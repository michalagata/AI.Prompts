---
name: skill-code-review
description: "Thorough code review — security, correctness, performance, maintainability, project rules compliance"
type: quality
tags: ["review", "security", "quality", "correctness"]
---

# Code Review

## Review Process

1. Understand the context: what problem does this change solve?
2. Read the full diff (all files, not just the latest commit).
3. Check each dimension below.
4. Report findings with severity, location, and actionable fix.

## Severity Levels

| Level | Meaning | Action Required |
|-------|---------|----------------|
| **CRITICAL** | Security vulnerability, data loss risk, crash, logic error | Must fix before merge |
| **WARNING** | Performance issue, maintainability concern, missing edge case | Should fix before merge |
| **SUGGESTION** | Style improvement, minor optimization, documentation | Nice to have |

## Dimension 1: Security

- [ ] No SQL injection (parameterized queries via SqlFactory?)
- [ ] No command injection (sanitized shell inputs?)
- [ ] No XSS (output encoding in templates?)
- [ ] No CSRF vulnerabilities (anti-forgery tokens?)
- [ ] Auth/authz enforced on all endpoints?
- [ ] No secrets/tokens/passwords in code or config files?
- [ ] Input validated at boundaries (type, range, format)?
- [ ] Sensitive data not logged or exposed in errors?
- [ ] Dependencies free of known CVEs?
- [ ] Rate limiting on public endpoints?

## Dimension 2: Correctness

- [ ] Edge cases handled (null, empty, max values)?
- [ ] Null/undefined properly checked before use?
- [ ] Concurrency issues (race conditions, deadlocks)?
- [ ] Error paths handled (try/catch, error returns)?
- [ ] Off-by-one errors in loops/indexes?
- [ ] Type safety (no unsafe casts, no `any`)?
- [ ] Resource cleanup (connections closed, streams disposed)?
- [ ] Boundary conditions (empty collections, 0, negative numbers)?
- [ ] State transitions valid (no impossible states)?

## Dimension 3: Performance

- [ ] No N+1 query patterns?
- [ ] No unnecessary memory allocations in hot paths?
- [ ] No blocking calls in async context?
- [ ] Database indexes exist for queried columns?
- [ ] No O(n^2) where O(n) or O(n log n) is possible?
- [ ] Pagination for list endpoints?
- [ ] Caching where appropriate (with invalidation strategy)?
- [ ] No unbounded collections/streams?

## Dimension 4: Maintainability

- [ ] Clear, descriptive naming (variables, functions, classes)?
- [ ] SOLID principles followed?
- [ ] DRY (but no premature abstraction)?
- [ ] Separation of concerns (single responsibility)?
- [ ] Code is readable without comments (self-documenting)?
- [ ] Comments explain "why", not "what"?
- [ ] Functions are focused (< 50 lines, single purpose)?
- [ ] No dead code or commented-out code?

## Dimension 5: Project Rules Compliance

Check against the Iron Rules:

| Rule | Check |
|------|-------|
| Rule 1 (No secrets) | No credentials in code/commits? |
| Rule 19 (SqlFactory) | .NET uses SqlFactory, not Dapper/EF/ADO.NET? |
| Rule 20 (No functionality removal) | Bug fix preserves existing features? |
| Rule 22 (Tests pass) | Tests included and passing? Coverage >= 80%? |
| Rule 23 (Protected tests) | Existing tests not modified without justification? |
| Rule 26 (Footer) | Web app has mandatory footer? |
| Rule 27 (Config in DB) | Configuration stored in database, not files? |
| Rule 15 (English only) | Code/comments/docs in English? |
| Rule 17 (Code-first) | No LLM calls where deterministic code works? |

## Review Output Format

```markdown
## Code Review: [PR/Change Description]

### Summary
Brief description of what was reviewed and overall assessment.

### Findings

#### CRITICAL
1. **[File:Line]** — Description of issue.
   - Why it matters: ...
   - Fix: ...

#### WARNING
1. **[File:Line]** — Description of issue.
   - Why it matters: ...
   - Fix: ...

#### SUGGESTION
1. **[File:Line]** — Description of improvement.
   - Suggestion: ...

### Positive Observations
- What was done well (acknowledge good patterns).

### Verdict
- [ ] APPROVE — no critical/warning findings
- [ ] REQUEST CHANGES — critical findings must be addressed
- [ ] COMMENT — warnings to discuss
```

## Rules

- **Never auto-approve.** Always review with fresh eyes.
- **Provide actionable feedback**: what's wrong, why it matters, how to fix it.
- **Be specific**: reference exact file and line number.
- **Be constructive**: suggest the fix, not just the problem.
- **Acknowledge good code**: positive reinforcement for good patterns.
- **Context matters**: a prototype has different standards than production code.
- **Check the full change**: all commits in the PR, not just the latest.
