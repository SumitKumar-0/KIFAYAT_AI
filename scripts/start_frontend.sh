#!/usr/bin/env bash
# ==============================================================================
# KIFAYAT AI — LOCAL FRONTEND STARTUP SCRIPT
# Serves the static frontend at http://localhost:5500
# ==============================================================================

set -e

# Navigate to project root (one level up from scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
cd "${PROJECT_ROOT}"

FRONTEND_DIR="${PROJECT_ROOT}/frontend"

echo "============================================================"
echo "  KIFAYAT AI — Frontend (Python Static HTTP Server)"
echo "  URL: http://localhost:5500"
echo "  Directory: ${FRONTEND_DIR}"
echo "  Backend expected at: http://127.0.0.1:8000"
echo "============================================================"

# --- Verify frontend directory exists ---
if [ ! -d "${FRONTEND_DIR}" ]; then
    echo ""
    echo "[ERROR] Frontend directory not found: ${FRONTEND_DIR}"
    echo "        Make sure you are running this from the project root."
    exit 1
fi

# --- Verify index.html exists ---
if [ ! -f "${FRONTEND_DIR}/index.html" ]; then
    echo ""
    echo "[ERROR] frontend/index.html not found."
    exit 1
fi

# --- Verify Python is available ---
if ! python3 --version &>/dev/null; then
    echo ""
    echo "[ERROR] python3 is not installed or not in PATH."
    echo "        Install Python 3.11+ from https://www.python.org/downloads/"
    exit 1
fi

echo ""
echo "[INFO] Starting static file server on http://localhost:5500 ..."
echo "[INFO] Press Ctrl+C to stop."
echo ""

python3 -m http.server 5500 --directory "${FRONTEND_DIR}"
