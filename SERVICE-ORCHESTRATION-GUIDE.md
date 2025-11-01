# Service Orchestration Guide

## Problem Being Solved

**Claude Code** (and other AI coding assistants) have a critical problem with server management:

❌ **Random server restarts** - Servers start, stop, restart unpredictably
❌ **No transparency** - Can't see what version is running
❌ **No manual control** - Can't manually restart or inspect servers
❌ **Testing impossible** - Server might restart during your test
❌ **Background processes** - Servers hidden in background, no visibility

## The Solution: Persistent Service Agents

Instead of Claude Code randomly managing servers, we create **dedicated tmux windows** for each service with **dedicated Claude agents** that manage them transparently.

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Main Orchestrator                         │
│                   (Window 0: Control)                        │
└─────────────────────┬───────────────────────────────────────┘
                      │
        ┌─────────────┼─────────────┬───────────────┐
        │             │             │               │
┌───────▼──────┐  ┌──▼──────────┐  ┌▼──────────┐   │
│ Backend      │  │ Frontend    │  │ Services  │   │
│ Server       │  │ Server      │  │ (DB etc)  │   │
│ Window 1     │  │ Window 3    │  │ Window 5  │   │
│              │  │             │  │           │   │
│ [VISIBLE]    │  │ [VISIBLE]   │  │ [VISIBLE] │   │
└──────┬───────┘  └──────┬──────┘  └─────┬─────┘   │
       │                 │                │         │
┌──────▼───────┐  ┌──────▼──────┐  ┌──────▼─────┐  │
│ Backend      │  │ Frontend    │  │ Monitor    │  │
│ Agent        │  │ Agent       │  │ Dashboard  │  │
│ Window 2     │  │ Window 4    │  │ Window 6   │  │
│              │  │             │  │            │  │
│ [Claude AI]  │  │ [Claude AI] │  │ [Status]   │  │
└──────────────┘  └─────────────┘  └────────────┘  │
                                                    │
                                          ┌─────────▼───┐
                                          │ Manual      │
                                          │ Shell       │
                                          │ Window 7    │
                                          │             │
                                          │ [Your CLI]  │
                                          └─────────────┘
```

### Key Principles

1. **ONE SERVICE = ONE WINDOW** - Each server runs in its own dedicated tmux window
2. **AGENTS DON'T RUN SERVERS** - Agents send commands to server windows, never run in background
3. **FULL VISIBILITY** - You can switch to any window and see exactly what's running
4. **MANUAL OVERRIDE** - You can always take manual control
5. **PERSISTENT PROCESSES** - Servers keep running until explicitly stopped

## Quick Start

### 1. Create the Orchestration Setup

```bash
cd /path/to/Tmux-Orchestrator

# Setup for your project
./setup-service-orchestration.sh my-project /path/to/your/project

# This creates:
# - Window 0: Orchestrator (main control)
# - Window 1: Backend-Server (visible server process)
# - Window 2: Backend-Agent (Claude managing backend)
# - Window 3: Frontend-Server (visible server process)
# - Window 4: Frontend-Agent (Claude managing frontend)
# - Window 5: Services (database, redis, etc.)
# - Window 6: Monitor (status dashboard)
# - Window 7: Shell (manual control)
```

### 2. Brief the Service Agents

```bash
# Start and brief all agents
./brief-service-agents.sh my-project

# This will:
# - Start Claude in agent windows (2, 4)
# - Send detailed instructions to each agent
# - Agents will ask permission before starting servers
```

### 3. Monitor Services

```bash
# View status of all services
./monitor-services.sh my-project

# Output shows:
# ✅ RUNNING / ⭕ STOPPED / ❌ ERROR
# Port information
# Recent log output
# Agent status
```

### 4. Manual Control (When Needed)

```bash
# Start a service manually
./control-service.sh my-project backend start

# Stop a service
./control-service.sh my-project frontend stop

# Restart a service
./control-service.sh my-project backend restart

# Check status
./control-service.sh my-project frontend status
```

## Detailed Workflow

### Starting Your Development Session

```bash
# 1. Create the orchestration
./setup-service-orchestration.sh my-app ~/projects/my-app

# 2. Brief the agents
./brief-service-agents.sh my-app

# 3. Attach to see the setup
tmux attach -t my-app

