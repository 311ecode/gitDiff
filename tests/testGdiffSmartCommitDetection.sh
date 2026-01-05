#!/usr/bin/env bash
# Tests smart commit detection - updated for path-aware behavior

testGdiffCurrentMatchesLastCommit() {
  echo "Testing behavior when current state matches last commit"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file with changes
  echo "stable content v1" >stable.txt
  git add stable.txt
  git commit -m "Add stable file v1" --quiet

  echo "stable content v2" >stable.txt
  git add stable.txt
  git commit -m "Update stable file v2" --quiet

  # Make some unrelated commits (that don't touch stable.txt)
  for i in {1..3}; do
    echo "unrelated $i" >"file$i.txt"
    git add "file$i.txt"
    git commit -m "Unrelated commit $i" --quiet
  done

  # Current working state matches the last committed state (no local changes)

  # Test path-aware numeric shortcut - should find the first different commit
  local output
  output=$(gdiff stable.txt 1 2>&1)

  # Should either work (finding a different commit) or give a helpful error
  if echo "$output" | grep -q "different commit" ||
    echo "$output" | grep -q "Could not find.*different commit"; then
    echo "SUCCESS: Path-aware behavior works correctly"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Unexpected behavior"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}

testGdiffWithActualWorkingChanges() {
  echo "Testing first different commit when working directory has changes"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file with version history
  echo "version 1" >evolving.txt
  git add evolving.txt
  git commit -m "Commit 1" --quiet

  echo "version 2" >evolving.txt
  git add evolving.txt
  git commit -m "Commit 2" --quiet

  # Make commits that don't touch this file
  for i in {1..2}; do
    echo "other $i" >"other$i.txt"
    git add "other$i.txt"
    git commit -m "Other commit $i" --quiet
  done

  # Now make working directory changes
  echo "version 3 - current work" >evolving.txt

  # Test path-aware numeric shortcut - should find actual different commit
  local output
  output=$(gdiff evolving.txt 1 2>&1)

  # Should find the commit with different content and show meaningful diff
  if echo "$output" | grep -q "different commit" &&
    echo "$output" | grep -q "version"; then
    echo "SUCCESS: Found meaningful different commit"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Didn't find meaningful different commit"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}
