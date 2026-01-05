#!/usr/bin/env bash
cleanupTestRepo() {
  local temp_dir=$(pwd)
  cd /tmp || return 1
  rm -rf "$temp_dir"
  return 0
}
