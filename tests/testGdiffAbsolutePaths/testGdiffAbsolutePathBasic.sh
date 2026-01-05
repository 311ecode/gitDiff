#!/usr/bin/env bash
testGdiffAbsolutePathBasic() {
  echo "Testing basic absolute path functionality"

  if ! setupTestRepo; then
    echo "ERROR: Failed to setup test repo"
    return 1
  fi

  # Create files and directories
  mkdir -p src/components
  echo "component content" >src/components/button.js
  git add src/components/
  git commit -m "Add components" --quiet

  # Modify file
  echo "modified component" >src/components/button.js

  # Get absolute path
  local abs_path=$(realpath src/components/button.js)

  # Test absolute path
  if gdiff "$abs_path" >/dev/null 2>&1; then
    echo "SUCCESS: Absolute path works"
    cleanupTestRepo
    return 0
  else
    echo "ERROR: Absolute path failed"
    cleanupTestRepo
    return 1
  fi
}
