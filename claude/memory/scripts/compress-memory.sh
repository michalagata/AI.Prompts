#!/usr/bin/env bash
set -Eeuo pipefail

# Memory Compression Script
# Compresses session files older than DAYS_THRESHOLD into weekly archive summaries.
# Supports both global (~/.claude/memory) and project-level (.memory/) directories.
#
# Usage:
#   compress-memory.sh [memory-dir]
#   compress-memory.sh                          # defaults to ~/.claude/memory
#   compress-memory.sh /path/to/repo/.memory    # project-level

MEMORY_DIR="${1:-${MEMORY_DIR:-$HOME/.claude/memory}}"
SESSION_DIR="$MEMORY_DIR/session"
ARCHIVE_DIR="$MEMORY_DIR/archive"
DAYS_THRESHOLD="${DAYS_THRESHOLD:-7}"

# Ensure directories exist
mkdir -p "$SESSION_DIR" "$ARCHIVE_DIR"

if [ ! -d "$SESSION_DIR" ]; then
    echo "[$(date -Iseconds)] No session directory at $SESSION_DIR — nothing to compress."
    exit 0
fi

FILE_COUNT=$(find "$SESSION_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
if [ "$FILE_COUNT" -eq 0 ]; then
    echo "[$(date -Iseconds)] No session files found — nothing to compress."
    exit 0
fi

echo "[$(date -Iseconds)] Starting memory compression in $MEMORY_DIR..."
echo "  Session files found: $FILE_COUNT"
echo "  Threshold: $DAYS_THRESHOLD days"

COMPRESSED=0

# Find files older than threshold
find "$SESSION_DIR" -name "*.md" -type f -mtime +"$DAYS_THRESHOLD" | sort | while read -r file; do
    basename_noext=$(basename "$file" .md)
    # Extract agent name: everything before the date pattern YYYY-MM-DD
    agent_name=$(echo "$basename_noext" | sed 's/-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}.*//')
    # Extract date from filename
    file_date=$(echo "$basename_noext" | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}' | head -1)

    if [ -z "$file_date" ] || [ -z "$agent_name" ]; then
        echo "  SKIP (no date/agent in name): $file"
        continue
    fi

    # Calculate ISO week (macOS vs Linux)
    week=$(date -j -f "%Y-%m-%d" "$file_date" "+%Y-W%V" 2>/dev/null || date -d "$file_date" "+%Y-W%V" 2>/dev/null || echo "unknown")

    archive_file="$ARCHIVE_DIR/${agent_name}-week-${week}.md"

    # Create archive header if new file
    if [ ! -f "$archive_file" ]; then
        cat > "$archive_file" <<HEADER
---
agent: ${agent_name}
week: ${week}
compressed: $(date -Iseconds)
type: archive
---

# Archive: ${agent_name} -- Week ${week}

Compressed from session files on $(date -Iseconds).

---

HEADER
    fi

    # Append session content
    echo "## $(basename "$file")" >> "$archive_file"
    echo "" >> "$archive_file"
    cat "$file" >> "$archive_file"
    echo "" >> "$archive_file"
    echo "---" >> "$archive_file"
    echo "" >> "$archive_file"

    rm "$file"
    echo "  Archived: $(basename "$file") -> $(basename "$archive_file")"
    COMPRESSED=$((COMPRESSED + 1))
done

# Update archive index in MEMORY.md if it exists
MEMORY_INDEX="$MEMORY_DIR/MEMORY.md"
if [ -f "$MEMORY_INDEX" ]; then
    # Count current archives
    ARCHIVE_COUNT=$(find "$ARCHIVE_DIR" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "  Archive files total: $ARCHIVE_COUNT"
fi

echo "[$(date -Iseconds)] Compression complete."
