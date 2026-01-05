#!/usr/bin/env bash
# Tests commit hash references
# Verifies that gdiff correctly handles full commit hash references

testGdiffCommitHash() {
  echo "🧪 Testing commit hash references"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Get the initial commit hash
  local commit_hash
  commit_hash=$(git log --format=%H -n 1)

  # Make a change
  echo "change" >testfile.txt

  # Test commit hash reference
  if gdiff "$commit_hash" >/dev/null 2>&1; then
    echo "✅ SUCCESS: Commit hash reference works"
    cleanupTestRepo
    return 0
  else
    echo "❌ ERROR: Commit hash reference failed"
    cleanupTestRepo
    return 1
  fi
}