# 4. Navigate between windows
# Ctrl+B then 0-7 to switch windows
# Ctrl+B then D to detach
```

### Daily Development

```bash
# Check what's running
./monitor-services.sh my-app

# If something needs restarting
./control-service.sh my-app backend restart

# View live server output
tmux select-window -t my-app:1  # Backend
tmux select-window -t my-app:3  # Frontend
```

### Agent Rules (How Agents Are Instructed)

Each service agent receives these **critical rules**:

#### ✅ DO:
- Manage the server in your designated window (1 for backend, 3 for frontend)
- Check server status before making changes
- Ask user before restarting during testing
- Report server state clearly
- Only restart when: user requests, critical error, or necessary code changes

#### ❌ DON'T:
- Start server in your own window (agents are in window 2 and 4)
- Use background processes (`&`, `nohup`)
- Randomly restart servers
- Assume server state - always check
- Restart during active user testing without asking

### Server Control Commands (For Agents)

Agents use these tmux commands to control servers:

```bash
# START server in window 1 (backend)
tmux send-keys -t my-app:1 'npm run dev' Enter

# STOP server
tmux send-keys -t my-app:1 C-c

# CHECK status
tmux capture-pane -t my-app:1 -p | tail -20

# RESTART (stop, wait, start)
tmux send-keys -t my-app:1 C-c
# wait 2 seconds
tmux send-keys -t my-app:1 'npm run dev' Enter
```

## Transparency Benefits

### Before (Claude Code random behavior):
```
You: "Let me test this feature"
[Claude randomly restarts server]
You: "Wait, what version is running?"
[Server in background, can't see]
You: "How do I restart it?"
[No way to manually control]
```

### After (Service Orchestration):
```
You: ./monitor-services.sh my-app
[Shows: Backend ✅ RUNNING on port 8000]
[Shows: Frontend ✅ RUNNING on port 3000]

You: tmux select-window -t my-app:1
[See live backend server output]

You: ./control-service.sh my-app backend restart
[Manual restart, visible output]
```

## Window Reference

| Window | Name | Purpose | Who Uses It |
|--------|------|---------|-------------|
| 0 | Orchestrator | Main control, coordination | You or main Claude |
| 1 | Backend-Server | **Backend server runs HERE** | Backend Agent controls |
| 2 | Backend-Agent | Claude managing backend | Backend Agent (Claude) |
| 3 | Frontend-Server | **Frontend server runs HERE** | Frontend Agent controls |
| 4 | Frontend-Agent | Claude managing frontend | Frontend Agent (Claude) |
| 5 | Services | Database, Redis, etc. | You or dedicated agent |
| 6 | Monitor | Status dashboard | Monitoring tools |
| 7 | Shell | Manual commands | You (manual override) |

## Common Scenarios

### Scenario 1: Server Won't Start

```bash
# Check what's happening
./monitor-services.sh my-app
# Shows: Backend ❌ ERROR

# View detailed output
tmux select-window -t my-app:1

# Try manual restart
./control-service.sh my-app backend restart

# Check agent's view
tmux select-window -t my-app:2
```

### Scenario 2: Need to Test Specific Version

```bash
# Stop auto-restarts by talking to agent
tmux select-window -t my-app:2
# Tell agent: "Do not restart backend until I say so"

# Manual control for testing
./control-service.sh my-app backend stop
# make code changes
./control-service.sh my-app backend start
# test your feature
```

### Scenario 3: Agent Keeps Restarting Server

```bash
# View agent window
tmux select-window -t my-app:2

# Check what agent sees
tmux capture-pane -t my-app:2 -p | tail -50

# Re-brief agent with stricter rules
# Or take manual control:
./control-service.sh my-app backend stop
# Tell agent to stay hands-off
```

### Scenario 4: Adding a New Service

```bash
# Create new window for service
tmux new-window -t my-app:8 -n "API-Gateway" -c "/path/to/project"

# Create agent window
tmux new-window -t my-app:9 -n "Gateway-Agent" -c "/path/to/project"

# Start Claude in agent window
tmux send-keys -t my-app:9 "claude" Enter

# Brief the agent (adapt from brief-service-agents.sh)
```

## Customization

### Custom Start Commands

Edit `control-service.sh` to customize start commands:

```bash
case "$SERVICE" in
    backend)
        START_CMD="python -m uvicorn app.main:app --reload"
        ;;
    frontend)
        START_CMD="npm run dev -- --port 3000"
        ;;
    api)
        START_CMD="go run main.go"
        ;;
