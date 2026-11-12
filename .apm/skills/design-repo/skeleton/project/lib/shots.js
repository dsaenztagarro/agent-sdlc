// shots — a screenshot of every page in every state it names, of the application surface alone.
//
// A page is a snapshot of the application: one surface, every state it can be in, reached from a
// state bar (design-handoff §4). This walks that bar on every page and captures the surface in each
// state, so what a reader looks at is the application and nothing drawn around it — a caption, a
// note or a paragraph beside the surface never reaches a shot. A page that does not keep the
// contract is named, and a brief fixes it; nothing here edits a page.
//
// The contract, in the page as it renders:
//   [data-surface]                            exactly one: the application as it renders, chrome included
//   [data-state="<Family> · <state>"]         one per state, inside the surface, one shown at a time; the
//                                             family is the name before " · ", or the whole name for the
//                                             family's first state
//   #state=<family>/<state>                   the address that shows a state, as the design system's state
//                                             switcher writes it
//   [role="tablist"][aria-label="State"]      the switcher's State row, required once a page has two states:
//                                             with a state shown, its selected tab is labelled with the
//                                             state's name and reads "<state>", or "Default" for the bare one
//   [data-design-chrome]                      the switcher and anything else drawn around the surface,
//                                             hidden in every shot
//
// Usage: node lib/shots.js PAGES_DIR OUT_DIR
// Exit 0 when every page keeps the contract, 1 when one does not, 2 when no browser can be launched.

const fs = require("fs");
const http = require("http");
const path = require("path");
const { chromium } = require("playwright-core");

const [pagesDir, outDir] = process.argv.slice(2).map((p) => path.resolve(p));
const SCALE = 2;
const VIEWPORT = { width: 1440, height: 900 };
// Chrome refuses a screenshot taller than about 32,000 device pixels; a taller surface is cut here.
const MAX_HEIGHT = Math.floor(32000 / SCALE);
const BAR = '[role="tablist"][aria-label="State"]';
const CHROME = "[data-design-chrome]";
const SEP = " · ";
const TYPES = { ".html": "text/html", ".css": "text/css", ".js": "text/javascript", ".jsx": "text/javascript",
  ".json": "application/json", ".svg": "image/svg+xml", ".png": "image/png", ".woff2": "font/woff2" };

const slug = (s) => s.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");

function pages(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) return entry.name === "_ds" ? [] : pages(full);
    return entry.name.endsWith(".html") ? [full] : [];
  }).sort();
}

// Served over http rather than file://, which gives a page a null origin and breaks every fetch.
function serve(root) {
  const server = http.createServer((req, res) => {
    const file = path.join(root, decodeURIComponent(new URL(req.url, "http://x").pathname));
    if (!file.startsWith(root) || !fs.existsSync(file) || fs.statSync(file).isDirectory()) {
      res.writeHead(404).end();
      return;
    }
    res.writeHead(200, { "content-type": TYPES[path.extname(file)] || "application/octet-stream" });
    fs.createReadStream(file).pipe(res);
  });
  return new Promise((resolve) => server.listen(0, "127.0.0.1", () => resolve(server)));
}

async function launch() {
  try {
    return await chromium.launch({ channel: "chrome" });
  } catch {
    return chromium.launch();
  }
}

async function contract(page) {
  return page.evaluate((bar) => {
    const states = [...document.querySelectorAll("[data-state]")]
      .filter((el) => !el.parentElement.closest("[data-state]"))
      .map((el) => el.dataset.state.trim());
    return { surfaces: document.querySelectorAll("[data-surface]").length, states, hasBar: Boolean(document.querySelector(bar)) };
  }, BAR);
}

// A state's family and the part after it, null for the bare family.
function parse(name) {
  const i = name.indexOf(SEP);
  return i < 0 ? { family: name, part: null } : { family: name.slice(0, i), part: name.slice(i + SEP.length) };
}

// The address the switcher shows a state at, and the label its tab reads.
const address = (name) => {
  const { family, part } = parse(name);
  return part === null ? slug(family) : `${slug(family)}/${slug(part)}`;
};
const label = (name) => parse(name).part ?? "Default";

function breaches({ surfaces, states, hasBar }) {
  const found = [];
  if (surfaces !== 1) found.push(`has ${surfaces} [data-surface] elements; it needs exactly one`);
  if (states.length === 0) found.push("names no state: no [data-state] element");
  if (states.length > 1 && !hasBar) found.push(`has ${states.length} states and no state bar`);
  return found;
}

