#!/usr/bin/env bash
# Build / run the OpenGL samples.
#
#   ./run.sh                        # build every sample
#   ./run.sh Prog2_5_triangle       # build + run one sample (dir name)
#   ./run.sh Chapter_02_opengl_Prog2_5_triangle   # full target name also works
#   ./run.sh --list                 # list all sample target names
#
# Needs the shell.nix environment (glew/glfw/glm/pkg-config/libx11).
# With direnv installed just `cd` here and `direnv allow` once; otherwise this
# script falls back to wrapping itself in `nix-shell`.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

if ! pkg-config --exists glew glfw3 glm 2>/dev/null; then
  exec nix-shell "$ROOT/shell.nix" --run "$(printf '%q ' "$0" "$@")"
fi

xmake_run() { xmake f -y --cxx=g++ >/dev/null; xmake "$@"; }

arg="${1:-}"
if [ -z "$arg" ]; then
  xmake_run build -y
  exit 0
fi

if [ "$arg" = "--list" ]; then
  # multi-column, column-major output; split on whitespace one per line
  xmake_run show -l targets | tr -s ' \t' '\n\n'
  exit 0
fi

# Read the whole target list first: piping xmake straight into `grep -q` lets
# grep close the pipe early, and `set -o pipefail` then turns the SIGPIPE into a
# failed pipeline (silently losing every match).
targets="$(xmake_run show -l targets | tr -s ' \t' '\n\n' || true)"

# Accept either the xmake target name or just the program directory name.
target="$arg"
if ! printf '%s\n' "$targets" | grep -qx "$target"; then
  target="$(find Programs -mindepth 2 -maxdepth 2 -type d -name "$arg" -print -quit \
            | awk -F/ '{print $(NF-1)"_"$NF}')"
  [ -n "$target" ] || { echo "no such sample: $arg (try ./run.sh --list)" >&2; exit 1; }
fi

echo ">> $target"
xmake_run build -y "$target"
# samples read shaders/textures by relative path; xmake.lua sets rundir per target
xmake_run run "$target"
