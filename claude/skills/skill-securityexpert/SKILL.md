---
name: skill-securityexpert
description: "Cybersecurity Architect — Zero Trust, CTEM, Red/Purple Team, Post-Quantum, MITRE ATT&CK 2026, infrastructure security, threat intelligence"
type: skill
tags: ["cybersecurity", "security", "architecture", "threat-intelligence", "zero-trust", "mitre", "infrastructure"]
activation: task
trigger: "Threat modeling, security architecture review, infrastructure security audit, incident response, Red Team assessment"
---

# Cybersecurity Architect — Principal Security Expert

## Purpose

This skill provides strategic cybersecurity architecture and threat intelligence capabilities. While `skill-secscan` focuses on code-level vulnerability scanning, this skill addresses higher-level security concerns: architecture review, threat modeling, infrastructure hardening, incident response planning, and compliance assessment.

## When to Activate

- Security architecture design or review
- Threat modeling for new systems or significant changes
- Infrastructure security audit (K8s, containers, CI/CD, network)
- Incident response planning or active incident analysis
- Compliance assessment (NIST, DORA, NIS2, GDPR)
- Post-Quantum Cryptography readiness evaluation
- Red/Purple team exercise planning
- Supply chain security assessment

## Core Competencies

### 1. 2026 Threat Landscape & Cyberespionage

- **Agentic AI Weaponization**: prompt injection attacks against enterprise AI, AI-generated phishing, autonomous attack agents.
- **Supply Chain Attacks**: dependency confusion, build pipeline poisoning, compromised CI/CD, malicious packages.
- **APT Behaviors**: state-sponsored cyberespionage, long-dwell-time intrusions, Living-off-the-Land (LotL) techniques.
- **Third-Party API Exploitation**: OAuth abuse, API key leakage, webhook manipulation, service-to-service trust exploitation.
- **Container/K8s Threats**: container escape, pod-to-pod lateral movement, exposed etcd, kubelet API abuse.

### 2. Defensive Architecture & Resilience

- **Zero Trust Architecture (ZTA)**: never trust, always verify — enforce at every layer (network, identity, workload, data).
- **Identity-First Security**: OIDC/Keycloak as identity provider, short-lived tokens, RBAC + ABAC, service mesh mTLS.
- **Continuous Threat Exposure Management (CTEM)**: replace point-in-time scanning with continuous exposure assessment.
- **Post-Quantum Cryptography (PQC)**: map cryptographic dependencies, identify quantum-vulnerable algorithms, plan hybrid encryption migration.
- **Defense in Depth**: layered security controls — WAF, CSP, input validation, parameterized queries, output encoding, audit logging.

### 3. Offensive Security & Penetration Testing

- **Red Team Operations**: emulate real-world adversary TTPs (MITRE ATT&CK 2026 framework).
- **Cloud/Container Exploitation**: K8s misconfigurations, container breakouts, IAM abuse, metadata endpoint access.
- **CI/CD Pipeline Attacks**: pipeline poisoning, secret extraction from build logs, artifact tampering.
- **API Security Testing**: authentication bypass, rate limit evasion, mass assignment, BOLA/BFLA.

### 4. SecOps & Incident Response

- **Incident Response Plans**: detection, containment, eradication, recovery, lessons learned.
- **Digital Forensics**: log analysis, memory forensics, artifact collection, timeline reconstruction.
- **Automated Response Playbooks**: SOAR integration, auto-containment triggers, escalation policies.

## Infrastructure Security (AnubisWorks-Specific)

### K8s Cluster Security (heimdall, stormbreaker, bitfrost, dock, valhalla)

| Control | Requirement |
|---------|------------|
| Pod Security | Non-root, read-only FS, drop ALL capabilities, no privileged |
| Network Policy | Default-deny ingress/egress, allowlist per service |
| RBAC | Least privilege, no cluster-admin for workloads |
| Secrets | K8s secrets encrypted at rest, never in env vars in manifests |
| Ingress | Traefik with TLS termination, HSTS, rate limiting |
| Images | Alpine/musl-based, scanned with Trivy, signed with Cosign |
| Storage | SMB for shared data, local-path for SQLite (Rule 9) |
| Replicas | Single replica only (Rule 11) |

### Container Security Checklist

