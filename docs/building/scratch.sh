#!/bin/bash
FILE="/Users/r/repos/react-native.skill/PLAN.md"

echo "=== Line count ==="
wc -l "$FILE"

echo ""
echo "=== Check Fix 1: Port references ==="
echo "--- Should NOT find 'localhost:8081' (should be \$PORT) ---"
grep -n 'localhost:8081' "$FILE" || echo "(none found - GOOD)"

echo ""
echo "--- Should find '\$PORT' references ---"
grep -n '\$PORT' "$FILE"

echo ""
echo "=== Check Fix 2: tree mode caveat ==="
grep -n 'tree.*mode.*caveat\|dev mode.*hook\|React DevTools hook not found' "$FILE"

echo ""
echo "=== Check Fix 3: Node 22+ guard ==="
grep -n 'process.version\|requires Node 22+, found' "$FILE"

echo ""
echo "=== Check Fix 4: Smoke Tests section ==="
grep -n 'Smoke Tests' "$FILE"

echo ""
echo "=== Check Fix 5: path resolution ==="
grep -n 'plugin install dir' "$FILE"

echo ""
echo "=== Check Fix 6 NOT applied: should still show 234 ==="
grep -n '234\|218' "$FILE"

echo ""
echo "=== Check Port resolution line in metro.sh section ==="
grep -n 'Port resolution order' "$FILE"

echo ""
echo "=== Check markdown section separators (---) ==="
grep -n '^---$' "$FILE"

echo ""
echo "=== Check section headers ==="
grep -n '^##' "$FILE"
