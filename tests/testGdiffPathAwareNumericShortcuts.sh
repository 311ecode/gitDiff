#!/usr/bin/env bash
# Tests path-aware numeric shortcuts

testGdiffPathAwareNumericBasic() {
  echo "Testing basic path-aware numeric shortcuts"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file with version history
  echo "version 1" >evolving.txt
  git add evolving.txt
  git commit -m "Add v1" --quiet

  echo "version 2" >evolving.txt
  git add evolving.txt
  git commit -m "Add v2" --quiet

  echo "version 3" >evolving.txt
  git add evolving.txt
  git commit -m "Add v3" --quiet

  # Current working state
  echo "version 4 - current" >evolving.txt

  # Test path-aware numeric shortcut
  if gdiff evolving.txt 1 >/dev/null 2>&1; then
    echo "SUCCESS: Path-aware numeric shortcut works"

    # Test that it finds different content
    local diff_output
    diff_output=$(gdiff evolving.txt 1)
    if echo "$diff_output" | grep -q "version 3" && echo "$diff_output" | grep -q "version 4"; then
      echo "SUCCESS: Found first different commit with expected content"
      cleanupTestRepo
      return 0
    else
      echo "ERROR: Unexpected diff content"
      echo "$diff_output"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: Path-aware numeric shortcut failed"
    cleanupTestRepo
    return 1
  fi
}

testGdiffPathAwareNumericMultiple() {
  echo "Testing multiple path-aware numeric shortcuts"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file with several versions
  for i in {1..5}; do
    echo "version $i" >multi.txt
    git add multi.txt
    git commit -m "Version $i" --quiet
  done

  # Current working state
  echo "version current" >multi.txt

  # Test different numeric shortcuts
  if gdiff multi.txt 1 >/dev/null 2>&1 &&
    gdiff multi.txt 2 >/dev/null 2>&1 &&
    gdiff multi.txt 3 >/dev/null 2>&1; then
    echo "SUCCESS: Multiple path-aware numeric shortcuts work"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Some path-aware numeric shortcuts failed"
    cleanupTestRepo
    return 1
  fi
}

testGdiffPathAwareWithUnrelatedCommits() {
  echo "Testing path-aware shortcuts with unrelated commits in between"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create target file
  echo "target v1" >target.txt
  git add target.txt
  git commit -m "Target v1" --quiet

  # Add unrelated commits
  for i in {1..10}; do
    echo "unrelated $i" >"unrelated$i.txt"
    git add "unrelated$i.txt"
    git commit -m "Unrelated $i" --quiet
  done

  # Update target file
  echo "target v2" >target.txt
  git add target.txt
  git commit -m "Target v2" --quiet

  # More unrelated commits
  for i in {11..15}; do
    echo "unrelated $i" >"unrelated$i.txt"
    git add "unrelated$i.txt"
    git commit -m "Unrelated $i" --quiet
  done

  # Current working state
  echo "target current" >target.txt

  # Test that path-aware shortcut skips unrelated commits
  local output
  output=$(gdiff target.txt 1 2>&1)

  if echo "$output" | grep -q "target v2" && echo "$output" | grep -q "target current"; then
    echo "SUCCESS: Path-aware shortcut correctly skips unrelated commits"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Path-aware shortcut didn't work correctly with unrelated commits"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}

testGdiffPathAwareErrorHandling() {
  echo "Testing path-aware error handling"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file with only one version
  echo "only version" >single.txt
  git add single.txt
  git commit -m "Single version" --quiet

  # No changes to working directory (current = committed)

  # Test asking for 2nd different commit when only 1 exists
  local output
  output=$(gdiff single.txt 2 2>&1)
  local exit_code=$?

  if [[ $exit_code -ne 0 ]] && echo "$output" | grep -q "Could not find"; then
    echo "SUCCESS: Proper error handling for non-existent Nth different commit"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Didn't handle missing Nth different commit properly"
    echo "Exit code: $exit_code"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}
