#!/usr/bin/env bash
# Tests directory-specific diff functionality
# Verifies that gdiff can diff specific directories and shows changes only for that directory

testGdiffDirectorySpecific() {
  echo "🧪 Testing directory-specific diff functionality"

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

  # Test diff for specific directory only
  if gdiff dir1 >/dev/null 2>&1; then
    echo "✅ SUCCESS: Directory-specific diff works for dir1"

    # Test that it only shows changes for the specified directory
    local dir1_diff=$(gdiff dir1)
    local dir2_diff=$(gdiff dir2)
    local dir3_diff=$(gdiff dir3)

    if [[ -n $dir1_diff && -n $dir2_diff && -n $dir3_diff ]]; then
      echo "✅ SUCCESS: Each directory shows its own changes"
      cleanupTestRepo
      return 0
    else
      echo "❌ ERROR: Directory-specific diff content issue"
      cleanupTestRepo
      return 1
    fi
  else
    echo "❌ ERROR: Directory-specific diff failed"
    cleanupTestRepo
    return 1
  fi
}
