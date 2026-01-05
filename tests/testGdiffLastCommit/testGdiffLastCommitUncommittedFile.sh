#!/usr/bin/env bash
testGdiffLastCommitUncommittedFile() {
  echo "🧪 Testing automatic last commit with uncommitted file"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Create but don't commit a file
  echo "uncommitted" >newfile.txt

  # Test with uncommitted file (should fall back to default commit and work)
  if gdiff newfile.txt >/dev/null 2>&1; then
    echo "✅ SUCCESS: Handled uncommitted file gracefully"
    cleanupTestRepo
    return 0
  else
    echo "❌ ERROR: Failed with uncommitted file"
    cleanupTestRepo
    return 1
  fi
}
