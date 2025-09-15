gdiff_determine_commit_find_first_different() {
  local path="$1"
  local max_search_depth="${2:-20}"  # Default to searching 20 commits back
  
  [[ -n "${DEBUG:-}" ]] && \
    echo "DEBUG: Searching for first commit different from current state for '$path'..." >&2
  
  # Get list of commits that touched this path, up to max_search_depth
  local commits
  commits=$(git log --format=%H -n "$max_search_depth" -- "$path" 2>/dev/null)
  
  if [[ -z "$commits" ]]; then
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: No commits found affecting '$path'" >&2
    return 1
  fi
  
  local commit_count=0
  local first_different_commit=""
  
  while IFS= read -r commit_hash; do
    if [[ -n "$commit_hash" ]]; then
      commit_count=$((commit_count + 1))
      
      # Compare current working state with this commit
      local diff_output
      diff_output=$(git diff "$commit_hash" -- "$path" 2>/dev/null)
      
      if [[ -n "$diff_output" ]]; then
        # Found a commit that's different from current state
        first_different_commit="$commit_hash"
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Found first different commit: $commit_hash (checked $commit_count commits)" >&2
        break
      else
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Commit $commit_hash has same content as current state" >&2
      fi
    fi
  done <<< "$commits"
  
  if [[ -n "$first_different_commit" ]]; then
    echo "$first_different_commit"
    return 0
  else
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: No different commits found in last $commit_count commits for '$path'" >&2
    return 1
  fi
}