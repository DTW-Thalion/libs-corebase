#!/bin/bash
# Compile and run corebase CFTesting-style test files against Apple
# CoreFoundation to confirm their assertions hold on the reference
# implementation.  Any compile failure, crash, non-zero exit, or "Failed
# test:" / "Dashed hope:" line marks a divergence between the assertion and
# Apple's behaviour.
set -u

CC=${CC:-clang}
CFLAGS="-Wno-deprecated-declarations -Wno-unused -O0 -g"
FRAMEWORKS="-framework CoreFoundation -framework Foundation"
WORK=$(mktemp -d)
DIVERGENT=0

files=""
for a in "$@"; do
  if [ -d "$a" ]; then
    for f in "$a"/*.m; do
      [ -f "$f" ] && files="$files $f"
    done
  elif [ -f "$a" ]; then
    files="$files $a"
  fi
done

for f in $files; do
  echo "======================================================================"
  echo "FILE: $f"
  bin="$WORK/$(echo "$f" | tr '/.' '__')"
  if ! $CC $CFLAGS "$f" $FRAMEWORKS -o "$bin" 2> "$bin.cc"; then
    echo "RESULT: COMPILE-FAIL"
    sed 's/^/  cc: /' "$bin.cc"
    DIVERGENT=$((DIVERGENT + 1))
    continue
  fi

  "$bin" > "$bin.out" 2> "$bin.err" &
  pid=$!
  ( sleep 25; kill -9 "$pid" 2>/dev/null ) &
  wdog=$!
  wait "$pid"
  rc=$?
  kill "$wdog" 2>/dev/null
  wait "$wdog" 2>/dev/null

  passed=$(grep -c "Passed test:" "$bin.err")
  failed=$(grep -c "Failed test:" "$bin.err")
  dashed=$(grep -c "Dashed hope:" "$bin.err")
  echo "  passed=$passed failed=$failed dashed=$dashed exit=$rc"

  if [ "$rc" -gt 128 ]; then
    echo "RESULT: CRASH (signal $((rc - 128)))"
    tail -6 "$bin.err" | sed 's/^/  tail: /'
    DIVERGENT=$((DIVERGENT + 1))
  elif [ "$rc" -ne 0 ]; then
    echo "RESULT: NONZERO-EXIT ($rc)"
    tail -6 "$bin.err" | sed 's/^/  tail: /'
    DIVERGENT=$((DIVERGENT + 1))
  elif [ "$failed" -gt 0 ] || [ "$dashed" -gt 0 ]; then
    echo "RESULT: DIVERGENT ASSERTIONS"
    grep -E "Failed test:|Dashed hope:" "$bin.err" | sed 's/^/  APPLE-DIFF: /'
    DIVERGENT=$((DIVERGENT + 1))
  else
    echo "RESULT: OK (matches Apple CF)"
  fi
done

echo "======================================================================"
echo "FILES WITH A DIVERGENCE: $DIVERGENT"
