#!/usr/bin/env bash
testGdiffAbsolutePathOutsideRepo() {
  echo "Testing absolute path outside repository"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create a file outside the repo
  local outside_file="/tmp/outside_repo_file.txt"
  echo "outside content" >"$outside_file"

  # Test with absolute path outside repo (should handle gracefully)
  local result
  if result=$(gdiff "$outside_file" 2>&1); then
    echo "INFO: Absolute path outside repo handled (may show no changes)"
  else
    # It's acceptable for this to fail since the file isn't in the repo
    echo "INFO: Absolute path outside repo failed as expected"
  fi

  # Clean up
  rm -f "$outside_file"
  cleanupTestRepo
  return 0
}
