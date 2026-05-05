# Development Standards (Rules 15-25)

---

## Rule 15: English-only engineering artifacts

- Code, comments, logs, commit messages, documentation: **English only**.
- User-facing UI strings and conversations: any language the user prefers.
- **All CLAUDE.md rules must be in English.** Translate before adding.
- **Zero exceptions.**

---

## Rule 16: Model priority — Sonnet-only (Opus is strict fallback)

- **ALL work MUST use Sonnet (latest).** Every task — reading, reasoning, architecture, planning, coding, refactoring, testing, debugging, research, communication, orchestration — uses Sonnet.
- **Opus is NEVER used by default.** Only when the user **explicitly requests** it in the current session. The switch applies to that session only.
- **No automatic Opus fallback.** If Sonnet hits a rate limit — wait, do not auto-switch. Only switch if user explicitly says so.
- **No Opus-for-reasoning / Sonnet-for-coding split.** Any such prior instruction is revoked. Sonnet does everything.
- **Delegation rule**: subagents via the Agent tool use `model: "sonnet"`. Use `model: "opus"` only if user explicitly requested it.
- Applies to Claude Code CLI sessions — not to LLMRouter routing configuration.
- **Zero exceptions.** No per-project `.claude/CLAUDE.md` may override this.

---

## Rule 17: Code-first over LLM calls

> Applies to every application mechanism, background task, agent tool, job, pipeline step, validator, router, and orchestration flow.

- **Default: deterministic code.** If functionality can be expressed with algorithms, rules, state machines, parsers, regex, SQL, graph traversal, classic ML, lookup tables, or schema validation — implement it as code, not an LLM call.
- **LLM calls are a last resort**: natural-language understanding, open-ended generation, free-form summarization, intent classification on unstructured input, code generation from prose specs.
- **In pipelines**: build a code scaffold that calls the LLM only on specific sub-steps that require it.
- **Before any LLM call**: ask "Can this be done with code?" If yes, write the code. If no, isolate the LLM surface to the minimum and document why.
- **During review/refactoring**: flag any LLM call replaceable by deterministic logic.
- **Rationale**: code is deterministic, testable, debuggable, versioned, cheap, and latency-free. LLM calls are stochastic, expensive, slow, hard to test, and add external dependencies.
- **Zero exceptions** for application implementation. User-facing chat/agent conversations may still use LLMs.

---

## Rule 18: Build target rules by application type

- **Containerized applications (Docker image)**:
  - Build for **Linux x64** (`linux-x64`) by default.
- **Console or desktop applications**:
  - Always build **3 platforms**: macOS, Windows x64, Linux x64.
  - Must be **portable** (self-contained, no runtime dependencies on the target machine).
  - This applies regardless of which platform the build runs on.
- **Zero exceptions.**

---

## Rule 20: Never remove or disable functionality when fixing bugs

- When fixing bugs, **never** remove, disable, comment out, or bypass existing application functionality.
- If a fix genuinely requires disabling or removing a feature, **describe the reason and present it for user decision** before proceeding. Do not act autonomously.
- This includes: removing endpoints, disabling middleware, commenting out features, replacing functionality with stubs/no-ops, adding feature flags that default to "off", or silently skipping code paths.
- The correct approach is to **fix the bug while preserving all existing functionality**.
- **Zero exceptions.**

---

## Rule 21: Approval required before changing existing logic

- Never modify existing application/system behavior without first describing the proposed change and waiting for explicit user approval.
- Config value changes explicitly requested by the user are fine — this rule targets autonomous logic changes.
- Applies to all repositories and systems.
- **Zero exceptions.**

---

## Rule 22: No commit without passing tests and adequate coverage

- **Never commit** if unit tests fail. Run the project's test suite before every commit.
- **Never commit** if code coverage drops below **80%**. If coverage is already below 80%, the commit must not reduce it further.
- If tests or coverage checks are not configured in the project, flag it to the user — do not silently skip.
- This applies to all repositories with a test suite. **Zero exceptions.**

---

## Rule 23: Existing unit tests are protected

- **Never modify existing unit test content** unless the tested functionality itself has changed and the modification is justified.
- **Before editing any existing test**: describe the proposed change with a clear justification and **wait for explicit user approval** before proceeding. This includes renaming, restructuring, "improving", or deleting tests.
- Adding **new** tests is always allowed and encouraged. This rule protects only existing tests.
- **Rationale**: tests are the safety net that catches regressions. Silently editing tests to make them pass defeats their purpose and masks bugs.
- **Zero exceptions.**

---

## Rule 24: Mandatory action plan (`thePlan.md`)

- **Before starting any non-trivial task**, create a `thePlan.md` file in the repository root (or working directory) with the full action plan.
- Present the plan to the user and **wait for explicit approval** before executing any step.
- The user may request changes to the plan — reflect all modifications in `thePlan.md` before proceeding.
- **Plan format**: use a checklist (`- [ ]` / `- [x]`) so each step's completion is visible.
- **During execution**: mark each completed step as `- [x]` in `thePlan.md` immediately after finishing it.
- **Commits per step**: when working in a repository, **commit after each completed plan step or phase**. The commit message should reference the step.
- **After all steps are complete**: delete `thePlan.md` from the working directory. The plan is ephemeral — it exists only for the duration of the task.
- Skip for trivial actions (single-line edits, quick lookups, simple questions) where a plan would be overhead.
- **Zero exceptions** for non-trivial work.

---

## Rule 25: Post-task retrospective

- After completing every non-trivial task, provide a brief **retrospective** section addressed to the user:
  - What could the user do differently next time to help me work **faster**, **more efficiently**, and **more accurately** on this type of task?
  - Examples: better initial context, more precise instructions, pointing to relevant files upfront, breaking the request differently, etc.
- Keep it concise (2-5 bullet points). Focus on actionable, specific advice — not generic platitudes.
- Skip the retrospective for trivial actions (single-line edits, quick lookups, simple questions).

---

## Rule 32: Mandatory upgrade to latest technology version on modification

- When modifying an existing application or system built with **.NET**, **Python**, or **Angular**, the **entire solution MUST be upgraded to the latest stable version** of that technology as part of the modification.
- This includes: framework version, SDK version, target framework moniker, language version, and all first-party dependencies (e.g., `Microsoft.Extensions.*`, `Angular CLI/Core`, Python minor version).
- Third-party dependencies SHOULD also be updated to their latest compatible versions, unless doing so would introduce breaking changes that exceed the scope of the task.
- The upgrade MUST be verified: build succeeds, all tests pass, no runtime regressions.
- If the upgrade itself would be a major effort (e.g., .NET 6 → .NET 10, Angular 14 → Angular 20), flag it to the user with an estimate before proceeding — but still perform it unless the user explicitly defers.
- **Zero exceptions.**
