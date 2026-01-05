#!/usr/bin/env bash
# Tests numeric shortcut functionality (N vs ~N)
# Updated for path-aware numeric shortcuts

testGdiffNumericShortcutWithPath() {
  echo "🧪 Testing numeric shortcut with path argument"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Make multiple commits with file changes
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file1.txt
  git add file1.txt
  git commit -m "Commit 2" --quiet

  # Modify files in working directory
  echo "modified1" >file1.txt

  # Test path-aware numeric shortcut (new behavior)
  if gdiff file1.txt 1 >/dev/null 2>&1 && gdiff 1 file1.txt >/dev/null 2>&1; then
    echo "✅ SUCCESS: Path-aware numeric shortcut works in both orders"
    cleanupTestRepo
    return 0
  else
    echo "❌ ERROR: Path-aware numeric shortcut failed"
    cleanupTestRepo
    return 1
  fi
}

testGdiffNumericShortcutSecondArgument() {
  echo "🧪 Testing numeric shortcut as second argument"

  if ! setupTestRepo; then
    echo "❌ ERROR: Failed to setup test repo"
    return 1
  fi

  # Make multiple commits with actual file changes
  echo "commit1" >file1.txt
  git add file1.txt
  git commit -m "Commit 1" --quiet

  echo "commit2" >file1.txt
  git add file1.txt
  git commit -m "Commit 2" --quiet

  # Modify file in working directory
  echo "modified" >file1.txt

  # Test path-aware numeric shortcut as second argument
  if gdiff file1.txt 1 >/dev/null 2>&1; then
    echo "✅ SUCCESS: Path-aware numeric shortcut works as second argument"
    cleanupTestRepo
    return 0
  else
    echo "❌ ERROR: Path-aware numeric shortcut as second argument failed"
    cleanupTestRepo
    return 1
  fi
}