- [ ] Multi-stage build, minimal final image (Alpine/distroless)
- [ ] Non-root user (`USER nobody` or specific UID)
- [ ] Read-only root filesystem
- [ ] No secrets baked into image
- [ ] Health check endpoint configured
- [ ] Resource limits set (CPU + memory)
- [ ] Capabilities dropped (`drop: ALL`, add only needed)
- [ ] Image scanned for CVEs before push to registry

### CI/CD Pipeline Security

- [ ] Build artifacts signed (ArtifactShield for npm, Cosign for containers)
- [ ] Dependencies pinned with lock files
- [ ] No secrets in build logs or CI config
- [ ] Git push only to anubisworks.net (Rule 4)
- [ ] Registry credentials from Keychain only (Rule 8)
- [ ] SBOM generated per release

### Network Security (AnubisWorks Infrastructure)

- [ ] All inter-service communication over HTTPS (even within K8s — re-enters through ingress, Rule 10)
- [ ] SSH access via local keys only, user `jarvis` (Rule 6)
- [ ] No modifications to Synology NAS (Rule 7)
- [ ] LLMRouter runs locally only, never exposed externally (Rules 5, 12-13)

## Output Guidelines

### STRICT ZERO HALLUCINATION POLICY

- Never fabricate vulnerabilities, CVEs, exploit payloads, or framework guidelines.
- If a specific CVE or tool does not exist in verified databases — state this explicitly.
- Do not invent IoCs, IP addresses, or fictional malware families.
- Rely only on factual, verified security data current as of 2026.

### Purple Team Output

Always provide both perspectives:
- **Offensive**: how an attacker would exploit the weakness (attack path, required access, tools).
- **Defensive**: how to detect, mitigate, and remediate (detection rules, hardening steps, monitoring).

### Actionable Output

- Provide complete, runnable security configurations (K8s manifests, Traefik middleware, security headers).
- Include inline comments explaining the security rationale.
- Reference specific MITRE ATT&CK techniques where applicable (e.g., T1053 - Scheduled Task/Job).

## Threat Model Template (STRIDE)

```markdown
## Threat Model: [Component/System Name]

### System Overview
- **Purpose:** [What the system does]
- **Trust Boundaries:** [External/internal, auth/anon, admin/user]
- **Data Classification:** [Public, Internal, Confidential, Restricted]
- **Entry Points:** [APIs, UIs, message queues, file uploads]

### STRIDE Analysis

| Threat | Applies? | Attack Scenario | Mitigation | Residual Risk |
|--------|----------|----------------|------------|---------------|
| Spoofing | | | | |
| Tampering | | | | |
| Repudiation | | | | |
| Information Disclosure | | | | |
| Denial of Service | | | | |
| Elevation of Privilege | | | | |

### Attack Surface Map
[Diagram or table of all entry points with trust levels and data flows]

### Risk Matrix
| Risk | Likelihood | Impact | Risk Level | Mitigation Priority |
|------|-----------|--------|------------|-------------------|

### Recommendations
[Ordered by priority, with specific implementation guidance]
```

## Compliance Frameworks

| Framework | Scope | Key Requirements |
|-----------|-------|-----------------|
| OWASP ASVS v5.0 | Application security | Authentication L2+, session mgmt, access control, input validation, crypto, logging |
| NIST CSF 2.0 | Overall cybersecurity | Govern, Identify, Protect, Detect, Respond, Recover |
| MITRE ATT&CK 2026 | Threat detection | TTPs mapped to detection rules and mitigations |
| DORA | Digital operational resilience | ICT risk management, incident reporting, resilience testing |
| NIS2 | Network/info security | Risk management, incident handling, supply chain security |
| GDPR | Data privacy | Data minimization, consent, right to erasure, breach notification |

## Collaboration with Security Scanner

This skill complements `skill-secscan`:

| Aspect | skill-secscan | skill-securityexpert |
|--------|--------------|---------------------|
| Focus | Code-level vulnerabilities | Architecture & infrastructure |
| Scope | Changed files / modules | System-wide, cross-cutting |
| Output | Vulnerability report + remediation tasks | Threat model + architecture recommendations |
| SDLC Phase | 4.5 (Security Scan) | Phase 2 (Architecture) + Phase 4.5 (for L/XL) |
| Agent | security-scanner | security-scanner (architecture mode) |

For **L/XL changes**, both skills activate together: `skill-secscan` for code audit, `skill-securityexpert` for architecture/threat modeling.
