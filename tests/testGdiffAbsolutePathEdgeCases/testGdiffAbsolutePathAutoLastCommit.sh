#!/usr/bin/env bash
testGdiffAbsolutePathAutoLastCommit() {
  echo "Testing absolute path with automatic last commit detection"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create files with different commit histories
  echo "file1 v1" >file1.txt
  git add file1.txt
  git commit -m "Add file1" --quiet

  echo "file2 v1" >file2.txt
  git add file2.txt
  git commit -m "Add file2" --quiet

  echo "file1 v2" >file1.txt
  git add file1.txt
  git commit -m "Update file1" --quiet

  # Now file1 was last modified in the most recent commit
  # while file2 was last modified in the second-to-last commit

  echo "file1 current" >file1.txt
  echo "file2 current" >file2.txt

  # Get absolute paths
  local abs_file1=$(realpath file1.txt)
  local abs_file2=$(realpath file2.txt)

  # Test automatic last commit detection with absolute paths
  if gdiff "$abs_file1" >/dev/null 2>&1 && gdiff "$abs_file2" >/dev/null 2>&1; then
    echo "SUCCESS: Automatic last commit detection works with absolute paths"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Automatic last commit detection failed with absolute paths"
    cleanupTestRepo
    return 1
  fi
}
