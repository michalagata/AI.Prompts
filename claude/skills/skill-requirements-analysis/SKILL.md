---
name: skill-requirements-analysis
description: "Requirements gathering, brainstorming, clarifying questions, user stories, acceptance criteria"
type: workflow
tags: ["requirements", "analysis", "brainstorming", "user-stories"]
---

# Requirements Analysis

## Core Principle

**Never assume — always ask.** Requirements gathering is about understanding before proposing.

## Process

### 1. Understand Context and Business Domain

- What problem are we solving?
- Who experiences this problem?
- What is the current workaround (if any)?
- What is the business value of solving this?

### 2. Identify Stakeholders

- Direct users (who interacts with the system?)
- Indirect stakeholders (who benefits from the system?)
- Technical stakeholders (who maintains/operates it?)
- Business stakeholders (who funds/owns it?)

### 3. Ask Clarifying Questions (Minimum 5 Before Proposing Solutions)

Use the **5W+H** framework:

| Question | Purpose |
|----------|---------|
| **Who** | Who are the users? What roles exist? |
| **What** | What exactly should the system do? What should it NOT do? |
| **Where** | Where will this run? On-prem? Cloud? Mobile? |
| **When** | Timeline? Deadlines? Phasing? |
| **Why** | Why is this needed now? What triggered this? |
| **How** | How should it work from the user's perspective? |

Additional probing questions:
- What does success look like?
- What are the constraints (budget, time, technology)?
- What integrations are needed?
- What are the security/compliance requirements?
- What happens if this fails?

### 4. Document Functional Requirements as User Stories

Format:
```
As a [role],
I want [capability],
So that [business value].
```

Guidelines:
- One behavior per story.
- Independent (can be implemented in any order).
- Negotiable (details can be discussed).
- Valuable (delivers user/business value).
- Estimable (small enough to estimate).
- Small (completable in one sprint/iteration).
- Testable (clear pass/fail criteria).

### 5. Document Non-Functional Requirements (NFR Matrix)

| Category | Requirement | Target | Priority |
|----------|------------|--------|----------|
| Performance | Response time | p95 < 500ms | High |
| Availability | Uptime | 99.9% | High |
| Scalability | Concurrent users | 100 | Medium |
| Security | Auth method | OIDC/Keycloak | High |
| Accessibility | Standard | WCAG 2.1 AA | High |
| Data | Retention | 90 days | Medium |
| Compliance | Standard | GDPR | High |

### 6. Identify Edge Cases and Error Scenarios

- What happens with empty input?
- What happens with maximum-size input?
- What happens during network failure?
- What happens with concurrent access?
- What happens with invalid/malicious input?
- What happens if a dependency is unavailable?

### 7. Create Acceptance Criteria (Given-When-Then)

```
Given [precondition/context],
When [action/trigger],
Then [expected outcome].
```

Write at least 3 acceptance criteria per user story:
- Happy path (normal flow)
- Edge case (boundary condition)
- Error case (failure scenario)

### 8. Identify Risks and Constraints

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|-----------|
| Risk description | H/M/L | H/M/L | How to reduce |

Constraints to capture:
- Technology constraints (must use X, cannot use Y)
- Infrastructure constraints (k3s, Alpine images, no x86-64-v2)
- Time constraints (deadline, phasing)
- Budget constraints
- Regulatory constraints

### 9. Propose Architecture Options

Present at least 2-3 options with trade-offs:

| Option | Pros | Cons | Complexity | Risk |
|--------|------|------|-----------|------|
| Option A | ... | ... | Low | Low |
| Option B | ... | ... | Medium | Medium |
| Option C | ... | ... | High | Low |

Recommend one option with justification.

## Brainstorming Techniques

- **Mind Mapping**: central concept with branching ideas.
- **Reverse Brainstorming**: "What could go wrong?" then invert to solutions.
- **SCAMPER**: Substitute, Combine, Adapt, Modify, Put to other use, Eliminate, Reverse.
- **Constraint Removal**: "If we had no constraints, what would we build?" then add constraints back.
- **Analogies**: "How does [similar system] solve this?"

## Output Format

Final requirements document structure:

```markdown
# Requirements: [Feature/System Name]

## Summary
One paragraph describing what we're building and why.

## Stakeholders
- Role: needs

## User Stories
1. As a..., I want..., So that...
   - AC1: Given... When... Then...
   - AC2: Given... When... Then...

## Non-Functional Requirements
[NFR Matrix]

## Edge Cases and Error Scenarios
[List]

## Acceptance Criteria
[Detailed Given-When-Then]

## Risk Register
[Risk table]

## Architecture Proposal
[Options with trade-offs and recommendation]

## Open Questions
[Unanswered questions requiring further discussion]
```

## Rules

- Always present **multiple options** with pros/cons before recommending.
- Never propose a solution before understanding the problem.
- Document assumptions explicitly — they may be wrong.
- Prioritize requirements (MoSCoW: Must, Should, Could, Won't).
- Review against existing Iron Rules for compliance.
