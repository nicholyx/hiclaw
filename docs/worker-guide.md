# Worker Guide

Guide for deploying, managing, and troubleshooting HiClaw Worker Agents.

## Overview

Workers are lightweight, stateless containers that:
- Connect to the Manager via Matrix for task communication
- Sync configuration from centralized MinIO storage
- Use AI Gateway for LLM access
- Use mcporter CLI for MCP Server tool calls (GitHub, etc.)

## Installation

Workers are created by the Manager Agent. The Manager handles all infrastructure setup (Matrix account, Higress consumer, config files, etc.) and can either create the Worker container directly or provide a command for manual execution.

### Method 1: Direct Creation (Recommended for Local Development)

If the Manager has access to the host's container runtime socket (default when using `make install`), it can create Worker containers directly:

1. Tell Manager: "Create a new Worker named alice for frontend dev. Create it directly."
2. Manager creates all infrastructure and starts the container automatically
3. No manual steps needed

### Method 2: Docker Run Command (for Remote Deployment)

If the Manager doesn't have socket access, it will reply with a `docker run` command:

1. Tell Manager: "Create a new Worker named alice for frontend dev"
2. Manager creates infrastructure and provides a `docker run` command
3. Copy and run the command on the target host:

```bash
docker run -d --name hiclaw-worker-alice \
  --restart=unless-stopped \
  -e HICLAW_WORKER_NAME=alice \
  -e HICLAW_FS_ENDPOINT=http://<MANAGER_HOST>:9000 \
  -e HICLAW_FS_ACCESS_KEY=<ACCESS_KEY> \
  -e HICLAW_FS_SECRET_KEY=<SECRET_KEY> \
  hiclaw/worker-agent:latest
```

The Manager will provide all the specific values in its reply.

> **Tip**: The `--restart=unless-stopped` flag ensures the Worker container automatically restarts when:
> - The Docker daemon restarts (e.g., after system reboot)
> - The container crashes unexpectedly
> This makes remote Workers behave similarly to locally-created Workers.

### Auto-restart Options for Remote Workers

For remote Workers deployed via Method 2, you have several options to ensure automatic startup:

#### Option 1: Docker Restart Policy (Recommended)

Add `--restart=unless-stopped` to your `docker run` command:

```bash
docker run -d --name hiclaw-worker-alice \
  --restart=unless-stopped \
  ...
```

**Restart policy options:**
| Policy | Behavior |
|--------|----------|
| `--restart=unless-stopped` | Restarts on crash and system reboot, unless manually stopped |
| `--restart=always` | Always restarts, even if manually stopped (restarts on daemon start) |
| `--restart=on-failure[:max-retries]` | Only restarts on non-zero exit code |

#### Option 2: Apply Restart Policy to Existing Container

If you already have a running Worker without a restart policy:

```bash
# Update the restart policy for an existing container
docker update --restart=unless-stopped hiclaw-worker-alice
```

#### Option 3: Systemd Service (Linux)

For production deployments requiring more control, create a systemd service:

```bash
# Create service file
sudo cat > /etc/systemd/system/hiclaw-worker-alice.service << 'EOF'
[Unit]
Description=HiClaw Worker Agent (alice)
After=docker.service
Requires=docker.service

[Service]
Type=simple
ExecStart=/usr/bin/docker start -a hiclaw-worker-alice
ExecStop=/usr/bin/docker stop hiclaw-worker-alice
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable hiclaw-worker-alice
sudo systemctl start hiclaw-worker-alice
```

> **Note**: When using systemd, remove `--restart` from the `docker run` command to avoid conflicts.

## Troubleshooting

### Worker won't start

```bash
# Check container logs
docker logs hiclaw-worker-alice

# Common issues:
# - "openclaw.json not found": Manager hasn't created config yet
# - "mc: command not found": Image build issue
# - Connection refused: Manager container not running or ports not exposed
```

### Worker can't connect to Matrix

```bash
# Verify Matrix server is reachable from Worker (via gateway port)
docker exec hiclaw-worker-alice curl -sf http://matrix-local.hiclaw.io:18080/_matrix/client/versions

# Check Worker's openclaw.json for correct Matrix config
docker exec hiclaw-worker-alice cat /root/hiclaw-fs/agents/alice/openclaw.json | jq '.channels.matrix'
```

