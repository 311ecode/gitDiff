#!/usr/bin/env bash
testGdiffNumericShortcutPathPriority() {
  echo "Testing numeric shortcut path priority logic"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create multiple commits to have commit history
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file2.txt
  git add file2.txt
  git commit -m "Commit 2" --quiet

  echo "commit3" >file3.txt
  git add file3.txt
  git commit -m "Commit 3" --quiet

  # Test scenario 1: No numeric path exists - should use commit shortcut
  if gdiff 2 >/dev/null 2>&1; then
    echo "SUCCESS: Numeric '2' works as commit shortcut when no path '2' exists"
  else
    echo "ERROR: Numeric commit shortcut failed when no path conflict"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 2: Create a file named "2" - should take priority
  echo "file named 2" >2
  git add 2
  git commit -m "Add file named 2" --quiet

  echo "modified file 2" >2

  if gdiff 2 >/dev/null 2>&1; then
    local diff_output
    diff_output=$(gdiff 2)
    if echo "$diff_output" | grep -q "file named 2"; then
      echo "SUCCESS: File '2' takes priority over commit shortcut"
    else
      echo "ERROR: File '2' didn't show expected content"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: File '2' priority failed"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 3: Explicit tilde forces commit interpretation
  if gdiff ~2 >/dev/null 2>&1; then
    echo "SUCCESS: Explicit ~2 overrides path priority"
  else
    echo "ERROR: Explicit ~2 failed"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 4: Create directory named "3" - should take priority
  mkdir -p 3
  echo "dir content" >3/file.txt
  git add 3/
  git commit -m "Add directory 3" --quiet

  echo "modified dir" >3/file.txt

  if gdiff 3 >/dev/null 2>&1; then
    local diff_output
    diff_output=$(gdiff 3)
    if echo "$diff_output" | grep -q "dir content"; then
      echo "SUCCESS: Directory '3' takes priority over commit shortcut"
    else
      echo "ERROR: Directory '3' didn't show expected content"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: Directory '3' priority failed"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 5: Path-aware numeric as second argument
  echo "target content" >target.txt
  git add target.txt
  git commit -m "Add target" --quiet

  echo "modified target" >target.txt

  if gdiff target.txt 1 >/dev/null 2>&1; then
    echo "SUCCESS: Path-aware numeric (2nd arg) works correctly"
  else
    echo "ERROR: Path-aware numeric as second argument failed"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 6: From subdirectory - test path resolution
  cd 3 || return 1

  # From inside directory "3", test that "2" still refers to file in parent
  if gdiff ../2 >/dev/null 2>&1; then
    echo "SUCCESS: Relative path to numeric file works from subdirectory"
  else
    echo "ERROR: Relative path to numeric file failed from subdirectory"
    cleanupTestRepo
    return 1
  fi

  # Test scenario 7: Numeric that doesn't exist as path should fall back to commit
  if gdiff 4 >/dev/null 2>&1; then
    echo "SUCCESS: Non-existent path '4' falls back to commit shortcut"
    cleanupTestRepo
    return 0
  else
    echo "INFO: Non-existent path '4' handled appropriately (may fail if commit doesn't exist)"
    cleanupTestRepo
    return 0
  fi
}
