# Memory Persistence System

## Purpose

Universal memory system ensuring agents and Claude Code never lose context across sessions.
Two complementary layers: **global** (cross-project) and **project** (per-repository).

---

## Architecture

### Global Memory (`~/.claude/memory/`)

Cross-project knowledge that applies everywhere. Managed by Claude Code and all agents.

```
~/.claude/memory/
├── MEMORY_SYSTEM.md       <- This file (system instructions)
├── MEMORY.md              <- Index loaded into context (keep under 200 lines)
├── session/               <- Active session context (per-agent, timestamped)
├── archive/               <- Compressed old sessions (weekly summaries)
│   └── .topic-index.tsv   <- Auto-generated index for fast retrieval
├── knowledge/             <- Permanent domain knowledge (never archived)
└── scripts/
    ├── compress-memory.sh      <- Archive sessions >7 days old
    ├── search-memory.sh        <- Search across all memory layers
    ├── extract-knowledge.sh    <- Save permanent knowledge
    ├── retrieve-archive.sh     <- Smart retrieval from archive (indexed)
    ├── init-project-memory.sh  <- Initialize .memory/ in a project
    └── memory-status.sh        <- Status overview of all memory layers
```

### Project Memory (`<repo>/.memory/`)

Per-repository working context. Tracks current task state, architecture decisions, action history.

```
<repo>/.memory/
├── STATE.md      <- Current task/status (overwritten each step)
├── CONTEXT.md    <- Architecture decisions, tech stack (updated on decisions)
├── HISTORY.md    <- Timestamped action log (append-only)
├── COMPACT.md    <- Snapshot before /compact (auto-created)
├── session/      <- Agent session files (same format as global)
├── archive/      <- Compressed old sessions
└── knowledge/    <- Project-specific permanent knowledge
```

---

## Mandatory Protocol (ALL agents + Claude Code)

### On Session Start

1. **Check project memory**: if working in a repository, check if `<repo>/.memory/` exists.
   - If yes: read `STATE.md`, `CONTEXT.md`, last 5 entries of `HISTORY.md`.
   - If no: run `~/.claude/memory/scripts/init-project-memory.sh <repo>` to create it.
2. **Check global memory**: read latest `~/.claude/memory/session/{agent}-*.md` for your agent name.
3. **Check for COMPACT.md**: if it exists in project `.memory/`, a compaction happened — restore context from it.

### After Every Significant Action

Write session context to **both** layers where applicable:

**Project level** (always, when working in a repo):
- Update `.memory/STATE.md` with current task, status, files modified, next step.
- Append to `.memory/HISTORY.md` with timestamped entry.
- Update `.memory/CONTEXT.md` if architecture/design decisions were made.

**Global level** (for cross-project insights, significant outcomes):
- Write `~/.claude/memory/session/{agent}-{YYYY-MM-DD-HHmm}.md` with:
  - **Action**: What was done (1-2 sentences)
  - **Decision**: Key decisions made and why
  - **Context**: What the next step needs to know
  - **Blockers**: Any issues found
  - **Files Modified**: List of changed files
  - **Project**: Which repository/project this relates to

### On Task Completion

1. Update project `.memory/STATE.md` to reflect completion.
2. If significant knowledge was discovered, extract it:
   - Project-specific: `~/.claude/memory/scripts/extract-knowledge.sh --dir <repo>/.memory <topic>`
   - Cross-project: `~/.claude/memory/scripts/extract-knowledge.sh <topic>`
3. Mark HISTORY.md with completion entry.

### Before /compact

1. Write `.memory/COMPACT.md` with full STATE.md + CONTEXT.md + last 20 HISTORY.md entries.
2. This is NON-NEGOTIABLE — compaction without COMPACT.md means context loss.

---

## Memory Lifecycle

| Stage | Location | Retention | Action |
|-------|----------|-----------|--------|
| **Active** | `session/` | < 7 days | Directly read on session start |
| **Archive** | `archive/` | Indefinite | Compressed weekly, indexed for retrieval |
| **Knowledge** | `knowledge/` | Permanent | Never archived, always available |

### Compression Rules

When `session/` contains files older than 7 days:
1. Run `compress-memory.sh [memory-dir]` (or let it auto-trigger when >20 files).
2. Files are grouped by agent + ISO week into `archive/{agent}-week-{YYYY-WNN}.md`.
3. Original session files are deleted after archival.
4. The topic index (`archive/.topic-index.tsv`) is rebuilt automatically.

### Archive Retrieval (NOT brute-force search)

The archive uses a **topic index** (`archive/.topic-index.tsv`) for fast lookups:

```bash
# Retrieve by topic (uses index, falls back to content search)
retrieve-archive.sh "deployment"

# Retrieve by agent (all archives for one agent)
retrieve-archive.sh --agent orchestrator

# Retrieve by week
retrieve-archive.sh --week 2026-W17

# Rebuild index after manual changes
retrieve-archive.sh --rebuild-index

# List all archive files
retrieve-archive.sh --list
```

The index is rebuilt automatically when:
- Compression runs
- A topic lookup misses the index (background rebuild)
- Explicitly requested with `--rebuild-index`

**When to use retrieve vs search:**
- `retrieve-archive.sh` — when you know the topic/agent/time range. Fast, indexed.
- `search-memory.sh` — when doing a broad text search across ALL layers. Slower, comprehensive.

---

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `compress-memory.sh [dir]` | Archive sessions >7 days | `compress-memory.sh` or `compress-memory.sh /repo/.memory` |
| `search-memory.sh <query>` | Search all layers | `search-memory.sh "topic" --agent name --dir /path` |
| `extract-knowledge.sh <topic>` | Save permanent knowledge | `extract-knowledge.sh "topic" "content"` or pipe stdin |
| `retrieve-archive.sh <topic>` | Smart archive retrieval | `retrieve-archive.sh "topic"` or `--agent name` or `--week W` |
| `init-project-memory.sh [dir]` | Create .memory/ in project | `init-project-memory.sh /path/to/repo` |
| `memory-status.sh` | Status overview | `memory-status.sh` or `--project /repo` or `--all /repo` |

All scripts support `--dir <path>` to work with any memory directory (global or project-level).

---

## Integration with Claude Code Auto Memory

Claude Code has its own auto memory system at `~/.claude/projects/{project}/memory/`.
This coexists with the script-based system:

| Feature | Auto Memory | Script-based Memory |
|---------|-------------|-------------------|
| Location | `~/.claude/projects/*/memory/` | `~/.claude/memory/` + `<repo>/.memory/` |
| Scope | Per-project feedback/preferences | Cross-project knowledge + task state |
| Format | YAML frontmatter + content | Markdown with session/archive/knowledge |
| Lifecycle | Managed by Claude Code runtime | Managed by scripts + agent protocol |
| Use case | User corrections, preferences | Task context, architecture decisions, domain knowledge |

**Both systems are active.** Auto memory captures user feedback and preferences.
Script-based memory captures task context, decisions, and domain knowledge.

---

## Integration with Agents

Every agent definition includes a Memory Protocol section. Agents MUST:

1. **Load context** before starting (project `.memory/STATE.md` + global `session/`)
2. **Persist context** after each significant action (both layers)
3. **Compress** when session count exceeds thresholds
4. **Extract knowledge** from significant outcomes
5. **Never skip writes** — even on failure, record what happened and why
