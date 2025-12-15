# Quick Start: Service Orchestration

Stop Claude Code from randomly restarting your servers. Get full transparency and control.

## The Problem You're Solving

- ❌ Claude Code restarts servers randomly during testing
- ❌ Can't see what version is running
- ❌ Can't manually restart servers
- ❌ Servers hidden in background processes
- ❌ Testing impossible due to instability

## The Solution in 3 Steps

### Step 1: Setup (30 seconds)

```bash
cd /path/to/Tmux-Orchestrator

# Replace 'my-app' with your project name
# Replace '/path/to/your/project' with your project directory
./setup-service-orchestration.sh my-app /path/to/your/project
```

**What this creates**:
```
Window 0: Orchestrator       ← You or main Claude
Window 1: Backend-Server     ← Backend runs HERE (visible)
Window 2: Backend-Agent      ← Claude managing backend
Window 3: Frontend-Server    ← Frontend runs HERE (visible)
Window 4: Frontend-Agent     ← Claude managing frontend
Window 5: Services           ← Database, Redis, etc.
Window 6: Monitor            ← Status dashboard
Window 7: Shell              ← Your manual control
```

### Step 2: Start Agents (1 minute)

```bash
# This starts Claude in agent windows and briefs them
./brief-service-agents.sh my-app
```

**What happens**:
- Claude starts in windows 2 and 4
- Each agent receives strict rules:
  - ✅ Only manage server in designated window
  - ❌ Never run servers in background
  - ❌ Never randomly restart
  - ⚠️  Ask before restarting during testing

### Step 3: Monitor & Control (ongoing)

```bash
# See what's running
./monitor-services.sh my-app

# Output:
# [Backend]
# Status: ✅ RUNNING
# Info: Server listening on port 8000
#
# [Frontend]
# Status: ✅ RUNNING
# Info: Available at localhost:3000

# Manual control when needed
./control-service.sh my-app backend restart
./control-service.sh my-app frontend stop
./control-service.sh my-app backend status
```

## What You Get

### Full Transparency

```bash
# Before: Where is my server??
Claude Code: "Starting server..." [somewhere in background]

# After: Exactly where everything is
tmux select-window -t my-app:1  # View backend server
tmux select-window -t my-app:3  # View frontend server
```

### Manual Control

```bash
# Start/stop/restart anything manually
./control-service.sh my-app backend restart

# Or jump into the window and control directly
tmux select-window -t my-app:1
# Ctrl+C to stop
# Type 'npm run dev' to start
```

### Stable Testing

```bash
# Tell agent to hold off
tmux select-window -t my-app:2
# Message agent: "Do not restart backend until I finish testing"

# Test your feature without interruptions
# Servers stay running until YOU say otherwise
```

## Key Commands

### Setup & Start
```bash
./setup-service-orchestration.sh <project-name> <project-path>
./brief-service-agents.sh <project-name>
```

### Monitoring
```bash
./monitor-services.sh <project-name>
```

### Manual Control
```bash
./control-service.sh <project-name> backend start
./control-service.sh <project-name> frontend stop
./control-service.sh <project-name> backend restart
./control-service.sh <project-name> frontend status
```

### Navigation
```bash
tmux attach -t <project-name>           # Attach to session
tmux select-window -t <project-name>:1  # Jump to window 1
# Ctrl+B then 0-7                       # Switch windows
# Ctrl+B then D                         # Detach (keeps running)
```

## Example Session

```bash
# 1. Setup your project
cd ~/Tmux-Orchestrator
./setup-service-orchestration.sh my-store ~/projects/my-store
./brief-service-agents.sh my-store

# 2. Check status
./monitor-services.sh my-store
# Shows: Backend ⭕ STOPPED, Frontend ⭕ STOPPED

# 3. Attach and see agents asking permission
tmux attach -t my-store
# Navigate to window 2 (Ctrl+B then 2)
# Agent asks: "Should I start backend server?"
# You: "yes"

# 4. Monitor shows servers running
./monitor-services.sh my-store
# Shows: Backend ✅ RUNNING, Frontend ✅ RUNNING

# 5. During testing - servers stay stable!
# No random restarts
# Full visibility
# Manual override available

# 6. When done, detach
# Ctrl+B then D
# Everything keeps running
```

## Customization

### Change Start Commands

Edit `control-service.sh` around line 40:

```bash
case "$SERVICE" in
    backend)
        START_CMD="python manage.py runserver"  # Django
        # or
        START_CMD="uvicorn main:app --reload"   # FastAPI
        ;;
    frontend)
        START_CMD="npm run dev"                 # Default
        # or
        START_CMD="yarn dev"                    # Yarn
        ;;
esac
```

### Add More Services

In `setup-service-orchestration.sh`, add:

```bash
# Window 8: New Service
tmux new-window -t "$PROJECT_NAME:8" -n "My-Service" -c "$PROJECT_PATH"

# Window 9: New Service Agent
tmux new-window -t "$PROJECT_NAME:9" -n "Service-Agent" -c "$PROJECT_PATH"
```

## Troubleshooting

### "Session already exists"
```bash
tmux kill-session -t my-app
# Then run setup again
```

### "Can't see server output"
```bash
# View SERVER windows (1, 3, 5), not AGENT windows (2, 4)
tmux select-window -t my-app:1  # Backend server output
tmux select-window -t my-app:3  # Frontend server output
```

### "Agent not responding"
```bash
# Restart Claude in agent window
tmux send-keys -t my-app:2 C-c
tmux send-keys -t my-app:2 "claude" Enter
# Re-brief
./brief-service-agents.sh my-app
```

## Integration with Claude Code

Instead of letting Claude Code randomly manage servers:

```bash
# 1. Set up orchestration
./setup-service-orchestration.sh my-app ~/projects/my-app
./brief-service-agents.sh my-app

# 2. When using Claude Code for development:
# - Let it modify code ✅
# - Don't let it manage servers ❌
# - Servers managed by dedicated agents in tmux ✅

# 3. Tell Claude Code:
"The backend server is managed by a dedicated agent in tmux window 2.
Do not start, stop, or restart servers yourself.
Focus on code changes only."
```

## What's Different?

| Before (Random) | After (Orchestrated) |
|----------------|---------------------|
| Server restarts anytime | Restart only when needed |
| Hidden background processes | Visible in tmux windows |
| No manual control | Full manual override |
| Unknown version running | Always know what's running |
| Testing breaks constantly | Stable testing environment |
| One Claude does everything | Specialized agents per service |

## Next Steps

1. **Read the full guide**: `SERVICE-ORCHESTRATION-GUIDE.md`
2. **Customize for your stack**: Edit start commands in scripts
3. **Add more services**: Extend window setup for your needs
4. **Share with team**: Everyone can use same orchestration

## Support

- Full documentation: `SERVICE-ORCHESTRATION-GUIDE.md`
- Security info: `SECURITY.md`
- General orchestrator: `CLAUDE.md`

---

**TL;DR**: Three commands to get stable, transparent, controllable servers:
```bash
./setup-service-orchestration.sh my-app ~/projects/my-app
./brief-service-agents.sh my-app
./monitor-services.sh my-app
```

Then enjoy testing without random restarts! 🎉
