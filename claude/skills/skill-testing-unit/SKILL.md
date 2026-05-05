---
name: skill-testing-unit
description: "Unit testing — frameworks, coverage enforcement, test protection, isolation"
type: quality
tags: ["testing", "unit-tests", "coverage", "quality"]
---

# Unit Testing

## Iron Rules

- **Never commit if tests fail** (Rule 22).
- **Never commit if coverage drops below 80%**. If already below 80%, must not reduce further.
- **Existing unit tests are PROTECTED** (Rule 23): never modify without justification + explicit user approval.
- Adding new tests: always allowed and encouraged.

## Test Characteristics

Every unit test MUST be:

- **Fast**: executes in milliseconds, not seconds.
- **Isolated**: no dependency on other tests, execution order, or shared mutable state.
- **Deterministic**: same result every run. No randomness (unless property-based testing).
- **No external dependencies**: no network calls, no filesystem access, no database connections.

## Frameworks by Technology

| Technology | Framework | Mocking | Assertions |
|-----------|-----------|---------|------------|
| .NET | xUnit | Moq | FluentAssertions |
| Angular | Jasmine + Karma | Jasmine spies / TestBed | Jasmine matchers |
| Python | pytest | unittest.mock / pytest-mock | pytest assertions |
| Go | testing | testify/mock | testify/assert |
| Rust | built-in `#[test]` | mockall | built-in assert macros |
| Java | JUnit 5 | Mockito | AssertJ |

## Test Pattern: Arrange-Act-Assert

```
// Arrange — set up test data and dependencies
// Act — execute the unit under test
// Assert — verify the outcome
```

Equivalent: Given-When-Then.

## Naming Convention

```
MethodName_StateUnderTest_ExpectedBehavior
```

Examples:
- `GetUser_WhenIdNotFound_ReturnsNull`
- `CalculateTotal_WithEmptyCart_ReturnsZero`
- `Validate_WhenEmailInvalid_ThrowsValidationException`

## Test Data

- **Deterministic fixtures**: predefined, predictable test data.
- No random data unless doing property-based testing (QuickCheck, FsCheck, Hypothesis).
- Use builder patterns or factory methods for complex test objects.
- Keep test data close to tests (in test files or dedicated fixtures/).

## Mocking Rules

- Mock **only at boundaries**: external services, database, file system, clock, random.
- **Never mock the unit under test** — that defeats the purpose.
- **Never mock value objects or DTOs** — use real instances.
- Prefer fakes/stubs over complex mock setups when possible.
- Verify interactions only when the interaction IS the behavior (e.g., "email was sent").

## Coverage

- Minimum threshold: **80%** (line coverage).
- Measure: statements, branches, functions.
- Focus on meaningful coverage:
  - Business logic: aim for 90%+.
  - Glue code / configuration: 80% acceptable.
  - Generated code: exclude from measurement.
- Tools:
  - .NET: Coverlet + ReportGenerator
  - Angular: Istanbul (built into Karma)
  - Python: pytest-cov
  - Go: built-in `go test -cover`

## Execution

Tests must be runnable from a clean checkout with a single command:

| Technology | Command |
|-----------|---------|
| .NET | `dotnet test` |
| Angular | `npm run test` |
| Python | `pytest` or `make test` |
| Go | `go test ./...` |
| Rust | `cargo test` |

## Anti-Patterns to Avoid

- Testing implementation details (private methods, internal state).
- Tests that test the framework, not your code.
- Overly complex test setup (> 10 lines of arrangement).
- Testing multiple behaviors in one test.
- Ignoring/skipping tests without documented reason.
- Brittle tests that break on unrelated changes.
- Sleep/delay in unit tests (indicates integration test).
