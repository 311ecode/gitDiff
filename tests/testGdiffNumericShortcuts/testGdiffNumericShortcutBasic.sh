#!/usr/bin/env bash
testGdiffNumericShortcutBasic() {
  echo "Testing basic numeric shortcut functionality"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create multiple commits to have history
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file2.txt
  git add file2.txt
  git commit -m "Commit 2" --quiet

  echo "commit3" >file3.txt
  git add file3.txt
  git commit -m "Commit 3" --quiet

  # Make working directory changes
  echo "modified1" >file1.txt
  echo "modified2" >file2.txt
  echo "modified3" >file3.txt

  # Test basic numeric shortcuts (should work as HEAD~N when no path conflicts)
  if gdiff 1 >/dev/null 2>&1; then
    echo "SUCCESS: Numeric shortcut '1' works (HEAD~1)"
  else
    echo "ERROR: Numeric shortcut '1' failed"
    cleanupTestRepo
    return 1
  fi

  if gdiff 2 >/dev/null 2>&1; then
    echo "SUCCESS: Numeric shortcut '2' works (HEAD~2)"
  else
    echo "ERROR: Numeric shortcut '2' failed"
    cleanupTestRepo
    return 1
  fi

  if gdiff 3 >/dev/null 2>&1; then
    echo "SUCCESS: Numeric shortcut '3' works (HEAD~3)"
  else
    echo "ERROR: Numeric shortcut '3' failed"
    cleanupTestRepo
    return 1
  fi

  # Test that numeric shortcuts show expected content
  local diff1_output
  diff1_output=$(gdiff 1)
  if echo "$diff1_output" | grep -q "file3.txt"; then
    echo "SUCCESS: Numeric shortcut '1' shows recent changes"
  else
    echo "ERROR: Numeric shortcut '1' doesn't show expected content"
    cleanupTestRepo
    return 1
  fi

  # Test equivalence with explicit HEAD~ notation
  local diff_numeric
  local diff_explicit
  diff_numeric=$(gdiff 1)
  diff_explicit=$(gdiff HEAD~1)

  if [[ $diff_numeric == "$diff_explicit" ]]; then
    echo "SUCCESS: Numeric shortcut equivalent to explicit HEAD~1"
  else
    echo "ERROR: Numeric shortcut differs from explicit HEAD~1"
    cleanupTestRepo
    return 1
  fi

  # Test with working directory vs specific commit
  local diff2_output
  diff2_output=$(gdiff 2)
  if echo "$diff2_output" | grep -q "file2.txt\|file3.txt"; then
    echo "SUCCESS: Numeric shortcut '2' shows changes from HEAD~2"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Numeric shortcut '2' doesn't show expected changes"
    cleanupTestRepo
    return 1
  fi
}
