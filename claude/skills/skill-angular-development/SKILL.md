---
name: skill-angular-development
description: "Angular frontend development — TypeScript, RxJS, NgRx, Material, OIDC, accessibility"
type: development
tags: ["angular", "typescript", "frontend", "rxjs"]
---

# Angular Development

## Technology Stack

- **Framework**: Angular (latest stable)
- **Language**: TypeScript (strict mode enabled)
- **Reactive**: RxJS for async/event streams
- **State Management**: NgRx for complex state, services with BehaviorSubject for simple state
- **UI Components**: Angular Material
- **Auth**: OIDC library with Keycloak integration

## Authentication and Authorization

- OIDC library (angular-auth-oidc-client or similar) with Keycloak as identity provider.
- Route guards: role-based access control via `CanActivate` / `CanActivateChild`.
- Token refresh: silent refresh preferred over localStorage storage.
- Token storage: memory preferred (security). Use silent refresh (`iframe` or `code flow + PKCE`) to maintain sessions.
- Interceptor: attach access token to outbound API requests.
- Handle 401/403 gracefully: redirect to login or show appropriate error.

## Testing

- **Unit tests**: Jasmine + Karma
  - Test components in isolation (use `TestBed` with mock services).
  - Test services with injected mocks.
  - Test pipes and directives independently.
  - Coverage threshold: 80% minimum.
- **E2E tests**: Playwright ONLY
  - No Selenium, no Cypress.
  - Page Object Model pattern.
  - Test critical user journeys.
  - Deterministic browser versions in CI.

## Accessibility (Mandatory)

- **WCAG 2.1 AA compliance** is mandatory for all UI components.
- Use semantic HTML elements (`<nav>`, `<main>`, `<article>`, `<button>`, etc.).
- All interactive elements: keyboard accessible, visible focus indicators.
- All images: meaningful `alt` text (or `alt=""` for decorative).
- Form inputs: associated `<label>` elements.
- Color contrast: minimum 4.5:1 for normal text, 3:1 for large text.
- ARIA attributes where semantic HTML is insufficient.
- Test with screen reader (VoiceOver / NVDA).

## Build and Performance

- **No source maps in production** (security + IP protection).
- **Performance budgets**:
  - LCP (Largest Contentful Paint) < 2.5s
  - FID (First Input Delay) < 100ms
  - CLS (Cumulative Layout Shift) < 0.1
- Lazy loading for feature modules.
- Tree-shaking: ensure no dead code in bundles.
- Preload strategy for anticipated navigation.


## Network Communication

- **Outbound calls to other k8s services**: must use explicit `https://` in configuration (traffic exits pod and re-enters through ingress).
- **Internal pod communication**: plain HTTP (TLS terminated at ingress).
- Environment-based API URL configuration (never hardcoded).

## Component Architecture

- **OnPush change detection strategy** preferred for all components.
- Smart (container) components: handle state and logic.
- Dumb (presentational) components: `@Input()` / `@Output()` only, no injected services.
- Unsubscribe from observables: use `takeUntilDestroyed()`, `async` pipe, or `DestroyRef`.

## State Management Patterns

### NgRx (complex state)
- Actions: past-tense event names (`[Source] Event Description`).
- Reducers: pure functions, no side effects.
- Effects: handle async operations, API calls.
- Selectors: memoized, composable.
- Entity adapter for collection state.

### Services (simple state)
- `BehaviorSubject` with exposed `Observable` (readonly).
- Immutable updates (spread operator or `structuredClone`).
- Single responsibility per service.

## Code Style

- Standalone components (no NgModules for new features).
- Signals for new reactive state (Angular 16+).
- `inject()` function over constructor injection.
- Barrel exports (`index.ts`) for feature boundaries.
- Consistent file naming: `feature-name.component.ts`, `feature-name.service.ts`.
