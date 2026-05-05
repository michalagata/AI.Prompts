---
name: skill-orchestration
description: "SDLC workflow orchestration — planning, delegation, progress tracking, quality gates"
type: workflow
tags: ["sdlc", "orchestration", "planning", "workflow"]
---

# SDLC Workflow Orchestration

## Plan Management (thePlan.md)

Before starting any non-trivial task:

1. **Create** `thePlan.md` in the repository root (or working directory) with the full action plan.
2. **Format**: use a checklist (`- [ ]` / `- [x]`) so each step's completion is visible.
3. **Present** the plan to the user and **wait for explicit approval** before executing any step.
4. **Modifications**: the user may request changes — reflect all modifications in `thePlan.md` before proceeding.
5. **During execution**: mark each completed step as `- [x]` immediately after finishing it.
6. **Commit per step**: when working in a repository, commit after each completed plan step or phase. The commit message should reference the step.
7. **Cleanup**: after all steps are complete, delete `thePlan.md` from the working directory. The plan is ephemeral.

Skip for trivial actions (single-line edits, quick lookups, simple questions) where a plan would be overhead.

## Task Delegation Patterns

| Phase | Responsible Skill/Agent | Handoff Artifact |
|-------|------------------------|------------------|
| Requirements | skill-requirements-analysis | Requirements doc with user stories, NFRs |
| Architecture | skill-architecture / skill-solution-creator | ADR, architecture diagram |
| Implementation | Language-specific skill (skill-dotnet, skill-angular, etc.) | Working code + tests |
| Code Review | skill-code-review | Review report with findings |
| Testing | skill-testing-unit, skill-testing-e2e | Test results, coverage report |
| Security | skill-security-compliance | Security scan report |
| Deployment | skill-devops-k8s | Deployed artifact, health check confirmation |

## Quality Gate Enforcement

Before any phase transition or commit:

- **Tests pass**: all unit tests green. No commit if tests fail.
- **Coverage >= 80%**: if already below 80%, must not reduce further.
- **Security clean**: no secrets in code, no critical vulnerabilities.
- **Existing functionality preserved**: no removed/disabled features during bug fixes.
- **Existing tests protected**: no modification without justification + approval.

## Handoff Protocols

### Requirements to Design
- Requirements doc approved by user
- All clarifying questions answered
- NFR matrix complete
- Risk register reviewed

### Design to Implementation
- Architecture Decision Record (ADR) created and approved
- API contracts defined (OpenAPI/Protobuf)
- Data model finalized
- Technology stack confirmed

### Implementation to Testing
- All code committed with passing unit tests
- Coverage threshold met
- Integration points documented
- Test data/fixtures available

### Testing to Deployment
- All test suites green (unit, integration, E2E, contract)
- Performance within SLO budgets
- Security scan clean
- Release notes prepared

## Progress Tracking and Reporting

- Update `thePlan.md` after each step completion
- Report blockers immediately (do not proceed silently)
- Track decisions made (what, why, alternatives considered)
- Log files modified in each step

## Post-Task Retrospective

After completing every non-trivial task, provide a brief retrospective (2-5 bullet points):

- What could the user do differently next time to help work **faster**, **more efficiently**, and **more accurately**?
- Focus on actionable, specific advice:
  - Better initial context?
  - More precise instructions?
  - Pointing to relevant files upfront?
  - Breaking the request differently?
  - Providing reference implementations?

Skip for trivial actions.

## Memory Persistence

After each plan step completion:
- Persist current state: what was done, decisions made, blockers encountered
- Include: files modified, tests affected, dependencies changed
- Format suitable for context recovery if session is interrupted
