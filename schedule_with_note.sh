#!/bin/bash
# Dynamic scheduler with note for next check
# Usage: ./schedule_with_note.sh <minutes> "<note>" [target_window]

MINUTES=${1:-3}
NOTE=${2:-"Standard check-in"}
TARGET=${3:-"tmux-orc:0"}

# Get script directory for portable path handling
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
NOTE_FILE="$SCRIPT_DIR/next_check_note.txt"

# Create a note file for the next check
echo "=== Next Check Note ($(date)) ===" > "$NOTE_FILE"
echo "Scheduled for: $MINUTES minutes" >> "$NOTE_FILE"
echo "" >> "$NOTE_FILE"
echo "$NOTE" >> "$NOTE_FILE"

echo "Scheduling check in $MINUTES minutes with note: $NOTE"

# Calculate the exact time when the check will run
CURRENT_TIME=$(date +"%H:%M:%S")
RUN_TIME=$(date -v +${MINUTES}M +"%H:%M:%S" 2>/dev/null || date -d "+${MINUTES} minutes" +"%H:%M:%S" 2>/dev/null)

# Use bash's built-in arithmetic instead of bc
SECONDS=$((MINUTES * 60))

# SECURITY FIX: Pass variables as arguments to prevent command injection
# Variables are now passed as positional parameters ($1, $2, $3) to the inner bash
COMMAND_TO_RUN="Time for orchestrator check! cat \"$NOTE_FILE\" && python3 claude_control.py status detailed"

nohup bash -c '
    sleep "$1"
    tmux send-keys -t "$2" "$3"
    sleep 1
    tmux send-keys -t "$2" Enter
' bash "$SECONDS" "$TARGET" "$COMMAND_TO_RUN" > /dev/null 2>&1 &

# Get the PID of the background process
SCHEDULE_PID=$!

echo "Scheduled successfully - process detached (PID: $SCHEDULE_PID)"
echo "SCHEDULED TO RUN AT: $RUN_TIME (in $MINUTES minutes from $CURRENT_TIME)"