---
name: skill-security-compliance
description: "Security and compliance — secrets management, OWASP, Keychain, token handling, data privacy"
type: security
tags: ["security", "secrets", "owasp", "compliance", "keychain"]
---

# Security and Compliance

## Secrets Management

### Iron Rule: No secrets in files or commits

- NEVER hardcode tokens, passwords, or API keys in any file.
- NEVER commit `.env`, `*.token`, or any file containing credentials.
- Always use: macOS Keychain, environment variables injected at runtime, or secret managers.

### Keychain Credentials

| Purpose | Keychain Service | Account | Retrieval |
|---------|-----------------|---------|-----------|
| GitHub token | `GithubToken` | `$(whoami)` | `security find-generic-password -a "$(whoami)" -s "GithubToken" -w` |
| Anthropic OAuth | `Claude Code-credentials` | `claude-token` | See extraction command below |
| Docker registry | `DockerRegistryAnubisWorks` | `jarvis` | `security find-generic-password -s "DockerRegistryAnubisWorks" -a "jarvis" -w` |

Anthropic OAuth access token extraction:
```bash
security find-generic-password -s "Claude Code-credentials" -a "claude-token" -w \
  | python3 -c "import sys,json; print(json.load(sys.stdin).get('claudeAiOauth',{}).get('accessToken',''))"
```

### Secret Token Lifecycle (Application First-Use Setup)

1. **No token set**: show setup screen with:
   - Masked input field + show/hide toggle
   - "Generate Token" button (cryptographically random)
   - Manual entry: require confirmation (enter twice)
   - Generated token: show single field + "Copy to clipboard"
2. **Token exists**: show login screen requiring the token.
3. **Storage**: hash with bcrypt or argon2. Never store plaintext.
4. Token shown once only at generation — cannot be retrieved later.

## OWASP Compliance

### OWASP Top 10 Mitigations

| Risk | Mitigation |
|------|-----------|
| A01 Broken Access Control | Role-based guards, least privilege, deny by default |
| A02 Cryptographic Failures | TLS 1.2+, AES-256 at rest, no weak algorithms |
| A03 Injection | Parameterized queries (SqlFactory), input validation, output encoding |
| A04 Insecure Design | Threat modeling, security by design, defense in depth |
| A05 Security Misconfiguration | Hardened defaults, no debug in prod, minimal attack surface |
| A06 Vulnerable Components | Dependency scanning, SBOM, automated updates |
| A07 Authentication Failures | OIDC/Keycloak, MFA, account lockout, secure session management |
| A08 Data Integrity Failures | Signed artifacts, verified CI/CD pipeline, SBOM |
| A09 Logging Failures | Structured security logs, audit trail, tamper-evident |
| A10 SSRF | Allowlist outbound, validate URLs, no internal network access from user input |

### OWASP ASVS v5.0

Follow Application Security Verification Standard for:
- Authentication (Level 2 minimum)
- Session management
- Access control
- Input validation
- Cryptography
- Error handling and logging

## Application Security

### Input Validation

- Validate ALL input at boundaries (API controllers, message handlers).
- Type checks, range checks, enum validation, format validation.
- Reject unexpected fields (strict schema validation).
- Sanitize for output context (HTML encoding, SQL parameterization).

### Authentication and Authorization

- OIDC with Keycloak as identity provider.
- JWT validation: signature, expiry, issuer, audience.
- Role-based access control (RBAC) at route and resource level.
- Token refresh: silent refresh, short-lived access tokens (5-15 min).
- Rate limiting on auth endpoints.

### Security Headers

```
Strict-Transport-Security: max-age=31536000; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Content-Security-Policy: default-src 'self'
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: camera=(), microphone=(), geolocation=()
```

## Container Security

- Read-only filesystem in containers (`readOnlyRootFilesystem: true`).
- Drop all capabilities, add only needed (`drop: ALL`).
- Run as non-root user.
- Seccomp/AppArmor profiles.
- No privileged containers.
- Minimal base images (Alpine/distroless).
- Scan images with Trivy before push.

## Data Privacy

### PII Handling

- Encrypt PII at rest (field-level encryption for sensitive columns).
- Mask PII in logs (replace with `***` or hash).
- Redact PII in telemetry/metrics.
- Classify data: public, internal, confidential, restricted.

### GDPR/CCPA Compliance

- **Data minimization**: collect only what's needed.
- **Purpose limitation**: use data only for stated purpose.
- **Right to erasure**: implement data deletion workflows.
- **Data portability**: export user data in standard format (JSON/CSV).
- **Consent management**: explicit opt-in, revocable.
- **Retention policies**: auto-delete data past retention period.

## Supply Chain Security

- **SBOM**: generate Software Bill of Materials per release (CycloneDX or SPDX format).
- **Dependency scanning**: Trivy, Grype, or OSV-Scanner in CI.
- **Image signing**: Cosign for container image signatures.
- **Lock files**: always commit lock files (package-lock.json, go.sum, etc.).
- **Pinned dependencies**: no floating versions in production.
- **Audit**: `npm audit`, `pip audit`, `go vuln check` in CI pipeline.

## Audit Logging

- Log all security-relevant events: login, logout, failed auth, permission changes, data access, admin actions.
- Structured format: timestamp, actor, action, resource, outcome, IP, user-agent.
- Tamper-evident: append-only log store or signed entries.
- Retention: minimum 90 days, configurable.
- Do NOT log secrets, tokens, or passwords (even hashed).
