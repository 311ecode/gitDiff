#!/usr/bin/env bash
testGdiffAbsolutePathDeepNesting() {
  echo "Testing absolute paths with deep directory nesting"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create deeply nested structure
  mkdir -p very/deep/nested/directory/structure
  echo "deep content" >very/deep/nested/directory/structure/file.txt
  git add very/
  git commit -m "Add deep structure" --quiet

  echo "modified deep content" >very/deep/nested/directory/structure/file.txt

  # Get absolute path
  local abs_deep_path=$(realpath very/deep/nested/directory/structure/file.txt)

  # Test from various directory levels
  if gdiff "$abs_deep_path" >/dev/null 2>&1; then
    echo "SUCCESS: Deep absolute path works from root"

    # Test from nested directory
    cd very/deep || return 1
    if gdiff "$abs_deep_path" >/dev/null 2>&1; then
      echo "SUCCESS: Deep absolute path works from nested directory"
      cleanupTestRepo
      return 0
    else
      echo "ERROR: Deep absolute path failed from nested directory"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: Deep absolute path failed from root"
    cleanupTestRepo
    return 1
  fi
}
