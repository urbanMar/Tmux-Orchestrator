#!/bin/bash
# Manual Service Control - Direct server management
# Bypasses agents for manual intervention

PROJECT_NAME="${1}"
SERVICE="${2}"  # backend, frontend, services
ACTION="${3}"   # start, stop, restart, status

if [ -z "$PROJECT_NAME" ] || [ -z "$SERVICE" ] || [ -z "$ACTION" ]; then
    echo "Usage: $0 <project-name> <service> <action>"
    echo ""
    echo "Services: backend, frontend, services"
    echo "Actions: start, stop, restart, status"
    echo ""
    echo "Examples:"
    echo "  $0 my-project backend start"
    echo "  $0 my-project frontend restart"
    echo "  $0 my-project backend status"
    exit 1
fi

# Determine window number
WINDOW=""
case "$SERVICE" in
    backend)
        WINDOW="1"
        SERVICE_NAME="Backend Server"
        START_CMD="npm run dev"
        ;;
    frontend)
        WINDOW="3"
        SERVICE_NAME="Frontend Server"
        START_CMD="npm run dev"
        ;;
    services)
        WINDOW="5"
        SERVICE_NAME="Services (DB/Redis)"
        START_CMD="echo 'Define your service start command here'"
        ;;
    *)
        echo "❌ Unknown service: $SERVICE"
        echo "Valid options: backend, frontend, services"
        exit 1
        ;;
esac

# Check session exists
if ! tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    echo "❌ Session '$PROJECT_NAME' not found"
    exit 1
fi

TARGET="$PROJECT_NAME:$WINDOW"

echo "=========================================="
echo "Manual Service Control"
echo "=========================================="
echo "Service: $SERVICE_NAME"
echo "Window: $TARGET"
echo "Action: $ACTION"
echo ""

case "$ACTION" in
    start)
        echo "🚀 Starting $SERVICE_NAME..."
        # First check if already running
        content=$(tmux capture-pane -t "$TARGET" -p)
        if echo "$content" | grep -q -E "listening|started|ready|running"; then
            echo "⚠️  Service appears to already be running!"
            echo "Recent output:"
            echo "$content" | tail -5
            echo ""
            read -p "Force restart? (yes/no): " response
            if [ "$response" != "yes" ]; then
                echo "❌ Aborted"
                exit 0
            fi
            echo "Stopping existing process..."
            tmux send-keys -t "$TARGET" C-c
            sleep 2
        fi

        echo "Sending start command: $START_CMD"
        tmux send-keys -t "$TARGET" "$START_CMD" Enter
        sleep 3

        echo ""
        echo "✅ Start command sent"
        echo "Checking status..."
        sleep 2
        tmux capture-pane -t "$TARGET" -p | tail -10
        echo ""
        echo "Tip: View live output with: tmux select-window -t $TARGET"
        ;;

    stop)
        echo "🛑 Stopping $SERVICE_NAME..."
        tmux send-keys -t "$TARGET" C-c
        sleep 1
        echo "✅ Stop signal sent"
        echo ""
        echo "Checking status..."
        sleep 1
        tmux capture-pane -t "$TARGET" -p | tail -5
        ;;

    restart)
        echo "🔄 Restarting $SERVICE_NAME..."
        echo "Step 1: Stopping..."
        tmux send-keys -t "$TARGET" C-c
        sleep 2

        echo "Step 2: Starting..."
        tmux send-keys -t "$TARGET" "$START_CMD" Enter
        sleep 3

        echo "✅ Restart complete"
        echo ""
        echo "Current status:"
        tmux capture-pane -t "$TARGET" -p | tail -10
        ;;

    status)
        echo "📊 Current Status:"
        echo ""
        content=$(tmux capture-pane -t "$TARGET" -p)

        if echo "$content" | grep -q -E "listening|started|ready|running"; then
            echo "Status: ✅ RUNNING"
        elif echo "$content" | grep -q -iE "error|failed|crash"; then
            echo "Status: ❌ ERROR"
        else
            echo "Status: ⭕ STOPPED"
        fi

        echo ""
        echo "Recent output (last 15 lines):"
        echo "----------------------------------------"
        echo "$content" | tail -15
        echo "----------------------------------------"
        ;;

    *)
        echo "❌ Unknown action: $ACTION"
        echo "Valid options: start, stop, restart, status"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Action Complete"
echo "=========================================="
echo ""
echo "To view live output:"
echo "  tmux select-window -t $TARGET"
echo ""
echo "To attach to session:"
echo "  tmux attach -t $PROJECT_NAME"
echo ""
