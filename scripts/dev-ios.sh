#!/usr/bin/env bash
#
# Live iOS preview helper for the Flutter app.
#
#   scripts/dev-ios.sh start     boot the simulator and run the app
#   scripts/dev-ios.sh reload    hot reload  (SIGUSR1)
#   scripts/dev-ios.sh restart   hot restart (SIGUSR2)
#   scripts/dev-ios.sh shot      screenshot the simulator
#   scripts/dev-ios.sh status    show whether the session is alive
#   scripts/dev-ios.sh stop      stop the run
#
# Driving the session by signal rather than by keystroke lets an agent or a
# script reload the app without owning the terminal.

set -euo pipefail

DEVICE_ID="${DEVICE_ID:-29547D37-B063-4C8C-A105-175E97A702F7}"   # iPhone 17, iOS 26.5
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$REPO_ROOT/apps/mobile"

RUN_DIR="${TMPDIR:-/tmp}/apc-dev-ios"
PID_FILE="$RUN_DIR/flutter.pid"
FIFO="$RUN_DIR/stdin.fifo"
LOG="$RUN_DIR/flutter.log"

# Flutter writes its build output here instead of into the repo. The repository
# lives under an iCloud-synced folder, where the File Provider stamps
# com.apple.FinderInfo onto directories; codesign then refuses to sign
# Flutter.framework ("resource fork, Finder information, or similar detritus
# not allowed") and every iOS build fails. Keeping build/ outside iCloud avoids
# it. Harmless on machines without iCloud Desktop sync.
BUILD_DIR="${FLUTTER_BUILD_DIR:-$HOME/.flutter-builds/ai-pronunciation-coach-mobile}"

ensure_build_dir() {
  mkdir -p "$BUILD_DIR"
  if [ -e "$APP_DIR/build" ] && [ ! -L "$APP_DIR/build" ]; then
    rm -rf "$APP_DIR/build"
  fi
  if [ ! -L "$APP_DIR/build" ]; then
    ln -s "$BUILD_DIR" "$APP_DIR/build"
  fi
}

running() {
  [ -f "$PID_FILE" ] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null
}

case "${1:-start}" in
  start)
    if running; then
      echo "already running (pid $(cat "$PID_FILE")) — use reload/restart"
      exit 0
    fi

    xcrun simctl boot "$DEVICE_ID" 2>/dev/null || true
    open -a Simulator

    ensure_build_dir
    mkdir -p "$RUN_DIR"
    rm -f "$FIFO" "$LOG"
    mkfifo -m 600 "$FIFO"

    # Hold the FIFO open so flutter never sees EOF on stdin and exits.
    tail -f /dev/null > "$FIFO" &
    echo $! > "$RUN_DIR/holder.pid"

    cd "$APP_DIR"
    nohup flutter run -d "$DEVICE_ID" --pid-file "$PID_FILE" \
      < "$FIFO" > "$LOG" 2>&1 &

    echo "starting — log: $LOG"
    echo "waiting for the app to attach..."
    for _ in $(seq 1 200); do
      grep -q "Flutter run key commands" "$LOG" 2>/dev/null && break
      grep -qE "Failed to build|Encountered error" "$LOG" 2>/dev/null && {
        echo "build failed; see $LOG"; exit 1; }
      sleep 3
    done
    grep -E "Dart VM Service|Flutter run key commands" "$LOG" | tail -2
    ;;

  reload)
    running || { echo "not running — start it first"; exit 1; }
    kill -USR1 "$(cat "$PID_FILE")"
    echo "hot reload sent"
    ;;

  restart)
    running || { echo "not running — start it first"; exit 1; }
    kill -USR2 "$(cat "$PID_FILE")"
    echo "hot restart sent"
    ;;

  shot)
    out="${2:-$RUN_DIR/screenshot.png}"
    xcrun simctl io "$DEVICE_ID" screenshot "$out" >/dev/null 2>&1
    echo "$out"
    ;;

  status)
    if running; then
      echo "running (pid $(cat "$PID_FILE"))"
    else
      echo "not running"
    fi
    ;;

  stop)
    running && kill "$(cat "$PID_FILE")" 2>/dev/null || true
    [ -f "$RUN_DIR/holder.pid" ] && kill "$(cat "$RUN_DIR/holder.pid")" 2>/dev/null || true
    rm -f "$PID_FILE" "$FIFO" "$RUN_DIR/holder.pid"
    echo "stopped"
    ;;

  *)
    echo "usage: $0 {start|reload|restart|shot|status|stop}" >&2
    exit 2
    ;;
esac
