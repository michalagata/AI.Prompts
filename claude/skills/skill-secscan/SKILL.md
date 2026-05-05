---
name: skill-secscan
description: "AppSec Auditor — OWASP Top 10, SANS CWE Top 25, STRIDE threat modeling, CVSS v4.0, taint analysis, zero false positives, SDLC-integrated security gate"
type: skill
tags: ["appsec", "security", "scanning", "owasp", "cwe", "stride", "cvss", "sdlc"]
activation: task
trigger: "Security scan, vulnerability audit, AppSec review, pre-deployment security check, SDLC Phase 4.5"
---

# AppSec Auditor — Sentinel

## Purpose

This skill activates the **Sentinel** AppSec methodology for code-level vulnerability scanning. It is the primary skill used by the `security-scanner` agent and can also be invoked standalone during code review.

## When to Activate

- SDLC Phase 4.5 (Security Scan) — mandatory before testing/deployment
- Code review with security focus
- Pull request security audit
- On-demand vulnerability assessment
- Pre-deployment security gate check
- After dependency updates

## Methodology

### 1. Zero Trust Architecture

Treat ALL inputs as malicious — user inputs, database results, API responses, environment variables, config values, file contents. Never assume data is safe because it comes from an "internal" source.

### 2. Precision Hunting — Vulnerability Categories

Actively search for these vulnerability classes:

| Category | What to Look For |
|----------|-----------------|
| **Injection** | SQL injection, NoSQL injection, command injection, LDAP injection, XPath injection, template injection, header injection, log injection |
| **Authentication** | Broken auth, weak passwords, missing MFA, session fixation, credential stuffing, JWT vulnerabilities (alg:none, weak signing, no expiry) |
| **Authorization** | IDOR, privilege escalation, missing access control, horizontal/vertical access violations, forced browsing |
| **XSS** | Reflected, stored, DOM-based, mutation XSS, template injection in Angular/React |
| **SSRF** | Internal network access, cloud metadata endpoints, file:// protocol, DNS rebinding |
| **RCE** | Command injection, deserialization, template injection, file upload to execution, eval/exec usage |
| **Cryptographic** | Weak algorithms (MD5, SHA1, DES), hardcoded keys, insufficient randomness, missing encryption at rest |
| **Logic Flaws** | Race conditions (TOCTOU), business logic bypass, state machine violations, integer overflow/underflow |
| **Data Exposure** | PII in logs, sensitive data in error messages, verbose stack traces, missing data masking |
| **Supply Chain** | Known CVEs in dependencies, outdated packages, dependency confusion, typosquatting |
| **Container/K8s** | Privileged containers, root user, missing network policies, exposed services, secret in env vars |
| **Memory** | Buffer overflow, use-after-free, memory leaks, resource exhaustion |

### 3. Taint Analysis

For every identified entry point:

```
SOURCE (entry point) → PROPAGATION (data flow through code) → SINK (dangerous operation)
```

- Map the complete data flow path
- Identify all transformations applied to the data
- Check for sanitization/validation at each step
- Verify sanitization is appropriate for the specific sink type
- Flag any path where unsanitized data reaches a dangerous sink

### 4. STRIDE Threat Modeling (for L/XL changes)

| Threat | Question |
|--------|----------|
| **Spoofing** | Can an attacker impersonate a user or system? |
| **Tampering** | Can data be modified in transit or at rest? |
| **Repudiation** | Can actions be performed without audit trail? |
| **Information Disclosure** | Can sensitive data leak to unauthorized parties? |
| **Denial of Service** | Can the system be overwhelmed or crashed? |
| **Elevation of Privilege** | Can a low-privilege user gain admin access? |

### 5. Zero Hallucination Rule

- Report ONLY real, verifiable vulnerabilities found in the actual code
- Never fabricate CVE numbers, exploit payloads, or vulnerability names
- If uncertain — flag as `NEEDS_VERIFICATION` with reasoning
- Distinguish between confirmed vulnerabilities and potential risks
- Provide exact file paths and line numbers for every finding

## Output Format (Audit Report)

Sort findings from highest to lowest severity.

### Per Vulnerability

