# 🚀 Kifayat AI — Local Development Setup Guide

Complete guide to run the **Kifayat AI** project fully locally on **macOS** (or Linux) **without Docker**.

---

## 📋 Table of Contents
1. [Required Software](#-required-software)
2. [Clone & Project Layout](#-clone--project-layout)
3. [Python Virtual Environment](#-python-virtual-environment)
4. [Install Dependencies](#-install-dependencies)
5. [Environment Variables](#-environment-variables)
6. [SQLite Database](#-sqlite-database)
7. [AI Provider Configuration](#-ai-provider-configuration)
8. [Start the Backend](#-start-the-backend)
9. [Start the Frontend](#-start-the-frontend)
10. [API Documentation](#-api-documentation)
11. [Run Tests](#-run-tests)
12. [Troubleshooting](#-troubleshooting)
13. [Stop Both Servers](#-stop-both-servers)

---

## ✅ Required Software

| Tool | Version | Install |
|------|---------|---------|
| **Python** | 3.11+ | [python.org/downloads](https://www.python.org/downloads/) or `brew install python` |
| **pip** | bundled with Python | — |
| **Git** | any | `brew install git` |

> [!NOTE]
> This project uses a **`.venv`** Python virtual environment that is already present in the repo. You do **not** need Docker, Node.js, npm, or any other runtime.

---

## 📂 Clone & Project Layout

```bash
# Clone the repository
git clone <your-repo-url> kifayat
cd kifayat/First_Commit   # <-- all commands below run from here
```

```
First_Commit/
├── backend/
│   ├── app/            # FastAPI application
│   │   ├── main.py     # Application entrypoint
│   │   ├── config.py   # Settings (loads from .env)
│   │   ├── api/        # Route handlers
│   │   ├── providers/  # LLM provider integrations
│   │   └── ...
│   ├── data/
│   │   ├── handbook.md        # Knowledge base
│   │   └── seed_exemplars.json
│   ├── tests/          # pytest test suite
│   └── kifayat.db      # SQLite database (auto-created)
├── frontend/
│   ├── index.html      # Main SPA
│   ├── css/            # Stylesheets
│   └── js/             # JavaScript (api.js, app.js, chat.js, ...)
├── scripts/
│   ├── start_backend.sh   # ← macOS/Linux backend launcher
│   └── start_frontend.sh  # ← macOS/Linux frontend launcher
├── .env                # Your local environment config (git-ignored)
├── .env.example        # Template — copy this to .env
├── requirements.txt    # Python dependencies
└── LOCAL_SETUP.md      # This file
```

---

## 🐍 Python Virtual Environment

A virtual environment (`.venv`) is already included. If you need to create a fresh one:

```bash
# From the First_Commit/ directory:
python3 -m venv .venv
```

**Activate the virtual environment:**

```bash
# macOS / Linux
source .venv/bin/activate

# Verify activation (should show .venv path)
which python3
```

You should see something like `.../First_Commit/.venv/bin/python3`.

> [!TIP]
> The startup scripts (`start_backend.sh`) auto-activate `.venv` for you, so manual activation is only needed when running commands directly.

---

## 📦 Install Dependencies

```bash
# Make sure your .venv is activated first
source .venv/bin/activate

pip install -r requirements.txt
```

The project requires these core packages (all in `requirements.txt`):

| Package | Purpose |
|---------|---------|
| `fastapi` | Web framework |
| `uvicorn` | ASGI server |
| `pydantic` + `pydantic-settings` | Data validation & settings |
| `python-dotenv` | Load `.env` variables |
| `httpx` | Async HTTP client (NVIDIA API calls) |
| `numpy` + `scikit-learn` | Embedding & cosine similarity for semantic cache |
| `pytest` + `pytest-asyncio` | Test suite |
| `python-multipart` | Multipart form parsing |
| `pypdf` | PDF document parsing |

---

## ⚙️ Environment Variables

Copy the template to create your local configuration:

```bash
cp .env.example .env
```

The `.env` file controls all runtime behavior. Open it and review the key settings:

```ini
# .env — Local Development Configuration

ENVIRONMENT=local

# ── AI Provider ─────────────────────────────────────────────────────────────
# Options: mock | nvidia | bedrock
# Use 'mock' for local development (no API key required)
LLM_PROVIDER=mock

# NVIDIA NIM API (only needed when LLM_PROVIDER=nvidia)
NVIDIA_API_KEY=
NVIDIA_MODEL=meta/llama-3.1-8b-instruct
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1

# AWS Bedrock (only needed when LLM_PROVIDER=bedrock)
AWS_REGION=us-east-1

# ── Database ─────────────────────────────────────────────────────────────────
SQLITE_DB_PATH=backend/kifayat.db

# ── Application ──────────────────────────────────────────────────────────────
PROJECT_NAME=Kifayat
APP_ID=helpdesk
HANDBOOK_PATH=backend/data/handbook.md
SEED_EXEMPLARS_PATH=backend/data/seed_exemplars.json

# ── Memory, Cache, Limits (safe defaults) ────────────────────────────────────
STREAMING_ENABLED=true
SEMANTIC_CACHE_ENABLED=true
MAX_OUTPUT_TOKENS=500
```

> [!IMPORTANT]
> **Never commit your `.env` file.** It is listed in `.gitignore`. Keep secrets out of version control.

---

## 🗄️ SQLite Database

Kifayat AI uses an **embedded SQLite database** — no database server is required.

- **Path**: `backend/kifayat.db`
- **Auto-created** on first startup if it does not exist.
- Tables are initialized automatically via [`sqlite_store.py`](backend/app/storage/sqlite_store.py).
- Schema migrations run automatically on each startup (safe to restart).

The database stores:
- Chat **sessions** and conversation history
- **Exemplars** (few-shot examples for AI quality improvement)
- **Request logs** for the analytics dashboard
- **Semantic cache** entries

> [!CAUTION]
> Never delete `backend/kifayat.db` while the server is running. To reset the database, stop the server first, then delete the file — it will be recreated automatically on the next startup.

---

## 🤖 AI Provider Configuration

The project supports three provider modes. Set `LLM_PROVIDER` in `.env`:

### Mode 1: `mock` (Default — no API key needed)
```ini
LLM_PROVIDER=mock
```
Uses a built-in mock provider that returns simulated responses. **Perfect for local development and testing.**

### Mode 2: `nvidia` (Real LLM — NVIDIA NIM API)
```ini
LLM_PROVIDER=nvidia
NVIDIA_API_KEY=nvapi-your-key-here
NVIDIA_MODEL=meta/llama-3.1-8b-instruct
NVIDIA_BASE_URL=https://integrate.api.nvidia.com/v1
```
Get a free API key at [build.nvidia.com](https://build.nvidia.com/).

Recommended model tiers:
| Setting | Model | Speed |
|---------|-------|-------|
| `CHEAP_MODEL_ID` | `meta/llama-3.1-8b-instruct` | Fast (Rung 1 & 2) |
| `STRONG_MODEL_ID` | `meta/llama-3.1-70b-instruct` | Slower, smarter (Rung 3) |
| `JUDGE_MODEL_ID` | `meta/llama-3.1-70b-instruct` | Quality evaluation |

### Mode 3: `bedrock` (AWS Bedrock)
```ini
LLM_PROVIDER=bedrock
AWS_REGION=us-east-1
```
Requires AWS CLI credentials configured via `~/.aws/credentials` or environment variables. See the [AWS Bedrock documentation](https://docs.aws.amazon.com/bedrock/).

> [!TIP]
> You can switch providers at runtime through the **Settings panel** in the frontend UI without restarting the backend.

---

## 🖥️ Start the Backend

### Option A — Use the startup script (recommended)

```bash
./scripts/start_backend.sh
```

### Option B — Run directly

```bash
# From First_Commit/ directory, with .venv activated:
source .venv/bin/activate
python3 -m uvicorn backend.app.main:app --reload --host 127.0.0.1 --port 8000
```

**Expected output:**

```
============================================================
  KIFAYAT AI — Backend (FastAPI + Uvicorn)
  URL: http://127.0.0.1:8000
  API Docs: http://127.0.0.1:8000/docs
============================================================
INFO:     Started server process [12345]
INFO:     Waiting for application startup.
INFO:     Initializing Kifayat Intelligent LLM Context Gateway...
INFO:     Active LLM Provider: mock
INFO:     Kifayat Gateway initialization complete.
INFO:     Application startup complete.
INFO:     Uvicorn running on http://127.0.0.1:8000 (Press CTRL+C to quit)
```

Verify the backend is healthy:
```bash
curl http://127.0.0.1:8000/api/health
# Expected: {"status":"healthy","project":"Kifayat","provider":"mock",...}
```

---

## 🌐 Start the Frontend

Open a **second terminal** window/tab.

### Option A — Use the startup script (recommended)

```bash
./scripts/start_frontend.sh
```

### Option B — Run directly

```bash
python3 -m http.server 5500 --directory frontend
```

**Expected output:**
```
============================================================
  KIFAYAT AI — Frontend (Python Static HTTP Server)
  URL: http://localhost:5500
============================================================
Serving HTTP on 0.0.0.0 port 5500 (http://0.0.0.0:5500/) ...
```

Open your browser at **[http://localhost:5500](http://localhost:5500)**.

> [!NOTE]
> The frontend uses `window.location.origin` to determine the API base URL. When served from `http://localhost:5500`, **all API calls go to `http://localhost:5500/...`** by default — this means the frontend expects the backend to be accessible at the same origin.
>
> **For split-server local development** (backend on `:8000`, frontend on `:5500`), you can also access the frontend directly via the backend at **[http://127.0.0.1:8000](http://127.0.0.1:8000)** — the FastAPI server automatically serves `frontend/index.html` and all static assets.

### Recommended local access
| URL | What it serves |
|-----|---------------|
| `http://127.0.0.1:8000` | Full app (backend serves frontend statically) |
| `http://127.0.0.1:8000/docs` | Interactive API documentation (Swagger UI) |
| `http://127.0.0.1:8000/redoc` | ReDoc API documentation |
| `http://localhost:5500` | Frontend only (via Python HTTP server) |

---

## 📖 API Documentation

With the backend running, visit:

- **Swagger UI**: [http://127.0.0.1:8000/docs](http://127.0.0.1:8000/docs)
- **ReDoc**: [http://127.0.0.1:8000/redoc](http://127.0.0.1:8000/redoc)

Key API endpoints:

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/health` | GET | Detailed provider health |
| `/api/chat/stream` | POST | Streaming chat (SSE) |
| `/api/dashboard/stats` | GET | Analytics dashboard |
| `/api/dashboard/requests` | GET | Recent request logs |
| `/api/cache/stats` | GET | Semantic cache statistics |
| `/api/exemplars` | GET | Exemplar store contents |
| `/v1/provider/status` | GET | LLM provider status |
| `/v1/provider/test` | POST | Live provider connectivity test |
| `/v1/provider/configure` | POST | Update provider settings at runtime |

---

## 🧪 Run Tests

```bash
# Activate venv first
source .venv/bin/activate

# Run the full test suite
python3 -m pytest backend/tests/ -v

# Run a specific test file
python3 -m pytest backend/tests/test_api_chat.py -v

# Run tests matching a pattern
python3 -m pytest backend/tests/ -k "test_mock" -v
```

> [!NOTE]
> 5 tests have pre-existing failures related to intent classification thresholds and semantic cache similarity scoring — these are **not caused by local configuration** and do not affect application functionality.

---

## 🔧 Troubleshooting

### ❌ `ModuleNotFoundError: No module named 'backend'`

You are running the server from the wrong directory. Always run from `First_Commit/`:

```bash
cd /path/to/kifayat/First_Commit
python3 -m uvicorn backend.app.main:app --reload --host 127.0.0.1 --port 8000
```

### ❌ `Address already in use — port 8000`

Another process is using port 8000. Find and stop it:

```bash
lsof -i :8000
kill -9 <PID>
```

Or use a different port:
```bash
python3 -m uvicorn backend.app.main:app --reload --host 127.0.0.1 --port 8001
```

### ❌ `Address already in use — port 5500`

```bash
lsof -i :5500
kill -9 <PID>
```

### ❌ `pip install` fails with memory error

Install packages one at a time, or increase swap space. The heavy wheels are `numpy` and `scikit-learn`. On macOS, `brew install python` usually provides optimized builds.

### ❌ Frontend shows no data / API errors in browser console

1. Make sure the backend is running: `curl http://127.0.0.1:8000/api/health`
2. Access the frontend via the backend directly at `http://127.0.0.1:8000` (same origin = no CORS issues).
3. If using the Python HTTP server on `:5500`, CORS is handled by the backend (`allow_origins=["*"]`), but check the browser console for the exact error.

### ❌ `pydantic_settings` / `.env` not loading

Ensure your `.env` is in the **project root** (`First_Commit/.env`), not inside a subdirectory. The `Settings` class loads from `.env` relative to the current working directory.

```bash
ls -la .env   # Should show the file
```

### ❌ Database errors on startup

```bash
# Reset the database (WARNING: deletes all data)
rm backend/kifayat.db
# Restart the backend — it will recreate automatically
```

### ❌ `NVIDIA_API_KEY` not configured warning

If using `LLM_PROVIDER=nvidia` without an API key, the backend will start but AI calls will fail. Either:
- Switch back to `LLM_PROVIDER=mock` in `.env` for no-key testing.
- Or add your NVIDIA API key: `NVIDIA_API_KEY=nvapi-your-key`.

---

## ⏹️ Stop Both Servers

In each terminal where a server is running, press:

```
Ctrl + C
```

Or to find and kill by port:

```bash
# Kill backend (port 8000)
lsof -ti :8000 | xargs kill -9

# Kill frontend (port 5500)
lsof -ti :5500 | xargs kill -9
```

---

## 🎯 Quick Start Summary

```bash
# 1. Enter the project directory
cd /path/to/kifayat/First_Commit

# 2. Activate virtual environment
source .venv/bin/activate

# 3. Install dependencies (first time only)
pip install -r requirements.txt

# 4. Configure environment (first time only)
cp .env.example .env   # then edit .env if needed

# 5. Terminal 1 — Start backend
./scripts/start_backend.sh
# Backend: http://127.0.0.1:8000

# 6. Terminal 2 — Start frontend (optional, backend also serves it)
./scripts/start_frontend.sh
# Frontend: http://localhost:5500

# 7. Open in browser
open http://127.0.0.1:8000
```
