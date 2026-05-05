#!/usr/bin/env bash
set -Eeuo pipefail

# Memory Search Script
# Searches across all memory layers: index -> session -> knowledge -> archive.
# Supports both global (~/.claude/memory) and project-level (.memory/) directories.
#
# Usage:
#   search-memory.sh <query> [--agent <name>] [--since <date>] [--dir <memory-dir>]
#   search-memory.sh "LLMRouter"
#   search-memory.sh "deployment" --agent orchestrator
#   search-memory.sh "migration" --dir /path/to/repo/.memory

QUERY=""
AGENT_FILTER=""
SINCE_FILTER=""
MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/memory}"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent) AGENT_FILTER="$2"; shift 2;;
        --since) SINCE_FILTER="$2"; shift 2;;
        --dir)   MEMORY_DIR="$2"; shift 2;;
        --help|-h)
            echo "Usage: search-memory.sh <query> [--agent <name>] [--since <date>] [--dir <memory-dir>]"
            echo ""
            echo "Options:"
            echo "  --agent <name>   Filter by agent name (e.g., orchestrator, dotnet-developer)"
            echo "  --since <date>   Filter files modified since date (YYYY-MM-DD)"
            echo "  --dir <path>     Memory directory (default: ~/.claude/memory)"
            exit 0
            ;;
        *)
            if [ -z "$QUERY" ]; then
                QUERY="$1"
            fi
            shift
            ;;
    esac
done

if [ -z "$QUERY" ]; then
    echo "Usage: search-memory.sh <query> [--agent <name>] [--since <date>] [--dir <memory-dir>]"
    exit 1
fi

FOUND=0

echo "=== Memory Search: \"$QUERY\" ==="
echo "  Directory: $MEMORY_DIR"
[ -n "$AGENT_FILTER" ] && echo "  Agent: $AGENT_FILTER"
[ -n "$SINCE_FILTER" ] && echo "  Since: $SINCE_FILTER"
echo ""

# 1. Search MEMORY.md index
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
    echo "--- Index (MEMORY.md) ---"
    matches=$(grep -in "$QUERY" "$MEMORY_DIR/MEMORY.md" 2>/dev/null || true)
    if [ -n "$matches" ]; then
        echo "$matches"
        FOUND=$((FOUND + 1))
    else
        echo "(no matches)"
    fi
    echo ""
fi

# 2. Search session (recent)
if [ -d "$MEMORY_DIR/session" ]; then
    echo "--- Session (Recent) ---"
    find_args=("$MEMORY_DIR/session" -name "*.md" -type f)
    [ -n "$AGENT_FILTER" ] && find_args=("$MEMORY_DIR/session" -name "${AGENT_FILTER}*.md" -type f)
    if [ -n "$SINCE_FILTER" ]; then
        find_args+=(-newer "$SINCE_FILTER")
    fi

    find "${find_args[@]}" 2>/dev/null | sort -r | while read -r f; do
        result=$(grep -in "$QUERY" "$f" 2>/dev/null | head -3 || true)
        if [ -n "$result" ]; then
            echo "  $(basename "$f")"
            echo "$result" | sed 's/^/    /'
            FOUND=$((FOUND + 1))
        fi
    done
    echo ""
fi

# 3. Search knowledge (permanent)
if [ -d "$MEMORY_DIR/knowledge" ]; then
    echo "--- Knowledge (Permanent) ---"
    find "$MEMORY_DIR/knowledge" -name "*.md" -type f 2>/dev/null | sort | while read -r f; do
        result=$(grep -in "$QUERY" "$f" 2>/dev/null | head -3 || true)
        if [ -n "$result" ]; then
            echo "  $(basename "$f")"
            echo "$result" | sed 's/^/    /'
            FOUND=$((FOUND + 1))
        fi
    done
    echo ""
fi

# 4. Search archive (historical)
if [ -d "$MEMORY_DIR/archive" ]; then
    echo "--- Archive (Historical) ---"
    find_args=("$MEMORY_DIR/archive" -name "*.md" -type f)
    [ -n "$AGENT_FILTER" ] && find_args=("$MEMORY_DIR/archive" -name "${AGENT_FILTER}*.md" -type f)

    find "${find_args[@]}" 2>/dev/null | sort -r | while read -r f; do
        result=$(grep -in "$QUERY" "$f" 2>/dev/null | head -5 || true)
        if [ -n "$result" ]; then
            echo "  $(basename "$f")"
            echo "$result" | sed 's/^/    /'
            FOUND=$((FOUND + 1))
        fi
    done
    echo ""
fi

echo "=== Search Complete ==="