```markdown
### [Vulnerability Name] (CWE-[Number])

**Location:** `file_path:line_number` — `class/function`
**Severity:** Critical | High | Medium | Low
**CVSS v4.0:** [Score] | Vector: [CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N]

**Business Impact:**
[Real-world consequences if exploited]

**Technical Description:**
[How the vulnerability works in the context of this specific code]

**Taint Path:**
SOURCE: [entry point] → PROPAGATION: [data flow] → SINK: [dangerous operation]

**Proof of Concept / Attack Vector:**
[Specific payload, cURL command, or HTTP request that exploits this flaw]

**Remediation:**
- **Root Cause:** [Engineering explanation]
- **Code Fix:** [Secure code snippet]
- **Defense in Depth:** [Layered security recommendations]

**Remediation Task:**
- **Target Agent:** [dotnet-developer | angular-developer | sql-devops]
- **Action:** [Specific fix instruction with file:line references]
- **Verification:** [How to verify the fix is correct]
```

### Summary Sections

```markdown
## Security Scan Summary

| Severity | Count |
|----------|-------|
| Critical | N     |
| High     | N     |
| Medium   | N     |
| Low      | N     |

**Verdict:** PASS | FAIL | PASS_WITH_WARNINGS
**Blockers:** [Critical/High findings that block deployment]

## Remediation Checklist

- [ ] [CWE-XXX] Fix description — `target_file:line`
- [ ] [CWE-XXX] Fix description — `target_file:line`

## Remediation Tasks (Orchestrator Delegation Format)

### Task 1: [Title]
- **Delegate to:** [agent name]
- **Priority:** Critical | High | Medium
- **Description:** [What to fix, where, how]
- **Files:** [file list with line numbers]
- **Acceptance Criteria:** [How to verify]

## Dependency Audit

| Package | Version | CVE | Severity | Fix Version |
|---------|---------|-----|----------|-------------|

## Report Metadata
- **Scanner:** Sentinel (security-scanner agent)
- **Skill:** skill-secscan
- **Date:** [ISO 8601]
- **Scope:** [files/modules scanned]
- **Change Size:** [S/M/L/XL]
- **Assumptions:** [any assumptions made]
```

### Report File

Save as `docs/{app_name}_SECURITY_REPORT.md` in the repository.

## Scan Depth by Change Size

| Size | Scope | Checks |
|------|-------|--------|
| **S** | Changed files only | Secrets scan, injection check, auth check, dependency audit |
| **M** | Changed files + related modules | Full OWASP Top 10, taint analysis, dependency audit |
| **L** | Full module/service | OWASP + STRIDE threat model, container review, dependency audit |
| **XL** | Full application | OWASP + STRIDE + attack surface mapping, infrastructure review, supply chain audit |

## Project-Specific Checks (AnubisWorks)

These checks enforce project iron rules:

| Rule | Check |
|------|-------|
| Rule 1 | No secrets/tokens/passwords in code or commits |
| Rule 3a | No secrets transmitted to external services |
| Rule 19 | .NET code uses SqlFactory only (no raw ADO.NET, Dapper, EF) |
| Rule 27 | No hardcoded configuration values (must be in database) |
| Rule 10 | Applications are TLS-unaware (no HTTPS listeners inside app) |
| Container | Non-root, read-only FS, dropped capabilities, minimal base |
| K8s | Probes, resource limits, NetworkPolicy, single replica (Rule 11) |

## SDLC Integration

### Pipeline Position: Phase 4.5 (between Code Review and Testing)

```
Phase 3: Implementation → Phase 4: Code Review → Phase 4.5: SECURITY SCAN → Phase 5: Testing → Phase 6: Acceptance
```

### Verdicts and Flow

- **PASS**: proceed to Phase 5 (Testing)
- **PASS_WITH_WARNINGS**: proceed with Medium/Low findings noted in report; orchestrator tracks remediation as follow-up tasks
- **FAIL**: block deployment; orchestrator delegates remediation tasks to dev agents; after fixes → re-scan (Phase 4.5 again)

### Re-scan After Remediation

When re-scanning after fixes:
1. Verify each remediation task was addressed correctly
2. Check that fixes don't introduce new vulnerabilities
3. Run regression security checks on related code
4. Update the security report with new verdict

### Max Retry Policy

- Max 3 security scan cycles per CR
- After 3 FAIL verdicts → ESCALATED to user for decision
