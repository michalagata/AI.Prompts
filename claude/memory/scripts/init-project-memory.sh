#!/usr/bin/env bash
set -Eeuo pipefail

# Project Memory Initialization Script
# Creates the .memory/ directory structure in a project with template files.
# Safe to run multiple times — never overwrites existing content.
#
# Usage:
#   init-project-memory.sh [project-dir]
#   init-project-memory.sh                    # defaults to current directory
#   init-project-memory.sh /path/to/repo

PROJECT_DIR="${1:-.}"
MEMORY_DIR="$PROJECT_DIR/.memory"

echo "Initializing project memory in: $MEMORY_DIR"

# Create directory structure
mkdir -p "$MEMORY_DIR/session"
mkdir -p "$MEMORY_DIR/archive"
mkdir -p "$MEMORY_DIR/knowledge"

# STATE.md — only create if missing
if [ ! -f "$MEMORY_DIR/STATE.md" ]; then
    cat > "$MEMORY_DIR/STATE.md" <<'EOF'
# Current State

## Active Task
(none)

## Status
Idle

## Last Action
Project memory initialized.

## Next Step
Awaiting first task.

## Files Modified This Session
(none)

## Open Decisions / Blockers
(none)

## Git State
(not checked yet)
EOF
    echo "  Created STATE.md"
else
    echo "  STATE.md already exists — skipped"
fi

# CONTEXT.md — only create if missing
if [ ! -f "$MEMORY_DIR/CONTEXT.md" ]; then
    cat > "$MEMORY_DIR/CONTEXT.md" <<'EOF'
# Project Context

## Tech Stack
(to be filled on first task)

## Architecture
(to be filled on first task)

## Key Decisions
(none yet)

## Integration Points
(none documented)

## Known Constraints
(none documented)
EOF
    echo "  Created CONTEXT.md"
else
    echo "  CONTEXT.md already exists — skipped"
fi

# HISTORY.md — only create if missing
if [ ! -f "$MEMORY_DIR/HISTORY.md" ]; then
    cat > "$MEMORY_DIR/HISTORY.md" <<EOF
# Action History

## [$(date '+%Y-%m-%d %H:%M')] Step 0: Initialization
- Action: Project memory initialized
- Files: .memory/ directory created
- Result: Ready for first task
EOF
    echo "  Created HISTORY.md"
else
    echo "  HISTORY.md already exists — skipped"
fi

# Add .memory/ to .gitignore if not already there
GITIGNORE="$PROJECT_DIR/.gitignore"
if [ -f "$GITIGNORE" ]; then
    if ! grep -qF '.memory/' "$GITIGNORE" 2>/dev/null; then
        echo "" >> "$GITIGNORE"
        echo "# Claude Code project memory (local, not committed)" >> "$GITIGNORE"
        echo ".memory/" >> "$GITIGNORE"
        echo "  Added .memory/ to .gitignore"
    fi
else
    echo "  Note: No .gitignore found — consider adding .memory/ to it"
fi

echo ""
echo "Project memory ready at: $MEMORY_DIR"
echo "  STATE.md   — overwritten each step (current task/status)"
echo "  CONTEXT.md — updated on decisions (architecture/tech stack)"
echo "  HISTORY.md — append-only action log"
echo "  session/   — per-agent session files"
echo "  archive/   — compressed old sessions"
echo "  knowledge/ — permanent domain knowledge"
