#!/bin/bash
# Service Monitor - Check status of all services
# Provides transparency into what's running

PROJECT_NAME="${1:-my-project}"

if ! tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    echo "❌ Session '$PROJECT_NAME' not found"
    exit 1
fi

clear

echo "=========================================="
echo "SERVICE MONITORING DASHBOARD"
echo "Project: $PROJECT_NAME"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="
echo ""

# Function to check if a service is running in a window
check_service() {
    local window=$1
    local service_name=$2
    local search_pattern=$3

    echo "[$service_name]"
    echo "Window: $PROJECT_NAME:$window"

    # Capture window content
    content=$(tmux capture-pane -t "$PROJECT_NAME:$window" -p 2>/dev/null || echo "Window not found")

    # Check for common server patterns
    if echo "$content" | grep -q -E "$search_pattern"; then
        echo "Status: ✅ RUNNING"
        # Try to extract port information
        port=$(echo "$content" | grep -oE "port [0-9]+" | tail -1)
        if [ -n "$port" ]; then
            echo "Info: Server listening on $port"
        fi
        port=$(echo "$content" | grep -oE "localhost:[0-9]+" | tail -1)
        if [ -n "$port" ]; then
            echo "Info: Available at $port"
        fi
    elif echo "$content" | grep -q -iE "error|failed|crash"; then
        echo "Status: ❌ ERROR"
        echo "Last error:"
        echo "$content" | grep -iE "error|failed|crash" | tail -3
    else
        echo "Status: ⭕ STOPPED"
    fi

    # Show last few lines of output
    echo "Recent output:"
    echo "$content" | tail -3 | sed 's/^/  | /'
    echo ""
}

echo "🔍 BACKEND SERVER (Window 1)"
echo "----------------------------------------"
check_service "1" "Backend" "listening|started|ready|running|server"

echo "🔍 FRONTEND SERVER (Window 3)"
echo "----------------------------------------"
check_service "3" "Frontend" "listening|started|ready|running|compiled|local:"

echo "🔍 SERVICES (Window 5)"
echo "----------------------------------------"
check_service "5" "Database/Services" "listening|started|ready|running"

echo "=========================================="
echo "AGENT STATUS"
echo "=========================================="
echo ""

# Check if agents are running Claude
for window in 2 4; do
    agent_name=""
    [ $window -eq 2 ] && agent_name="Backend Agent"
    [ $window -eq 4 ] && agent_name="Frontend Agent"

    content=$(tmux capture-pane -t "$PROJECT_NAME:$window" -p 2>/dev/null || echo "")

    echo "[$agent_name - Window $window]"
    if echo "$content" | grep -q -E "claude|Claude|AGENT READY"; then
        echo "Status: ✅ ACTIVE"
        echo "Last message:"
        echo "$content" | tail -2 | sed 's/^/  | /'
    else
        echo "Status: ⭕ NOT STARTED"
    fi
    echo ""
done

echo "=========================================="
echo "QUICK ACTIONS"
echo "=========================================="
echo ""
echo "View specific window:"
echo "  tmux select-window -t $PROJECT_NAME:1  # Backend Server"
echo "  tmux select-window -t $PROJECT_NAME:3  # Frontend Server"
echo "  tmux select-window -t $PROJECT_NAME:2  # Backend Agent"
echo "  tmux select-window -t $PROJECT_NAME:4  # Frontend Agent"
echo ""
echo "Manual server control:"
echo "  ./control-service.sh $PROJECT_NAME backend start|stop|restart"
echo "  ./control-service.sh $PROJECT_NAME frontend start|stop|restart"
echo ""
echo "Refresh this monitor:"
echo "  ./monitor-services.sh $PROJECT_NAME"
echo ""
echo "Attach to session:"
echo "  tmux attach -t $PROJECT_NAME"
echo ""
