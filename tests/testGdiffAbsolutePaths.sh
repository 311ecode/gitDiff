#!/usr/bin/env bash
# Tests absolute path functionality
# Updated for path-aware numeric shortcuts

testGdiffAbsolutePathNumericShortcut() {
  echo "Testing absolute path with numeric shortcuts"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create commits with actual file changes
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file1.txt
  git add file1.txt
  git commit -m "Commit 2" --quiet

  echo "modified" >file1.txt

  # Get absolute path
  local abs_path=$(realpath file1.txt)

  # Test absolute path with path-aware numeric shortcut
  if gdiff "$abs_path" 1 >/dev/null 2>&1 && gdiff 1 "$abs_path" >/dev/null 2>&1; then
    echo "SUCCESS: Absolute path with path-aware numeric shortcut works"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Absolute path with path-aware numeric shortcut failed"
    cleanupTestRepo
    return 1
  fi
}
