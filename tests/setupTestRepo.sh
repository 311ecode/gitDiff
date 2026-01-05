#!/usr/bin/env bash
setupTestRepo() {
  local temp_dir=$(mktemp -d)
  cd "$temp_dir" || return 1
  git init --quiet
  git config user.email "test@example.com"
  git config user.name "Test User"
  echo "initial content" >testfile.txt
  git add testfile.txt
  git commit -m "Initial commit" --quiet
  return 0
}
