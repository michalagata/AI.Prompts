# Application Architecture (Rule 26)

---


## Rule 26: Application configuration & database architecture

Every application MUST follow these principles:

### Hot reload

- Periodically refresh config from DB (configurable interval). React to config save triggers immediately.
- Cache config in memory with TTL + on-write invalidation.

### REST API

- **All** configuration options MUST be exposed via authenticated REST API.
- Write operations MUST be protected by secret token or OIDC.
- **Every API write endpoint MUST validate input**: type checks, range checks, enum validation, format validation (dates, emails, URLs, IPs, etc.).
- API MUST return clear validation error messages (field name + reason + expected format).
