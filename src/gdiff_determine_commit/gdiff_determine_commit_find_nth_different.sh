gdiff_determine_commit_find_nth_different() {
  local path="$1"
  local nth="${2:-1}"  # Default to 1st different commit
  local max_search_depth="${3:-50}"  # Search up to 50 commits back
  
  [[ -n "${DEBUG:-}" ]] && \
    echo "DEBUG: Searching for ${nth}th different commit for path '$path'..." >&2
  
  # Get list of commits that touched this path
  local commits
  commits=$(git log --format=%H -n "$max_search_depth" -- "$path" 2>/dev/null)
  
  if [[ -z "$commits" ]]; then
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: No commits found affecting '$path'" >&2
    return 1
  fi
  
  local commit_count=0
  local different_count=0
  local nth_different_commit=""
  
  while IFS= read -r commit_hash; do
    if [[ -n "$commit_hash" ]]; then
      commit_count=$((commit_count + 1))
      
      # Compare current working state with this commit
      local diff_output
      diff_output=$(git diff "$commit_hash" -- "$path" 2>/dev/null)
      
      if [[ -n "$diff_output" ]]; then
        # Found a commit that's different from current state
        different_count=$((different_count + 1))
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Found ${different_count}th different commit: $commit_hash" >&2
        
        if [[ $different_count -eq $nth ]]; then
          nth_different_commit="$commit_hash"
          break
        fi
      else
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Commit $commit_hash has same content as current state" >&2
      fi
    fi
  done <<< "$commits"
  
  if [[ -n "$nth_different_commit" ]]; then
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: Found ${nth}th different commit: $nth_different_commit (searched $commit_count commits)" >&2
    echo "$nth_different_commit"
    return 0
  else
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: Could not find ${nth}th different commit for '$path' (found only $different_count different commits in $commit_count total)" >&2
    return 1
  fi
}