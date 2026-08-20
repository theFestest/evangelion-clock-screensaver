#!/bin/bash
# Integration test for the self-exit-on-stop workaround: loads the built
# saver in the window harness, posts the com.apple.screensaver.willstop
# distributed notification (the same signal legacyScreenSaver delivers),
# and asserts the process exits — and that a preview instance does not.
# Requires a GUI session and a prior Release build.
set -euo pipefail
cd "$(dirname "$0")/../.."

SAVER="build/Release/Evangelion Clock.saver"
[ -d "$SAVER" ] || { echo "FAIL: $SAVER missing; run the xcodebuild Release build first" >&2; exit 1; }

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"; kill $HPID 2>/dev/null || true' EXIT

clang -fobjc-arc -framework Cocoa -framework ScreenSaver -o "$OUT/harness" tools/harness.m
clang -fobjc-arc -framework Foundation -o "$OUT/post-willstop" tools/post-willstop.m

wait_for_attach() {
	for _ in $(seq 1 20); do
		grep -q "view attached" "$1" 2>/dev/null && return 0
		sleep 0.5
	done
	echo "FAIL: harness never attached a view; log:" >&2
	cat "$1" >&2
	return 1
}

# The exit is scheduled 2s after the notification; poll up to 8s.
wait_for_exit() {
	for _ in $(seq 1 16); do
		kill -0 "$1" 2>/dev/null || return 0
		sleep 0.5
	done
	return 1
}

echo "-- non-preview instance exits on willstop"
"$OUT/harness" "$SAVER" single > "$OUT/nonpreview.log" 2>&1 &
HPID=$!
wait_for_attach "$OUT/nonpreview.log"
"$OUT/post-willstop"
if wait_for_exit "$HPID"; then
	echo "ok: process exited after willstop"
else
	echo "FAIL: process still alive after willstop" >&2
	exit 1
fi

echo "-- preview instance survives willstop"
"$OUT/harness" "$SAVER" single preview > "$OUT/preview.log" 2>&1 &
HPID=$!
wait_for_attach "$OUT/preview.log"
"$OUT/post-willstop"
sleep 4
if kill -0 "$HPID" 2>/dev/null; then
	echo "ok: preview process still running"
	kill "$HPID"
else
	echo "FAIL: preview process exited on willstop" >&2
	exit 1
fi

echo "all lifecycle tests passed"