esac
```

### Additional Services

Add more services in `setup-service-orchestration.sh`:

```bash
# Window 8: API Gateway
tmux new-window -t "$PROJECT_NAME:8" -n "API-Gateway" -c "$PROJECT_PATH"

# Window 9: API Gateway Agent
tmux new-window -t "$PROJECT_NAME:9" -n "Gateway-Agent" -c "$PROJECT_PATH"
```

## Troubleshooting

### "Session already exists"

```bash
# Kill existing session
tmux kill-session -t my-app

# Or use the automatic option
./setup-service-orchestration.sh my-app /path
# Answer 'yes' when prompted
```

### "Agent not responding"

```bash
# Check if Claude is running
tmux capture-pane -t my-app:2 -p | grep -i claude

# Restart agent
tmux send-keys -t my-app:2 C-c
sleep 2
tmux send-keys -t my-app:2 "claude" Enter
sleep 5

# Re-brief
./brief-service-agents.sh my-app
```

### "Can't see server output"

```bash
# Always view the SERVER window, not the agent window
tmux select-window -t my-app:1  # Backend server
tmux select-window -t my-app:3  # Frontend server

# Not these (these are agent windows):
# my-app:2 (Backend agent)
# my-app:4 (Frontend agent)
```

## Best Practices

1. **Always use monitoring first**: `./monitor-services.sh` before making changes
2. **Keep servers running**: Only restart when necessary
3. **Manual testing sessions**: Tell agents to hold off during manual testing
4. **One service per window**: Don't run multiple services in one window
5. **Check before starting**: Always verify nothing is running before start
6. **Use meaningful session names**: Name sessions after your project
7. **Detach, don't close**: Use `Ctrl+B D` to detach, keeps everything running

## Integration with Existing Workflow

### With Claude Code

```bash
# Instead of letting Claude Code manage servers randomly:
# 1. Set up orchestration first
./setup-service-orchestration.sh my-app ~/projects/my-app
./brief-service-agents.sh my-app

# 2. Tell Claude Code to only modify code, not manage servers
# 3. Agents handle server management, Claude Code handles development

# 4. When Claude Code says "starting server..."
# Reply: "No, use the dedicated agent in window 2 for backend or window 4 for frontend"
```

### With Your IDE

- Keep your IDE open as normal
- Use tmux orchestration for **server management only**
- Edit code in IDE, servers run in tmux
- View logs in tmux windows

### With Git Workflow

```bash
# When switching branches
./control-service.sh my-app backend stop
git checkout feature-branch
./control-service.sh my-app backend start

# Agents can also monitor git changes
# Tell them: "Restart backend when I change branches"
```

## Advanced: Multiple Projects

```bash
# Project 1
./setup-service-orchestration.sh project-a ~/code/project-a
./brief-service-agents.sh project-a

# Project 2
./setup-service-orchestration.sh project-b ~/code/project-b
./brief-service-agents.sh project-b

# Switch between projects
tmux attach -t project-a
tmux attach -t project-b

# View all sessions
tmux list-sessions
```

## Scripts Reference

| Script | Purpose | Usage |
|--------|---------|-------|
| `setup-service-orchestration.sh` | Create tmux window structure | `./setup-service-orchestration.sh <name> <path>` |
| `brief-service-agents.sh` | Start and instruct Claude agents | `./brief-service-agents.sh <name>` |
| `monitor-services.sh` | Check status of all services | `./monitor-services.sh <name>` |
| `control-service.sh` | Manual service control | `./control-service.sh <name> <service> <action>` |
| `send-claude-message.sh` | Send message to an agent | `./send-claude-message.sh <window> "<message>"` |

## Summary

✅ **Persistent servers** - Run until you stop them
✅ **Full transparency** - See exactly what's running
✅ **Manual control** - Override agents anytime
✅ **No random restarts** - Agents ask before restarting
✅ **Visible processes** - Every server in its own window
✅ **Testing friendly** - Servers stay stable during tests
✅ **Version clarity** - Always know what code is running

**The result**: You control the servers, agents assist you, not the other way around.
