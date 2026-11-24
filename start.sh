#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Wayword needs Docker. Install Docker Desktop, then run ./start.sh again." >&2
  exit 1
fi

saved_key="$(sed -n 's/^OPENROUTER_API_KEY=//p' .env 2>/dev/null || true)"

if [[ -n "$saved_key" ]]; then
  echo "Using the OpenRouter key saved in .env."
else
  read -r -s -p "OpenRouter API key (press Enter to run with the stub provider): " entered_key
  echo
  if [[ -n "$entered_key" ]]; then
    umask 077
    printf 'OPENROUTER_API_KEY=%s\n' "$entered_key" > .env
    echo "Saved the key to .env, which git ignores."
  else
    echo "No key given: corrections come from the stub provider."
  fi
fi

echo "Building and starting Wayword."
docker compose up --build --detach --wait
echo
echo "Wayword is running at http://localhost:5173"
echo "Backend logs: docker compose logs --follow backend"
echo "Stop it:      docker compose down"
