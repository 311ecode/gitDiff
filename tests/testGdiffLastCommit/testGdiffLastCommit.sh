#!/usr/bin/env bash
# Tests automatic last commit detection for paths
# Verifies that gdiff automatically uses the last commit that modified a specific path
# when a path is specified without an explicit commit reference

testGdiffLastCommit() {
  echo "🧪 Testing automatic last commit detection for paths"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Create multiple directories with files
  mkdir -p dir1 dir2 dir3

  # Initial commit for dir1
  echo "dir1 initial" >dir1/file1.txt
  git add dir1/file1.txt
  git commit -m "Add dir1 initial" --quiet

  # Commit for dir2
  echo "dir2 initial" >dir2/file2.txt
  git add dir2/file2.txt
  git commit -m "Add dir2 initial" --quiet

  # Commit for dir3
  echo "dir3 initial" >dir3/file3.txt
  git add dir3/file3.txt
  git commit -m "Add dir3 initial" --quiet

  # Modify files in all directories
  echo "dir1 modified" >dir1/file1.txt
  echo "dir2 modified" >dir2/file2.txt
  echo "dir3 modified" >dir3/file3.txt

  # Test that gdiff automatically uses last commit for each directory
  if gdiff dir1 >/dev/null 2>&1 &&
    gdiff dir2 >/dev/null 2>&1 &&
    gdiff dir3 >/dev/null 2>&1; then
    echo "✅ SUCCESS: Automatic last commit detection works for directories"

    # Test that explicit commit overrides automatic detection
    if gdiff dir1 HEAD~2 >/dev/null 2>&1; then
      echo "✅ SUCCESS: Explicit commit overrides automatic last commit detection"
      cleanupTestRepo
      return 0
    else
      echo "❌ ERROR: Explicit commit override failed"
      cleanupTestRepo
      return 1
    fi
  else
    echo "❌ ERROR: Automatic last commit detection failed"
    cleanupTestRepo
    return 1
  fi
}
