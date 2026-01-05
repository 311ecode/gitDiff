#!/usr/bin/env bash
testGdiffAbsolutePathWithCommit() {
  echo "Testing absolute path with commit reference"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create multiple commits
  mkdir -p docs
  echo "initial docs" >docs/readme.md
  git add docs/
  git commit -m "Add docs" --quiet

  echo "updated docs" >docs/readme.md
  git add docs/readme.md
  git commit -m "Update docs" --quiet

  echo "current docs" >docs/readme.md

  # Get absolute path
  local abs_path=$(realpath docs/readme.md)

  # Test absolute path with commit in both orders
  if gdiff "$abs_path" HEAD~1 >/dev/null 2>&1 && gdiff HEAD~1 "$abs_path" >/dev/null 2>&1; then
    echo "SUCCESS: Absolute path with commit works in both orders"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Absolute path with commit failed"
    cleanupTestRepo
    return 1
  fi
}
