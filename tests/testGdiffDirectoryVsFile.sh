#!/usr/bin/env bash
# Tests directory diff vs file diff distinction
# Verifies that directory diffs show changes for all files in the directory
# while file diffs only show changes for the specific file

testGdiffDirectoryVsFile() {
  echo "🧪 Testing directory diff vs file diff distinction"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Create directory with multiple files
  mkdir -p config
  echo "config1" >config/app.conf
  echo "config2" >config/db.conf

  git add config/
  git commit -m "Add config files" --quiet

  # Modify both files
  echo "config1 modified" >config/app.conf
  echo "config2 modified" >config/db.conf

  # Test that directory diff shows changes for all files in directory
  local dir_diff=$(gdiff config)
  local file1_diff=$(gdiff config/app.conf)
  local file2_diff=$(gdiff config/db.conf)

  if [[ -n $dir_diff && -n $file1_diff && -n $file2_diff ]]; then
    # Directory diff should contain changes from both files
    if echo "$dir_diff" | grep -q "app.conf" && echo "$dir_diff" | grep -q "db.conf"; then
      echo "✅ SUCCESS: Directory diff shows changes for all files in directory"
      cleanupTestRepo
      return 0
    else
      echo "❌ ERROR: Directory diff missing some file changes"
      cleanupTestRepo
      return 1
    fi
  else
    echo "❌ ERROR: Directory or file diffs empty"
    cleanupTestRepo
    return 1
  fi
}
