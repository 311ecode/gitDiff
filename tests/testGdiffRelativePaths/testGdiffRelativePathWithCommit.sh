#!/usr/bin/env bash
testGdiffRelativePathWithCommit() {
  echo "Testing relative path with commit reference"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create structure
  mkdir -p subdir
  echo "initial" >subdir/file.txt
  git add subdir/
  git commit -m "Add subdir" --quiet

  echo "commit2" >subdir/file.txt
  git add subdir/file.txt
  git commit -m "Modify subdir" --quiet

  echo "current" >subdir/file.txt

  # Move to root and test relative path with commit
  if gdiff subdir 2 >/dev/null 2>&1 && gdiff 2 subdir >/dev/null 2>&1; then
    echo "SUCCESS: Relative path with commit works from root"

    # Move to subdirectory and test
    cd subdir || return 1
    if gdiff . 2 >/dev/null 2>&1; then
      echo "SUCCESS: Current directory reference works from subdirectory"
      cleanupTestRepo
      return 0
    else
      echo "ERROR: Current directory reference failed from subdirectory"
      cleanupTestRepo
      return 1
    fi
  else
    echo "ERROR: Relative path with commit failed"
    cleanupTestRepo
    return 1
  fi
}
