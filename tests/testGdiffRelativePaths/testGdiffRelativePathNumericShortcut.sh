#!/usr/bin/env bash
testGdiffRelativePathNumericShortcut() {
  echo "Testing numeric shortcut vs relative path priority"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Make multiple commits
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file2.txt
  git add file2.txt
  git commit -m "Commit 2" --quiet

  # Create directory structure
  mkdir -p a
  cd a || return 1

  # Create a directory named "2" inside a/
  mkdir -p 2
  echo "content" >2/file.txt
  git add 2/
  git commit -m "Add a/2 directory" --quiet

  echo "modified" >2/file.txt

  # From a/, "2" should refer to the local directory "./2"
  if gdiff 2 >/dev/null 2>&1; then
    local diff_output
    diff_output=$(gdiff 2)
    if echo "$diff_output" | grep -q "file.txt"; then
      echo "SUCCESS: Local path '2' takes priority over numeric shortcut"

      # Test that explicit ~2 still works as commit
      if gdiff ~2 >/dev/null 2>&1; then
        echo "SUCCESS: Explicit ~2 still works as commit reference"
        cleanupTestRepo
        return 0
      else
        echo "ERROR: Explicit ~2 failed"
        cleanupTestRepo
        return 1
      fi
    else
      echo "ERROR: Directory '2' diff doesn't show expected content"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: Local directory '2' reference failed"
    cleanupTestRepo
    return 1
  fi
}
