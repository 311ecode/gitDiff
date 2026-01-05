#!/usr/bin/env bash
# Tests smart commit validation and gap information

testGdiffCommitValidationBasic() {
  echo "Testing commit validation when commit didn't touch path"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file A
  echo "file A content" >fileA.txt
  git add fileA.txt
  git commit -m "Add file A" --quiet

  # Create file B (this commit doesn't touch file A)
  echo "file B content" >fileB.txt
  git add fileB.txt
  git commit -m "Add file B" --quiet

  # Make another commit that doesn't touch file A
  echo "file C content" >fileC.txt
  git add fileC.txt
  git commit -m "Add file C" --quiet

  # Modify file A
  echo "modified file A" >fileA.txt

  # Test that gdiff warns when using HEAD~1 (which didn't touch fileA.txt)
  local output
  output=$(gdiff fileA.txt HEAD~1 2>&1)

  if echo "$output" | grep -q "didn't modify this path"; then
    echo "SUCCESS: Warning shown when commit didn't touch the path"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: No warning shown for irrelevant commit"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}

testGdiffGapInformation() {
  echo "Testing gap information display"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create file and multiple commits
  echo "version 1" >target.txt
  git add target.txt
  git commit -m "Add target file" --quiet

  # Several commits that don't touch the target file
  for i in {1..5}; do
    echo "unrelated $i" >"unrelated$i.txt"
    git add "unrelated$i.txt"
    git commit -m "Unrelated commit $i" --quiet
  done

  # Modify target file
  echo "modified target" >target.txt

  # Test gap information with auto-detection
  local output
  output=$(gdiff target.txt 2>&1)

  if echo "$output" | grep -q "commits ago"; then
    echo "SUCCESS: Gap information shown with auto-detection"

    # Test gap information with explicit commit
    output=$(gdiff target.txt HEAD~3 2>&1)
    if echo "$output" | grep -q "Comparing against:"; then
      echo "SUCCESS: Gap information shown with explicit commit"
      cleanupTestRepo
      return 0
    else
      echo "ERROR: No gap information with explicit commit"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: No gap information shown"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}

testGdiffCommitSuggestions() {
  echo "Testing commit suggestions when using wrong commit"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create directory structure
  mkdir -p src/utils
  echo "utils v1" >src/utils/helpers.js
  git add src/
  git commit -m "Add utils" --quiet

  # Several unrelated commits
  for i in {1..3}; do
    echo "other $i" >"other$i.txt"
    git add "other$i.txt"
    git commit -m "Other commit $i" --quiet
  done

  # Modify the utils file
  echo "modified utils" >src/utils/helpers.js

  # Test suggestions when using recent commit that didn't touch the path
  local output
  output=$(gdiff src/utils/helpers.js HEAD~1 2>&1)

  if echo "$output" | grep -q "Consider using:"; then
    echo "SUCCESS: Suggestions provided for better commit choice"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: No suggestions provided"
    echo "Output: $output"
    cleanupTestRepo
    return 1
  fi
}
