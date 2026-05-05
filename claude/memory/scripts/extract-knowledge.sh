#!/usr/bin/env bash
set -Eeuo pipefail

# Knowledge Extraction Script
# Saves permanent domain knowledge to knowledge/{topic}.md.
# Supports both global (~/.claude/memory) and project-level (.memory/) directories.
#
# Usage:
#   extract-knowledge.sh <topic> [content]
#   extract-knowledge.sh <topic>               # reads from stdin
#   extract-knowledge.sh --dir <path> <topic> [content]
#   extract-knowledge.sh --list                # list all knowledge files
#   extract-knowledge.sh --list --dir <path>

MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/memory}"
TOPIC=""
CONTENT=""
LIST_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dir)   MEMORY_DIR="$2"; shift 2;;
        --list)  LIST_MODE=true; shift;;
        --help|-h)
            echo "Usage: extract-knowledge.sh [--dir <path>] [--list] <topic> [content]"
            echo ""
            echo "Options:"
            echo "  --dir <path>   Memory directory (default: ~/.claude/memory)"
            echo "  --list         List all knowledge files"
            echo ""
            echo "If content is empty, reads from stdin."
            exit 0
            ;;
        *)
            if [ -z "$TOPIC" ]; then
                TOPIC="$1"
            elif [ -z "$CONTENT" ]; then
                CONTENT="$1"
            fi
            shift
            ;;
    esac
done

KNOWLEDGE_DIR="$MEMORY_DIR/knowledge"
mkdir -p "$KNOWLEDGE_DIR"

# List mode
if [ "$LIST_MODE" = true ]; then
    echo "=== Knowledge Base: $KNOWLEDGE_DIR ==="
    if [ -d "$KNOWLEDGE_DIR" ]; then
        find "$KNOWLEDGE_DIR" -name "*.md" -type f | sort | while read -r f; do
            name=$(basename "$f" .md)
            first_line=$(head -5 "$f" | grep -v "^#" | grep -v "^---" | grep -v "^$" | head -1)
            printf "  %-30s %s\n" "$name" "$first_line"
        done
    fi
    COUNT=$(find "$KNOWLEDGE_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  Total: $COUNT entries"
    exit 0
fi

if [ -z "$TOPIC" ]; then
    echo "Usage: extract-knowledge.sh [--dir <path>] <topic> [content]"
    echo "  If content is empty, reads from stdin"
    exit 1
fi

FILE="$KNOWLEDGE_DIR/${TOPIC}.md"

if [ -f "$FILE" ]; then
    echo "" >> "$FILE"
    echo "---" >> "$FILE"
    echo "" >> "$FILE"
    echo "## Update: $(date -Iseconds)" >> "$FILE"
    echo "" >> "$FILE"
    echo "  (Appending to existing knowledge file)"
else
    cat > "$FILE" <<HEADER
---
topic: ${TOPIC}
created: $(date -Iseconds)
type: knowledge
---

# Knowledge: ${TOPIC}

HEADER
    echo "  (Created new knowledge file)"
fi

if [ -n "$CONTENT" ]; then
    echo "$CONTENT" >> "$FILE"
else
    cat >> "$FILE"
fi

echo "Knowledge saved to: $FILE"
