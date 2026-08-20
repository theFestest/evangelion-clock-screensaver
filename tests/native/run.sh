#!/bin/bash
# Compile and run the native logic unit tests.
set -euo pipefail
cd "$(dirname "$0")/../.."

OUT="$(mktemp -d)"
trap 'rm -rf "$OUT"' EXIT

clang -fobjc-arc -framework Foundation \
	-I. \
	EvangelionClockLogic.m tests/native/test_logic.m \
	-o "$OUT/test_logic"

"$OUT/test_logic"
