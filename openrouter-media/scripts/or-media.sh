#!/usr/bin/env bash
# or-media.sh - entry point for the OpenRouter media helper.
# Uses the stdlib Python implementation (no jq/curl needed); falls back to the
# bash+jq version only when no working Python is available.
#
# Env notes: a leaked PYTHONHOME/PYTHONPATH (e.g. from a bundled runtime) breaks
# py/python on Windows, so the probe retries with those unset.
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

probe() { # $1 = python command words; sets PYENV prefix
  if $1 -c "import argparse, json, urllib.request" >/dev/null 2>&1; then PYENV=""; return 0; fi
  if env -u PYTHONHOME -u PYTHONPATH $1 -c "import argparse, json, urllib.request" >/dev/null 2>&1; then
    PYENV="env -u PYTHONHOME -u PYTHONPATH"; return 0
  fi
  return 1
}

for cand in "py -3" "python3" "python"; do
  if probe "$cand"; then
    exec $PYENV $cand "$DIR/or_media.py" "$@"
  fi
done

echo "note: no working python3 found; using the bash+jq implementation" >&2
exec bash "$DIR/or-media-jq.sh" "$@"

