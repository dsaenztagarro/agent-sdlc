---
paths:
  - "<!-- FILL: the glob of the project's test files -->"
  - "<!-- FILL: the glob of the source of its interactive components -->"
---

# Testing, and building a stateful component

These rules load when a file the `paths:` above names is opened: the project's tests, and the source of the components that hold state between a user's actions.
Each rule is one sentence, followed where it helps by why it holds or how to tell it is broken; where it differs by client, a web form and a terminal form follow it.

## What a test runs against

- **Test the real thing; never mock the object under test or its in-process collaborators:** a test drives real collaborators and fixtures and asserts on real outcomes, with a double only at a genuine boundary — the network or an external service, infrastructure a unit test cannot stand up, or an error it cannot otherwise force.
  - *Why:* a test that stubs what it checks proves the stub, and stays green while the real code breaks.
  - *The tell:* a refactor that keeps the behaviour breaks the test; rewrite it against real objects and observable outcomes.
- **Smoke-test every interactive surface:** at least one end-to-end test reaches it through a real interaction, not a direct address, and asserts what should now render, never the absence of an error.
  - *Scope:* it proves the wiring connects; the permutations behind it belong to focused tests.
  - *Why positive:* an assertion of what should render states what the feature does and still fails when the wiring breaks, where an error string guards one past failure and documents nothing.

## How a test finds what it checks

- **Locate markup the way a user does:** by role and accessible name, then label, then visible text, and a class or a data hook appears only inside a named helper in the test support code, never in a test body.
- **A component's state is accessible state, never a class alone.**
  - *Web:* the native attribute where the element has one, otherwise the state the WAI-ARIA specification defines for the element's role, kept in step by the code that changes what is shown and read through a filter added once to the test framework's role selectors.
  - *Terminal:* the test asserts the rendered frame's text, never a style code.

## The shape of a stateful component's tests

- **Assert invariants after every command:** the tests drive the real component through a sequence of commands beside a model of what its state should be, and after each command check that every control the state implies is usable, the render matches the model, no value is silently lost and no shape the backend rejects is held — in a few named journeys, one of them recovery from every filled state, plus one fixed-seed walk whose failing sequence is promoted to a journey.
- **A mutation check proves detection, not correctness:** a surviving mutation is a finding, and a killed one is no guarantee that the behaviour is the right one.
- **Prefer a source-invariant guard** for a closed property of the code — every one of a kind declares something, every path named resolves — and keep the slow end-to-end test for the wiring only it can prove.

## Building a stateful component

- **A stateful component is built complete:** its reachable states are listed before it is built, and each one is legal (never a shape the backend rejects), escapable (an action leaves it) and visible (every value it holds can be seen and cleared).
- **Never hide a control in reaction to a user action:** a control with no answer in the current state states that, with a derived value or a disabled field and its reason.
- **A question two surfaces ask has one implementation,** which both call.
