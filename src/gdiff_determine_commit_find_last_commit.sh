gdiff_determine_commit_find_last_commit() {
  local commit="$1"
  local path="$2"
  
  [[ -n "${DEBUG:-}" ]] && \
    echo "DEBUG: Finding last commit for '$path'..." >&2
  local lastCommit
  lastCommit=$(git log -1 --format=%H -- "$path" 2>/dev/null)
  if [[ -n "$lastCommit" ]]; then
    commit="$lastCommit"
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: Using last commit: $commit" >&2
  else
    if [[ ! -e "$path" ]]; then
      echo "Error: Path '$path' does not exist" >&2
      return 1  # Fix: Return error code 1 for non-existent paths
    fi
    # Uncommitted/new path → compare against HEAD (not HEAD~1)
    commit="HEAD"
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: No history; fallback to $commit" >&2
  fi
  
  echo "$commit"
}