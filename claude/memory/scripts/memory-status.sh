#!/usr/bin/env bash
set -Eeuo pipefail

# Memory Status Script
# Quick overview of memory state — global and/or project-level.
#
# Usage:
#   memory-status.sh                           # global memory status
#   memory-status.sh --project /path/to/repo   # project memory status
#   memory-status.sh --all /path/to/repo       # both global + project

MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/memory}"
PROJECT_DIR=""
SHOW_GLOBAL=true
SHOW_PROJECT=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --project)
            PROJECT_DIR="$2"
            SHOW_GLOBAL=false
            SHOW_PROJECT=true
            shift 2
            ;;
        --all)
            PROJECT_DIR="$2"
            SHOW_GLOBAL=true
            SHOW_PROJECT=true
            shift 2
            ;;
        --dir)
            MEMORY_DIR="$2"
            shift 2
            ;;
        --help|-h)
            echo "Usage: memory-status.sh [--project <dir>] [--all <dir>] [--dir <memory-dir>]"
            exit 0
            ;;
        *)
            PROJECT_DIR="$1"
            SHOW_PROJECT=true
            shift
            ;;
    esac
done

show_dir_status() {
    local dir="$1"
    local label="$2"

    echo "=== $label ==="
    echo "  Path: $dir"
    echo ""

    if [ ! -d "$dir" ]; then
        echo "  (directory does not exist)"
        echo ""
        return
    fi

    # Session files
    local session_count=0
    if [ -d "$dir/session" ]; then
        session_count=$(find "$dir/session" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Archive files
    local archive_count=0
    if [ -d "$dir/archive" ]; then
        archive_count=$(find "$dir/archive" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi

    # Knowledge files
    local knowledge_count=0
    if [ -d "$dir/knowledge" ]; then
        knowledge_count=$(find "$dir/knowledge" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    fi

    echo "  Session files:   $session_count"
    echo "  Archive files:   $archive_count"
    echo "  Knowledge files: $knowledge_count"

    # Show recent session files
    if [ "$session_count" -gt 0 ]; then
        echo ""
        echo "  Recent sessions (last 5):"
        find "$dir/session" -name "*.md" -type f 2>/dev/null | sort -r | head -5 | while read -r f; do
            local mod_date
            mod_date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$f" 2>/dev/null || stat -c "%y" "$f" 2>/dev/null | cut -d. -f1 || echo "?")
            echo "    $(basename "$f")  ($mod_date)"
        done
    fi

    # Show knowledge topics
    if [ "$knowledge_count" -gt 0 ]; then
        echo ""
        echo "  Knowledge topics:"
        find "$dir/knowledge" -name "*.md" -type f 2>/dev/null | sort | while read -r f; do
            echo "    - $(basename "$f" .md)"
        done
    fi

    # Show STATE.md summary (project-level)
    if [ -f "$dir/STATE.md" ]; then
        echo ""
        echo "  STATE.md:"
        grep -E "^## |^[A-Z]" "$dir/STATE.md" 2>/dev/null | head -5 | sed 's/^/    /'
    fi

    # Check compression needed
    if [ "$session_count" -gt 20 ]; then
        echo ""
        echo "  WARNING: $session_count session files — compression recommended"
        echo "  Run: compress-memory.sh $dir"
    fi

    # Check archive index
    if [ "$archive_count" -gt 0 ] && [ ! -f "$dir/archive/.topic-index.tsv" ]; then
        echo ""
        echo "  NOTE: Archive has no topic index — retrieval will be slower"
        echo "  Run: retrieve-archive.sh --dir $dir --rebuild-index"
    fi

    echo ""
}

# Show global memory status
if [ "$SHOW_GLOBAL" = true ]; then
    show_dir_status "$MEMORY_DIR" "Global Memory (~/.claude/memory)"

    # Also show per-project memories count
    PROJECTS_DIR="$HOME/.claude/projects"
    if [ -d "$PROJECTS_DIR" ]; then
        project_memory_count=$(find "$PROJECTS_DIR" -name "MEMORY.md" -path "*/memory/*" 2>/dev/null | wc -l | tr -d ' ')
        total_memory_files=$(find "$PROJECTS_DIR" -name "*.md" -path "*/memory/*" 2>/dev/null | wc -l | tr -d ' ')
        echo "  Auto Memory (per-project):"
        echo "    Projects with memory: $project_memory_count"
        echo "    Total memory files:   $total_memory_files"
        echo ""
    fi
fi

# Show project memory status
if [ "$SHOW_PROJECT" = true ] && [ -n "$PROJECT_DIR" ]; then
    if [ -d "$PROJECT_DIR/.memory" ]; then
        show_dir_status "$PROJECT_DIR/.memory" "Project Memory ($PROJECT_DIR)"
    else
        echo "=== Project Memory ($PROJECT_DIR) ==="
        echo "  (not initialized — run: init-project-memory.sh $PROJECT_DIR)"
        echo ""
    fi
fi
