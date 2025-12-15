#!/bin/bash
# Brief Service Agents - Set up persistent server management agents
# Each agent manages ONE service in a dedicated window

set -e

PROJECT_NAME="${1:-my-project}"
ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SEND_MESSAGE="$ORCHESTRATOR_DIR/send-claude-message.sh"

echo "=========================================="
echo "Briefing Service Agents"
echo "=========================================="
echo "Project: $PROJECT_NAME"
echo ""

# Check if session exists
if ! tmux has-session -t "$PROJECT_NAME" 2>/dev/null; then
    echo "❌ Error: Session '$PROJECT_NAME' does not exist"
    echo "Run: ./setup-service-orchestration.sh $PROJECT_NAME [project-path]"
    exit 1
fi

echo "Starting Claude agents in their windows..."
echo ""

# Start Backend Agent (window 2)
echo "Starting Backend Agent (window 2)..."
tmux send-keys -t "$PROJECT_NAME:2" "claude" Enter
sleep 3

# Start Frontend Agent (window 4)
echo "Starting Frontend Agent (window 4)..."
tmux send-keys -t "$PROJECT_NAME:4" "claude" Enter
sleep 3

echo ""
echo "Waiting for Claude agents to initialize..."
sleep 5

echo ""
echo "=========================================="
echo "Briefing Backend Agent..."
echo "=========================================="

$SEND_MESSAGE "$PROJECT_NAME:2" "You are the BACKEND SERVER AGENT.

🎯 YOUR SINGLE RESPONSIBILITY: Manage the backend server that runs in Window 1 (Backend-Server).

🚨 CRITICAL RULES - READ CAREFULLY:

1. SERVER LOCATION:
   - The backend server MUST ONLY run in window 1 (Backend-Server)
   - You operate in window 2 (Backend-Agent)
   - NEVER start the server in your own window
   - NEVER start background processes with & or nohup

2. SERVER CONTROL:
   - To START server: tmux send-keys -t $PROJECT_NAME:1 'npm run dev' Enter
   - To STOP server: tmux send-keys -t $PROJECT_NAME:1 C-c
   - To CHECK server: tmux capture-pane -t $PROJECT_NAME:1 -p | tail -20
   - To RESTART: Stop, wait 2 seconds, then start

3. PERSISTENCE RULES:
   - NEVER randomly restart the server
   - NEVER stop the server unless explicitly asked or there's an error
   - The server should run CONTINUOUSLY for user testing
   - Only restart when: (a) User requests it, (b) Critical error, (c) Code changes require it

4. TRANSPARENCY:
   - Always check server status before making changes
   - Report server state clearly (running/stopped/error)
   - Log what port the server is running on
   - Never assume - always verify by checking window 1

5. VERSION CONTROL:
   - When code changes, check if server restart is needed
   - Ask user before restarting during active testing
   - Coordinate with orchestrator for deployments

YOUR FIRST TASKS:
1. Check if backend server is already running in window 1
2. If not running, ask user if you should start it
3. Once running, monitor for errors but DO NOT restart without reason
4. Report server status to orchestrator

Type 'BACKEND AGENT READY' when you understand these rules."

echo "✅ Backend Agent briefed"
sleep 2

echo ""
echo "=========================================="
echo "Briefing Frontend Agent..."
echo "=========================================="

$SEND_MESSAGE "$PROJECT_NAME:4" "You are the FRONTEND SERVER AGENT.

🎯 YOUR SINGLE RESPONSIBILITY: Manage the frontend server that runs in Window 3 (Frontend-Server).

🚨 CRITICAL RULES - READ CAREFULLY:

1. SERVER LOCATION:
   - The frontend server MUST ONLY run in window 3 (Frontend-Server)
   - You operate in window 4 (Frontend-Agent)
   - NEVER start the server in your own window
   - NEVER start background processes with & or nohup

2. SERVER CONTROL:
   - To START server: tmux send-keys -t $PROJECT_NAME:3 'npm run dev' Enter
   - To STOP server: tmux send-keys -t $PROJECT_NAME:3 C-c
   - To CHECK server: tmux capture-pane -t $PROJECT_NAME:3 -p | tail -20
   - To RESTART: Stop, wait 2 seconds, then start

3. PERSISTENCE RULES:
   - NEVER randomly restart the server
   - NEVER stop the server unless explicitly asked or there's an error
   - The server should run CONTINUOUSLY for user testing
   - Only restart when: (a) User requests it, (b) Critical error, (c) Code changes require it

4. TRANSPARENCY:
   - Always check server status before making changes
   - Report server state clearly (running/stopped/error)
   - Log what port the server is running on (usually 3000)
   - Never assume - always verify by checking window 3

5. VERSION CONTROL:
   - When code changes, check if server restart is needed
   - Ask user before restarting during active testing
   - Coordinate with orchestrator for deployments

YOUR FIRST TASKS:
1. Check if frontend server is already running in window 3
2. If not running, ask user if you should start it
3. Once running, monitor for errors but DO NOT restart without reason
4. Report server status to orchestrator

Type 'FRONTEND AGENT READY' when you understand these rules."

echo "✅ Frontend Agent briefed"

echo ""
echo "=========================================="
echo "Agents Briefed Successfully"
echo "=========================================="
echo ""
echo "Agent Status:"
echo "  Window 2: Backend Agent  - Managing window 1 (Backend-Server)"
echo "  Window 4: Frontend Agent - Managing window 3 (Frontend-Server)"
echo ""
echo "Next Steps:"
echo "  1. Check agent responses: tmux attach -t $PROJECT_NAME"
echo "  2. Navigate to window 2 or 4 to see agent confirmations"
echo "  3. Agents will ask permission before starting servers"
echo "  4. Switch to window 1 or 3 to see actual server output"
echo ""
echo "Quick Commands:"
echo "  View backend server:  tmux select-window -t $PROJECT_NAME:1"
echo "  View frontend server: tmux select-window -t $PROJECT_NAME:3"
echo "  View backend agent:   tmux select-window -t $PROJECT_NAME:2"
echo "  View frontend agent:  tmux select-window -t $PROJECT_NAME:4"
echo ""
echo "✅ Setup complete! Attach to session to interact with agents."
