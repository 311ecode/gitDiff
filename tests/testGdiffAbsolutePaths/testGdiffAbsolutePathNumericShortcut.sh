#!/usr/bin/env bash
testGdiffAbsolutePathNumericShortcut() {
  echo "Testing absolute path with numeric shortcuts"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create commits
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file2.txt
  git add file2.txt
  git commit -m "Commit 2" --quiet

  echo "modified" >file1.txt

  # Get absolute path
  local abs_path=$(realpath file1.txt)

  # Test absolute path with numeric shortcut
  if gdiff "$abs_path" 2 >/dev/null 2>&1 && gdiff 2 "$abs_path" >/dev/null 2>&1; then
    echo "SUCCESS: Absolute path with numeric shortcut works"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Absolute path with numeric shortcut failed"
    cleanupTestRepo
    return 1
  fi
}
