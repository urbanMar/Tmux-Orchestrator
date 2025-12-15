#!/bin/bash
# Service Orchestration Setup - Persistent Server Management
# Solves: Claude Code random server restarts, lack of transparency, no manual control

set -e  # Exit on error

# Configuration
PROJECT_NAME="${1:-my-project}"
PROJECT_PATH="${2:-$(pwd)}"
ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Service Orchestration Setup"
echo "=========================================="
echo "Project: $PROJECT_NAME"
echo "Path: $PROJECT_PATH"
echo "Orchestrator: $ORCHESTRATOR_DIR"
echo ""

# Check if session already exists
if tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    echo "⚠️  Session '$PROJECT_NAME' already exists!"
    read -p "Kill existing session and recreate? (yes/no): " response
    if [ "$response" = "yes" ]; then
        tmux kill-session -t "$PROJECT_NAME"
        echo "✅ Killed existing session"
    else
        echo "❌ Aborted"
        exit 1
    fi
fi

echo "Creating tmux session structure..."
echo ""

# Create main session with orchestrator
tmux new-session -d -s "$PROJECT_NAME" -n "Orchestrator" -c "$ORCHESTRATOR_DIR"

# Window 0: Orchestrator (main control)
echo "✅ Window 0: Orchestrator (main control)"

# Window 1: Backend Server (dedicated window for server process)
tmux new-window -t "$PROJECT_NAME:1" -n "Backend-Server" -c "$PROJECT_PATH"
echo "✅ Window 1: Backend-Server (persistent server)"

# Window 2: Backend Agent (Claude manages backend)
tmux new-window -t "$PROJECT_NAME:2" -n "Backend-Agent" -c "$PROJECT_PATH"
echo "✅ Window 2: Backend-Agent (Claude backend management)"

# Window 3: Frontend Server (dedicated window for server process)
tmux new-window -t "$PROJECT_NAME:3" -n "Frontend-Server" -c "$PROJECT_PATH"
echo "✅ Window 3: Frontend-Server (persistent server)"

# Window 4: Frontend Agent (Claude manages frontend)
tmux new-window -t "$PROJECT_NAME:4" -n "Frontend-Agent" -c "$PROJECT_PATH"
echo "✅ Window 4: Frontend-Agent (Claude frontend management)"

# Window 5: Database/Services (if needed)
tmux new-window -t "$PROJECT_NAME:5" -n "Services" -c "$PROJECT_PATH"
echo "✅ Window 5: Services (database, redis, etc.)"

# Window 6: Monitoring Dashboard
tmux new-window -t "$PROJECT_NAME:6" -n "Monitor" -c "$ORCHESTRATOR_DIR"
echo "✅ Window 6: Monitor (status dashboard)"

# Window 7: Shell (manual commands)
tmux new-window -t "$PROJECT_NAME:7" -n "Shell" -c "$PROJECT_PATH"
echo "✅ Window 7: Shell (manual control)"

echo ""
echo "=========================================="
echo "Session Structure Created"
echo "=========================================="
echo ""
echo "Window Layout:"
echo "  0: Orchestrator     - Main orchestrator (you can start Claude here)"
echo "  1: Backend-Server   - Backend server runs HERE (visible, persistent)"
echo "  2: Backend-Agent    - Claude agent managing backend"
echo "  3: Frontend-Server  - Frontend server runs HERE (visible, persistent)"
echo "  4: Frontend-Agent   - Claude agent managing frontend"
echo "  5: Services         - Database, Redis, etc."
echo "  6: Monitor          - Status monitoring"
echo "  7: Shell            - Manual control"
echo ""
echo "Next Steps:"
echo "  1. Attach to session: tmux attach -t $PROJECT_NAME"
echo "  2. Navigate to window 0 (Orchestrator)"
echo "  3. Start Claude orchestrator: claude"
echo "  4. Or manually brief agents using: $ORCHESTRATOR_DIR/brief-service-agents.sh $PROJECT_NAME"
echo ""
echo "To view session: tmux attach -t $PROJECT_NAME"
echo "To detach: Press Ctrl+B then D"
echo "To switch windows: Ctrl+B then window number (0-7)"
echo ""
echo "✅ Setup complete!"