// Each state is reached at its address, and the bar must then name it; the design chrome is hidden
// while the surface is captured, on a page with one state as on one with many.
async function shoot(page, rel, states, hasBar) {
  const shots = [];
  const cut = [];
  for (const [i, name] of states.entries()) {
    if (hasBar) {
      await page.evaluate((hash) => { location.hash = hash; }, `state=${address(name)}`);
      const shown = await page.waitForFunction(
        (n) => [...document.querySelectorAll("[data-state]")].some((el) => el.dataset.state.trim() === n && el.checkVisibility()),
        name, { timeout: 2000 }
      ).then(() => true, () => false);
      if (!shown) return { breach: `its address #state=${address(name)} does not show the "${name}" state` };
      const tab = await page.evaluate((bar) => {
        const t = document.querySelector(`${bar} [role="tab"][aria-selected="true"]`);
        return t && { name: t.getAttribute("aria-label"), text: t.textContent.trim() };
      }, BAR);
      if (!tab || tab.name !== name || tab.text !== label(name)) {
        return { breach: `at the "${name}" state, its state bar reads ${JSON.stringify(tab?.text ?? null)}, not "${label(name)}"` };
      }
    }
    await page.evaluate((chrome) => document.querySelectorAll(chrome).forEach((c) => { c.style.visibility = "hidden"; }), CHROME);
    const file = path.join(rel.replace(/\.html$/, ""), `${String(i + 1).padStart(2, "0")}-${slug(name)}.png`);
    fs.mkdirSync(path.join(outDir, path.dirname(file)), { recursive: true });
    // The stage gives the surface the viewport's height and the surface scrolls inside it, so a shot
    // would stop at the fold: the viewport grows by what the surface's scrollers overflow.
    const overflow = await page.evaluate(() => {
      const surface = document.querySelector("[data-surface]");
      return Math.max(0, ...[surface, ...surface.querySelectorAll("*")]
        .filter((el) => /auto|scroll/.test(getComputedStyle(el).overflowY))
        .map((el) => el.scrollHeight - el.clientHeight));
    });
    const height = VIEWPORT.height + overflow;
    if (height > MAX_HEIGHT) cut.push(name);
    await page.setViewportSize({ ...VIEWPORT, height: Math.min(height, MAX_HEIGHT) });
    await page.locator("[data-surface]").screenshot({ path: path.join(outDir, file), animations: "disabled" });
    await page.setViewportSize(VIEWPORT);
    await page.evaluate((chrome) => document.querySelectorAll(chrome).forEach((c) => { c.style.visibility = ""; }), CHROME);
    shots.push({ name, file });
  }
  return { shots, cut };
}

function index(shot) {
  const esc = (s) => s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" })[c]);
  const sections = Object.entries(shot).map(([rel, shots]) =>
    `<section><h2>${esc(rel)}</h2>${shots.map((s) =>
      `<figure><img src="${esc(s.file)}" alt="${esc(s.name)}"><figcaption>${esc(s.name)}</figcaption></figure>`).join("")}</section>`);
  return `<!doctype html><meta charset="utf-8"><title>shots</title>
<style>body{font:14px system-ui;margin:24px;background:#f4f4f4}figure{display:inline-block;margin:0 16px 16px 0;vertical-align:top}
img{max-width:720px;border:1px solid #ccc;display:block}figcaption{margin-top:4px}</style>
${sections.join("\n")}\n`;
}

(async () => {
  const server = await serve(pagesDir);
  let browser;
  try {
    browser = await launch();
  } catch (error) {
    server.close();
    console.error(`error: no browser to drive — install Google Chrome, or run \`npx playwright install chromium\`\n  ${error.message.split("\n")[0]}`);
    process.exit(2);
  }

  fs.rmSync(outDir, { recursive: true, force: true });
  fs.mkdirSync(outDir, { recursive: true });
  const base = `http://127.0.0.1:${server.address().port}/`;
  const shot = {};
  const broken = [];
  const cuts = [];

  for (const file of pages(pagesDir)) {
    const rel = path.relative(pagesDir, file);
    const page = await browser.newPage({ viewport: VIEWPORT, deviceScaleFactor: SCALE });
    await page.goto(base + rel.split(path.sep).map(encodeURIComponent).join("/"), { waitUntil: "networkidle" });
    const found = await contract(page);
    const breach = breaches(found);
    if (breach.length) {
      breach.forEach((b) => broken.push(`${rel}: ${b}`));
    } else {
      const result = await shoot(page, rel, found.states, found.hasBar);
      if (result.breach) broken.push(`${rel}: ${result.breach}`);
      else shot[rel] = result.shots;
      result.cut?.forEach((name) => cuts.push(`${rel}: the ${name} state is cut at ${MAX_HEIGHT}px, taller than one screenshot holds`));
    }
    await page.close();
  }

  await browser.close();
  server.close();
  fs.writeFileSync(path.join(outDir, "index.html"), index(shot));

  const count = Object.values(shot).reduce((n, s) => n + s.length, 0);
  console.log(`${count} shots of ${Object.keys(shot).length} pages — open ${path.join(outDir, "index.html")}`);
  cuts.forEach((c) => console.log(`  ${c}`));
  if (broken.length) {
    console.error(`${broken.length} page contract breach(es) — a brief fixes them, never an edit in the mirror:`);
    broken.forEach((b) => console.error(`  ${b}`));
    process.exit(1);
  }
})();
