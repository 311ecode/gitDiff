#!/usr/bin/env bash
testGdiffNoRecentDifferences() {
  echo "Testing behavior when no recent differences exist for a file"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file and commit it
  echo "stable content" >stable.txt
  git add stable.txt
  git commit -m "Add stable file" --quiet

  # Make many commits that don't touch this file
  for i in {1..10}; do
    echo "unrelated $i" >"unrelated$i.txt"
    git add "unrelated$i.txt"
    git commit -m "Unrelated commit $i" --quiet
  done

  # No changes to stable.txt in working directory (current = committed)

  # Test path-aware numeric shortcut when no recent differences exist
  local output
  output=$(gdiff stable.txt 1 2>&1)

  if echo "$output" | grep -q "Could not find.*different commit" ||
    echo "$output" | grep -q "No different commits found"; then
    echo "SUCCESS: Properly handles case with no recent differences"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Didn't handle no recent differences case properly"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}
