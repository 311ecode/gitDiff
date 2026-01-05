#!/usr/bin/env bash
testGdiffLastCommitDefaultPath() {
  echo "🧪 Testing that default path (.) doesn't trigger last commit detection"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Make multiple commits
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file2.txt
  git add file2.txt
  git commit -m "Commit 2" --quiet

  # Modify files
  echo "modified1" >file1.txt
  echo "modified2" >file2.txt

  # Test that default path (.) uses default commit, not last commit detection
  # This should show changes from both files since we're diffing the whole repo
  local diff_output
  diff_output=$(gdiff 2>&1)
  local exit_status=$?

  if [[ $exit_status -eq 0 ]] &&
    echo "$diff_output" | grep -q "file1.txt" &&
    echo "$diff_output" | grep -q "file2.txt"; then
    echo "✅ SUCCESS: Default path uses default commit behavior"
    cleanupTestRepo
    return 0
  else
    echo "❌ ERROR: Default path behavior incorrect"
    echo "Diff output: $diff_output"
    echo "Exit status: $exit_status"
    cleanupTestRepo
    return 1
  fi
}