### Worker can't access LLM

```bash
# Test AI Gateway access with Worker's key
# Note: these commands run inside the Worker container where domain names resolve to Manager's internal IP
docker exec hiclaw-worker-alice curl -sf \
  -H "Authorization: Bearer $(jq -r '.models.providers."hiclaw-gateway".apiKey' /root/hiclaw-fs/agents/alice/openclaw.json)" \
  http://aigw-local.hiclaw.io:8080/v1/models

# If 401: Check that Worker's consumer key in openclaw.json matches the one in Higress.
# If 403: Worker may not be authorized for the AI route. Ask Manager to add.
```

### Worker can't access MCP (GitHub)

```bash
# Test mcporter connectivity (run inside Worker container)
docker exec hiclaw-worker-alice mcporter --transport http \
  --server-url "http://aigw-local.hiclaw.io:8080/mcp-servers/mcp-github/mcp" \
  --header "Authorization=Bearer <WORKER_KEY>" \
  call list_repos '{"owner": "test"}'

# If 403: Worker not authorized for this MCP Server. Ask Manager.
```

### Resetting a Worker

```bash
# Stop and remove the container
docker stop hiclaw-worker-alice
docker rm hiclaw-worker-alice

# Then ask Manager to recreate the Worker:
# "Please recreate the alice worker container"
# Manager will re-run create-worker.sh which regenerates credentials and restarts the container
```

> Note: Worker config and task data live in MinIO, not in the container. Removing the container does not lose any work.

## Lifecycle Management

The Manager automatically manages Worker container lifecycle:

- **Auto-stop**: Idle Workers (no active finite tasks) are stopped after a configurable timeout to save resources
- **Auto-start**: When a task is assigned to a stopped Worker, the Manager wakes it up before sending the task
- **Auto-recreate on restart**: When the Manager container restarts, it checks all registered Workers and recreates any whose container is missing or whose Manager IP has changed

You can also manually control Workers by asking the Manager:
- "Stop the alice worker"
- "Start the alice worker"
- "What is the status of all workers?"

## Architecture Details

### Startup Sequence

1. Configure `mc` alias for MinIO access
2. Pull Worker config from MinIO (`agents/<name>/`)
3. Copy skill templates
4. Start bidirectional mc mirror sync
5. Configure mcporter with MCP endpoints
6. Launch OpenClaw

### File Sync

- **Local to Remote**: Real-time via `mc mirror --watch`
- **Remote to Local**: Periodic pull every 5 minutes

### Config Hot-Reload

When Manager updates Worker's config in MinIO:
1. MinIO receives the updated file
2. mc mirror pulls it to Worker's local filesystem (next 5-min cycle, or immediately if Manager pushes)
3. OpenClaw detects file change (~300ms) and hot-reloads config

### Environment Variables

| Variable | Description |
|----------|-------------|
| `HICLAW_WORKER_NAME` | Worker identifier (e.g., `alice`) |
| `HICLAW_MATRIX_SERVER` | Matrix Homeserver URL (e.g., `http://matrix-local.hiclaw.io:18080`) |
| `HICLAW_AI_GATEWAY` | AI Gateway URL (e.g., `http://aigw-local.hiclaw.io:18080`) |
| `HICLAW_FS_ENDPOINT` | MinIO endpoint URL (e.g., `http://<MANAGER_HOST>:9000`) |
| `HICLAW_FS_ACCESS_KEY` | MinIO access key (Worker-specific, generated by Manager) |
| `HICLAW_FS_SECRET_KEY` | MinIO secret key (Worker-specific, generated by Manager) |

> All values are generated by the Manager and provided in the `docker run` command or set automatically during direct creation. You should not need to set these manually.

### Syncing Files Manually

Inside the Worker container, run `hiclaw-sync` to pull the latest config and skill files from MinIO:

```bash
docker exec hiclaw-worker-alice hiclaw-sync
```

This is useful after the Manager pushes updated skills or config to MinIO and you want to apply them immediately without waiting for the next sync cycle.
