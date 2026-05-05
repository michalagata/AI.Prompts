# Memory Index

> This file is automatically loaded into conversation context.
> Each entry is a pointer to a memory file. Keep entries under 150 chars.

## Knowledge
- (no entries yet — use `extract-knowledge.sh <topic>` to add)

## Recent Sessions
- (auto-populated by agents writing to `session/`)

## Archives
- (auto-populated by `compress-memory.sh` from old sessions)

## Scripts
- `scripts/compress-memory.sh` — Archive sessions >7 days into weekly summaries
- `scripts/search-memory.sh` — Search all layers: index, session, knowledge, archive
- `scripts/extract-knowledge.sh` — Save permanent domain knowledge
- `scripts/retrieve-archive.sh` — Smart indexed retrieval from archive
- `scripts/init-project-memory.sh` — Create .memory/ in a project directory
- `scripts/memory-status.sh` — Status overview of all memory layers
