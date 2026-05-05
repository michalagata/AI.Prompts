---
name: skill-testing-e2e
description: "E2E, contract, integration, and performance testing — Playwright, Pact, load testing"
type: quality
tags: ["testing", "e2e", "contract", "integration", "performance", "playwright"]
---

# E2E, Integration, Contract, and Performance Testing

## End-to-End Testing

### Framework: Playwright ONLY

- **No Selenium, no Cypress** — Playwright is the only approved E2E framework.
- Deterministic browser versions (pin in `package.json` or lock file).
- Cross-browser: Chromium, Firefox, WebKit.

### Patterns

- **Page Object Model**: encapsulate page interactions in reusable classes.
- **Test isolation**: each test starts from a known state (fresh session, seeded data).
- **Selectors**: prefer `data-testid` attributes over CSS classes or XPath.
- **Waits**: use Playwright auto-waiting. Never use `sleep()` or fixed delays.

### Failure Artifacts

On test failure, automatically capture:
- Screenshot of the page state.
- Playwright trace file (for trace viewer replay).
- Console logs and network requests.
- Video recording (configurable, off by default for speed).

### Container-First Execution

- Browsers + OS dependencies in Docker image.
- Multi-stage Dockerfile with `test` target.
- Reproducible across local dev and CI.

## Integration Testing

- Use **real databases and queues** in ephemeral containers (Testcontainers or docker-compose).
- Migrations applied to test database (same schema upgrade path as production).
- **No mocks for infrastructure** — test the real integration.
- Cleanup: destroy containers after test suite completes.
- Isolation: each test suite gets its own database/queue instance.

## Contract Testing

- **Pact** (producer/consumer) or OpenAPI schema-based verification.
- Consumer-driven contracts: consumer defines expectations, producer verifies.
- Contract tests run in CI on every PR.
- Breaking contract changes: fail the build, require explicit contract version bump.
- Publish contracts to a Pact Broker or store alongside code.

## Smoke Testing

Minimal tests to verify deployment health:
- Health endpoint returns 200 (`/healthz`, `/readyz`).
- One critical user path completes successfully.
- Run after every deployment, before traffic routing.

## Performance Testing

### Types

| Type | Purpose | Duration |
|------|---------|----------|
| Load | Normal expected traffic | 10-30 min |
| Soak | Sustained load over time | 2-8 hours |
| Spike | Sudden traffic burst | 5-10 min |
| Stress | Find breaking point | Until failure |

### SLO Budgets

- **Availability**: 99.9% (8.76h downtime/year)
- **Latency**: p50 < 200ms, p95 < 500ms, p99 < 1000ms
- **Error rate**: < 0.1% under normal load

### Tools

- k6, Locust, or Artillery for load generation.
- Compare results against SLO budgets.
- Fail the pipeline if SLOs are violated.

## Test Endpoints

- Test-specific endpoints under `/__test/*` or `/test/*`.
- Secured by token (not publicly accessible).
- Configuration toggles:
  - `EnableTestExecutionApis` (default: true in non-production)
  - `HostTestApis` (default: true in non-production)
- Disabled in production by default.

## Repeatability

- Tests must NOT depend on real external services unless sandboxed.
- Use WireMock, MockServer, or similar for external API simulation.
- Seed data deterministically (fixtures, not production snapshots).
- Time-dependent tests: use clock injection, not real time.

## LLMRouter E2E Exception

After every LLMRouter change, execute full E2E tests verifying:

- **Feature parity**: LLMRouter with local models (DeepSeek) performs all tasks Sonnet/Opus can perform.
- **Quality parity**: response quality matches Sonnet/Opus outputs.
- **No regression**: must not perform worse or slower than before the change.
- **Only acceptable difference**: response time.
- If any test reveals a gap — do not consider the change complete. Fix before marking done.

## CI Integration

- E2E tests run on every PR (can be parallelized with sharding).
- Integration tests run on every PR.
- Contract tests run on every PR.
- Performance tests: run on release branches or on-demand.
- Smoke tests: run after every deployment.
