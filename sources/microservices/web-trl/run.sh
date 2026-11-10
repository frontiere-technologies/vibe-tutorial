#!/usr/bin/env bash
# Build the TRL web app and serve it on its own, with no back end and no
# Chrome device needed: ./run.sh [port]   (default 8080)
set -euo pipefail
cd "$(dirname "$0")"
PORT="${1:-8080}"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter is not installed: see https://docs.flutter.dev/get-started/install" >&2
  exit 1
fi

# Fail fast, before a build, if the port is taken (e.g. a previous run still serving).
if ! python3 -c "import socket, sys; s = socket.socket(); s.bind(('127.0.0.1', int(sys.argv[1])))" "${PORT}" 2>/dev/null; then
  echo "Port ${PORT} is already in use: stop the other server, or run ./run.sh <another port>" >&2
  exit 1
fi

flutter pub get
flutter build web --release
echo
echo "TRL Readiness — http://localhost:${PORT}   (Ctrl+C to stop)"
exec python3 -m http.server "${PORT}" --bind 127.0.0.1 --directory build/web
