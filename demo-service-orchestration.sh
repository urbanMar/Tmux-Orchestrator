#!/bin/bash
# Demo Script - Test Service Orchestration
# This creates a demo session to verify everything works

DEMO_PROJECT="demo-orchestration"
ORCHESTRATOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Service Orchestration Demo"
echo "=========================================="
echo ""
echo "This demo will:"
echo "  1. Create a demo tmux session"
echo "  2. Set up all windows"
echo "  3. Show you the structure"
echo "  4. Provide commands to interact with it"
echo ""
read -p "Continue? (yes/no): " response

if [ "$response" != "yes" ]; then
    echo "Demo cancelled"
    exit 0
fi

echo ""
echo "Step 1: Cleaning up any existing demo session..."
if tmux has-session -t "$DEMO_PROJECT" 2>/dev/null; then
    tmux kill-session -t "$DEMO_PROJECT"
    echo "✅ Removed existing session"
fi

echo ""
echo "Step 2: Creating orchestration structure..."
"$ORCHESTRATOR_DIR/setup-service-orchestration.sh" "$DEMO_PROJECT" "$ORCHESTRATOR_DIR"

echo ""
echo "Step 3: Simulating simple servers (without Claude agents)..."
echo ""

# Put simple status messages in server windows for demo
tmux send-keys -t "$DEMO_PROJECT:1" "echo '=== BACKEND SERVER WINDOW ===' && echo 'Server would run here' && echo 'Example: npm run dev' && echo 'Status: ⭕ Not started yet'" Enter

tmux send-keys -t "$DEMO_PROJECT:3" "echo '=== FRONTEND SERVER WINDOW ===' && echo 'Server would run here' && echo 'Example: npm run dev' && echo 'Status: ⭕ Not started yet'" Enter

tmux send-keys -t "$DEMO_PROJECT:5" "echo '=== SERVICES WINDOW ===' && echo 'Database, Redis, etc. would run here' && echo 'Status: ⭕ Not started yet'" Enter

# Put helpful info in agent windows
tmux send-keys -t "$DEMO_PROJECT:2" "echo '=== BACKEND AGENT WINDOW ===' && echo 'Claude would run here: claude' && echo 'This agent manages window 1 (Backend-Server)' && echo '' && echo 'Agent commands:' && echo '  Start server: tmux send-keys -t $DEMO_PROJECT:1 \"npm run dev\" Enter' && echo '  Stop server:  tmux send-keys -t $DEMO_PROJECT:1 C-c' && echo '  Check status: tmux capture-pane -t $DEMO_PROJECT:1 -p | tail -10'" Enter

tmux send-keys -t "$DEMO_PROJECT:4" "echo '=== FRONTEND AGENT WINDOW ===' && echo 'Claude would run here: claude' && echo 'This agent manages window 3 (Frontend-Server)' && echo '' && echo 'Agent commands:' && echo '  Start server: tmux send-keys -t $DEMO_PROJECT:3 \"npm run dev\" Enter' && echo '  Stop server:  tmux send-keys -t $DEMO_PROJECT:3 C-c' && echo '  Check status: tmux capture-pane -t $DEMO_PROJECT:3 -p | tail -10'" Enter

# Put monitoring info in monitor window
tmux send-keys -t "$DEMO_PROJECT:6" "echo '=== MONITORING DASHBOARD ===' && echo '' && echo 'Run this command to see service status:' && echo '  $ORCHESTRATOR_DIR/monitor-services.sh $DEMO_PROJECT' && echo '' && echo 'Manual control commands:' && echo '  $ORCHESTRATOR_DIR/control-service.sh $DEMO_PROJECT backend start' && echo '  $ORCHESTRATOR_DIR/control-service.sh $DEMO_PROJECT frontend restart'" Enter

# Put welcome message in shell window
tmux send-keys -t "$DEMO_PROJECT:7" "echo '=== MANUAL CONTROL SHELL ===' && echo '' && echo 'This is your manual control window.' && echo '' && echo 'Try these commands:' && echo '  ../monitor-services.sh $DEMO_PROJECT' && echo '  ../control-service.sh $DEMO_PROJECT backend status' && echo '' && echo 'Navigate windows:' && echo '  Ctrl+B then 0-7 (switch to window 0-7)' && echo '  Ctrl+B then D (detach, keeps running)'" Enter

# Put orchestrator info in window 0
tmux send-keys -t "$DEMO_PROJECT:0" "echo '========================================' && echo 'ORCHESTRATOR DEMO - Service Management' && echo '========================================' && echo '' && echo 'Welcome! This demo shows how to manage services with transparency.' && echo '' && echo '📋 WINDOW LAYOUT:' && echo '  Window 0 (here): Orchestrator control' && echo '  Window 1: Backend Server (visible server process)' && echo '  Window 2: Backend Agent (Claude managing backend)' && echo '  Window 3: Frontend Server (visible server process)' && echo '  Window 4: Frontend Agent (Claude managing frontend)' && echo '  Window 5: Services (database, redis, etc.)' && echo '  Window 6: Monitoring dashboard' && echo '  Window 7: Manual shell' && echo '' && echo '🎯 KEY CONCEPT:' && echo '  Servers run in windows 1, 3, 5 (visible)' && echo '  Agents run in windows 2, 4 (manage those servers)' && echo '  YOU have full transparency and control' && echo '' && echo '📌 NAVIGATE:' && echo '  Press: Ctrl+B then window number (0-7)' && echo '  Example: Ctrl+B then 1 = View backend server' && echo '' && echo '📊 MONITORING:' && echo '  In another terminal, run:' && echo '    cd $ORCHESTRATOR_DIR' && echo '    ./monitor-services.sh $DEMO_PROJECT' && echo '' && echo '🎮 MANUAL CONTROL:' && echo '  In another terminal, run:' && echo '    ./control-service.sh $DEMO_PROJECT backend start' && echo '    ./control-service.sh $DEMO_PROJECT frontend status' && echo '' && echo 'Press Ctrl+B then D to detach (keeps session running)' && echo '========================================'" Enter

sleep 2

echo ""
echo "=========================================="
echo "✅ Demo Setup Complete!"
echo "=========================================="
echo ""
echo "🎉 Session '$DEMO_PROJECT' is ready!"
echo ""
echo "📺 To see it in action:"
echo "   tmux attach -t $DEMO_PROJECT"
echo ""
echo "🎮 Navigate between windows:"
echo "   Ctrl+B then 0-7 (window number)"
echo "   Ctrl+B then D (detach)"
echo ""
echo "📊 Monitor from another terminal:"
echo "   cd $ORCHESTRATOR_DIR"
echo "   ./monitor-services.sh $DEMO_PROJECT"
echo ""
echo "🔧 Manual control from another terminal:"
echo "   ./control-service.sh $DEMO_PROJECT backend status"
echo ""
echo "🧹 Clean up when done:"
echo "   tmux kill-session -t $DEMO_PROJECT"
echo ""
echo "=========================================="
echo "Ready to explore!"
echo "=========================================="
echo ""
echo "Attaching to demo session in 3 seconds..."
echo "(Press Ctrl+C to cancel)"
sleep 3

tmux attach -t "$DEMO_PROJECT"
