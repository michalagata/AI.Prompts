#!/usr/bin/env bash
set -Eeuo pipefail

# Archive Retrieval Script
# Smart retrieval from archived memory — extracts relevant sections without
# brute-force searching the entire archive every time.
#
# Maintains a lightweight topic index (archive/.topic-index.tsv) that maps
# topics/keywords to archive files, enabling O(1) lookups.
#
# Usage:
#   retrieve-archive.sh <topic>                         # retrieve by topic
#   retrieve-archive.sh --agent <name>                  # retrieve all archives for an agent
#   retrieve-archive.sh --week <YYYY-WNN>               # retrieve a specific week
#   retrieve-archive.sh --rebuild-index                  # rebuild the topic index
#   retrieve-archive.sh --dir <path> <topic>             # use custom memory dir
#   retrieve-archive.sh --list                           # list all archive files

MEMORY_DIR="${MEMORY_DIR:-$HOME/.claude/memory}"
TOPIC=""
AGENT=""
WEEK=""
REBUILD_INDEX=false
LIST_MODE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --agent)  AGENT="$2"; shift 2;;
        --week)   WEEK="$2"; shift 2;;
        --dir)    MEMORY_DIR="$2"; shift 2;;
        --rebuild-index) REBUILD_INDEX=true; shift;;
        --list)   LIST_MODE=true; shift;;
        --help|-h)
            echo "Usage: retrieve-archive.sh [options] [topic]"
            echo ""
            echo "Options:"
            echo "  --agent <name>      Retrieve archives for a specific agent"
            echo "  --week <YYYY-WNN>   Retrieve a specific week's archive"
            echo "  --dir <path>        Memory directory (default: ~/.claude/memory)"
            echo "  --rebuild-index     Rebuild the topic index from archive contents"
            echo "  --list              List all archive files with metadata"
            exit 0
            ;;
        *)
            if [ -z "$TOPIC" ]; then
                TOPIC="$1"
            fi
            shift
            ;;
    esac
done

ARCHIVE_DIR="$MEMORY_DIR/archive"
INDEX_FILE="$ARCHIVE_DIR/.topic-index.tsv"

mkdir -p "$ARCHIVE_DIR"

# --- Function: Build/rebuild topic index ---
build_index() {
    echo "Building topic index from archive files..."
    > "$INDEX_FILE"

    find "$ARCHIVE_DIR" -name "*.md" -type f | sort | while read -r f; do
        fname=$(basename "$f" .md)
        # Extract agent and week from filename
        agent=$(echo "$fname" | sed 's/-week-.*//')
        week=$(echo "$fname" | grep -oE 'week-[0-9]{4}-W[0-9]{2}' | sed 's/^week-//' || echo "unknown")

        # Extract key topics: headings (##), decisions, actions, blockers
        topics=$(grep -iE "^##|Action:|Decision:|Blocker:|Context:|topic:|subject:" "$f" 2>/dev/null \
            | sed 's/^## *//' | sed 's/^[A-Za-z]*: *//' \
            | tr '[:upper:]' '[:lower:]' | tr -cs '[:alnum:]-' ' ' \
            | tr ' ' '\n' | sort -u | tr '\n' ',' | sed 's/,$//')

        # Extract file paths mentioned
        files=$(grep -oE '[a-zA-Z0-9_./-]+\.(cs|ts|py|md|json|yaml|yml|sh|csproj|sln)' "$f" 2>/dev/null \
            | sort -u | tr '\n' ',' | sed 's/,$//')

        printf "%s\t%s\t%s\t%s\t%s\n" "$fname" "$agent" "$week" "$topics" "$files" >> "$INDEX_FILE"
    done

    COUNT=$(wc -l < "$INDEX_FILE" | tr -d ' ')
    echo "Index built: $COUNT entries in $INDEX_FILE"
}

# --- Rebuild index if requested or if missing ---
if [ "$REBUILD_INDEX" = true ] || [ ! -f "$INDEX_FILE" ]; then
    build_index
    if [ "$REBUILD_INDEX" = true ]; then
        exit 0
    fi
fi

