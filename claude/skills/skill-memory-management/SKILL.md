---
name: skill-memory-management
description: "Memory persistence, compression, archival, and search for agents and Claude Code"
type: system
tags: ["memory", "persistence", "context", "archival"]
---

# Memory Management

> **This skill is ALWAYS ACTIVE for all agents and Claude Code sessions.**

## Core Principle

Every agent and Claude Code session must persist context to enable continuity across sessions, interruptions, and handoffs.

## Directory Structure

```
memory/
  session/          # Current session files (hot)
  archive/          # Compressed weekly archives (warm)
  knowledge/        # Extracted reusable facts (permanent)
  scripts/          # Utility scripts
  MEMORY.md         # Index file — start searches here
```

## Session Files

### After EVERY action: write context

File: `memory/session/{agent-name}-{YYYY-MM-DD-HHmm}.md`

Entry format:

```markdown
# Session Entry: {agent-name} — {YYYY-MM-DD HH:mm}

## Action
What was performed.

## Decision
What was decided and why (alternatives considered).

## Context
Current state, relevant background, dependencies.

## Blockers
Any issues preventing progress.

## Files Modified
- /path/to/file1.ext (reason)
- /path/to/file2.ext (reason)
```

### Before EVERY action: read latest session file

1. Check `memory/MEMORY.md` for current state summary.
2. Read the latest `memory/session/{agent-name}-*.md` file for recent context.
3. If resuming after interruption, read last 3 session files for full context recovery.

## Compression Rules

When `memory/session/` has **>20 files per agent**:

1. Identify all files for that agent older than 7 days.
2. Group by ISO week number.
3. Compress into weekly archive: `memory/archive/{agent-name}-week-{YYYY-WW}.md`
4. Archive format:

```markdown
# Weekly Archive: {agent-name} — Week {YYYY-WW}

## Summary
High-level summary of the week's work.

## Key Decisions
- Decision 1 (date): rationale
- Decision 2 (date): rationale

## Actions Taken
- Action 1 (date): outcome
- Action 2 (date): outcome

## Knowledge Extracted
- Topic: brief finding

## Blockers Resolved
- Blocker: resolution
```

5. Delete original session files after successful archive creation.

## Knowledge Extraction

After significant tasks (feature completion, architecture decisions, bug resolution):

1. Extract reusable facts to `memory/knowledge/{topic}.md`
2. Topics: technology patterns, project conventions, infrastructure details, learned lessons
3. Format:

```markdown
# Knowledge: {topic}

## Facts
- Fact 1
- Fact 2

## Patterns
- Pattern: when to apply, how

## Gotchas
- Issue: workaround

## References
- File/URL: context
```

## Search Protocol

When looking for information:

1. **MEMORY.md index** — check the top-level summary first
2. **session/** — recent session files for current context
3. **knowledge/** — extracted facts by topic
4. **archive/** — historical context by week

## Utility Scripts

| Script | Purpose |
|--------|---------|
| `memory/scripts/compress-memory.sh` | Compress old session files into weekly archives |
| `memory/scripts/search-memory.sh` | Full-text search across all memory files |
| `memory/scripts/extract-knowledge.sh` | Extract knowledge from recent sessions |

## MEMORY.md Index

Maintain `memory/MEMORY.md` as a living index:

```markdown
# Memory Index

## Current State
Brief description of what's in progress.

## Active Agents
- agent-name: last activity, current task

## Recent Knowledge
- topic: one-line summary (date)

## Archive Coverage
- Week YYYY-WW: summary
```

Update this file after every archive compression and significant knowledge extraction.
