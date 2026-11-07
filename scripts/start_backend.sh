#!/usr/bin/env bash
# ==============================================================================
# KIFAYAT AI — LOCAL BACKEND STARTUP SCRIPT
# Starts FastAPI + Uvicorn on http://127.0.0.1:8000
# ==============================================================================

set -e

# Navigate to project root (one level up from scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

echo "============================================================"
echo "  KIFAYAT AI — Backend (FastAPI + Uvicorn)"
echo "  URL: http://127.0.0.1:8000"
echo "  API Docs: http://127.0.0.1:8000/docs"
echo "  Project root: ${PROJECT_ROOT}"
echo "============================================================"

# --- Activate virtual environment if it exists ---
if [ -d "${PROJECT_ROOT}/.venv" ]; then
    echo "[INFO] Activating .venv virtual environment..."
    source "${PROJECT_ROOT}/.venv/bin/activate"
elif [ -d "${PROJECT_ROOT}/venv" ]; then
    echo "[INFO] Activating venv virtual environment..."
    source "${PROJECT_ROOT}/venv/bin/activate"
else
    echo "[WARN] No .venv or venv directory found. Using system Python."
    echo "       Run: python3 -m venv .venv && source .venv/bin/activate && pip install -r requirements.txt"
fi

# --- Verify required dependencies ---
if ! python3 -c "import fastapi, uvicorn" 2>/dev/null; then
    echo ""
    echo "[ERROR] Required Python packages are missing."
    echo "        Please install them first:"
    echo "          pip install -r requirements.txt"
    echo ""
    exit 1
fi

# --- Ensure .env exists ---
if [ ! -f "${PROJECT_ROOT}/.env" ]; then
    echo "[INFO] .env not found, copying from .env.example..."
    cp "${PROJECT_ROOT}/.env.example" "${PROJECT_ROOT}/.env"
    echo "[INFO] Created .env from .env.example. Edit it to configure your environment."
fi

# --- Ensure database directory exists ---
mkdir -p "${PROJECT_ROOT}/backend"

echo ""
echo "[INFO] Starting Uvicorn on http://127.0.0.1:8000 (reload mode)..."
echo "[INFO] Press Ctrl+C to stop."
echo ""

python3 -m uvicorn backend.app.main:app \
    --reload \
    --host 127.0.0.1 \
    --port 8000