# --- List mode ---
if [ "$LIST_MODE" = true ]; then
    echo "=== Archive Files: $ARCHIVE_DIR ==="
    if [ -f "$INDEX_FILE" ]; then
        printf "  %-40s %-20s %s\n" "FILE" "AGENT" "WEEK"
        printf "  %-40s %-20s %s\n" "----" "-----" "----"
        while IFS=$'\t' read -r fname agent week topics files; do
            printf "  %-40s %-20s %s\n" "$fname" "$agent" "$week"
        done < "$INDEX_FILE"
    else
        find "$ARCHIVE_DIR" -name "*.md" -type f | sort | while read -r f; do
            echo "  $(basename "$f")"
        done
    fi
    COUNT=$(find "$ARCHIVE_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  Total: $COUNT files"
    exit 0
fi

# --- Retrieve by agent ---
if [ -n "$AGENT" ]; then
    echo "=== Archives for agent: $AGENT ==="
    found=0
    find "$ARCHIVE_DIR" -name "${AGENT}-*.md" -type f | sort -r | while read -r f; do
        echo ""
        echo "--- $(basename "$f") ---"
        cat "$f"
        found=$((found + 1))
    done
    if [ "$found" -eq 0 ] 2>/dev/null; then
        # Check if any files exist (subshell issue with find|while)
        check=$(find "$ARCHIVE_DIR" -name "${AGENT}-*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
        if [ "$check" -eq 0 ]; then
            echo "(no archives found for agent: $AGENT)"
        fi
    fi
    exit 0
fi

# --- Retrieve by week ---
if [ -n "$WEEK" ]; then
    echo "=== Archives for week: $WEEK ==="
    find "$ARCHIVE_DIR" -name "*-week-${WEEK}.md" -type f | sort | while read -r f; do
        echo ""
        echo "--- $(basename "$f") ---"
        cat "$f"
    done
    check=$(find "$ARCHIVE_DIR" -name "*-week-${WEEK}.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$check" -eq 0 ]; then
        echo "(no archives found for week: $WEEK)"
    fi
    exit 0
fi

# --- Retrieve by topic (using index) ---
if [ -n "$TOPIC" ]; then
    TOPIC_LOWER=$(echo "$TOPIC" | tr '[:upper:]' '[:lower:]')
    echo "=== Archive Retrieval: \"$TOPIC\" ==="
    echo ""

    # First: search the index for matching entries
    if [ -f "$INDEX_FILE" ]; then
        MATCHING_FILES=$(grep -i "$TOPIC_LOWER" "$INDEX_FILE" 2>/dev/null | cut -f1 || true)
    else
        MATCHING_FILES=""
    fi

    if [ -z "$MATCHING_FILES" ]; then
        # Fallback: direct grep on archive files (slower but catches everything)
        echo "(index miss — falling back to content search)"
        echo ""
        find "$ARCHIVE_DIR" -name "*.md" -type f | sort -r | while read -r f; do
            result=$(grep -il "$TOPIC" "$f" 2>/dev/null || true)
            if [ -n "$result" ]; then
                echo "--- $(basename "$f") ---"
                # Extract relevant sections (heading + next 10 lines around match)
                grep -B2 -A10 -i "$TOPIC" "$f" 2>/dev/null | head -40
                echo ""
                echo "..."
                echo ""
            fi
        done

        # Rebuild index to include this for next time
        build_index >/dev/null 2>&1 &
    else
        # Use index hits — output full matching files
        for fname in $MATCHING_FILES; do
            archive_path="$ARCHIVE_DIR/${fname}.md"
            if [ -f "$archive_path" ]; then
                echo "--- ${fname} ---"
                # Extract relevant sections around the topic
                grep -B2 -A10 -i "$TOPIC" "$archive_path" 2>/dev/null | head -60
                echo ""
                echo "  (full file: $archive_path)"
                echo ""
            fi
        done
    fi

    echo "=== Retrieval Complete ==="
    exit 0
fi

echo "Usage: retrieve-archive.sh [--agent <name>] [--week <YYYY-WNN>] [--rebuild-index] [--list] [topic]"
exit 1
