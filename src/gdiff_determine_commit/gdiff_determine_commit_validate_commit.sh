gdiff_determine_commit_validate_commit() {
  local commit="$1"
  local path="$2"
  
  # Check if the specified commit actually touched the path
  if [[ "$path" != "." ]]; then
    local commits_touching_path
    commits_touching_path=$(git log --format=%H -- "$path" 2>/dev/null)
    
    if [[ -n "$commits_touching_path" ]]; then
      local commit_hash
      commit_hash=$(git rev-parse "$commit" 2>/dev/null)
      
      if [[ -n "$commit_hash" ]] && ! echo "$commits_touching_path" | grep -q "^$commit_hash$"; then
        # The specified commit didn't touch this path
        local last_commit
        last_commit=$(echo "$commits_touching_path" | head -1)
        
        # Get commit info
        local specified_info
        specified_info=$(git log -1 --format="%h %s" "$commit" 2>/dev/null || echo "unknown commit")
        
        local last_info
        last_info=$(git log -1 --format="%h %s" "$last_commit" 2>/dev/null || echo "unknown commit")
        
        # Count commits
        local commits_to_last
        commits_to_last=$(git rev-list --count "$last_commit"..HEAD 2>/dev/null || echo "unknown")
        
        # Check if current state is different from last commit
        local diff_with_last
        diff_with_last=$(git diff "$last_commit" -- "$path" 2>/dev/null)
        
        if [[ -z "$diff_with_last" ]]; then
          # Current state matches last commit, try to find first different commit
          local first_different
          if first_different=$(gdiff_determine_commit_find_first_different "$path"); then
            local first_different_info
            first_different_info=$(git log -1 --format="%h %s" "$first_different" 2>/dev/null || echo "unknown commit")
            
            local commits_to_first_different
            commits_to_first_different=$(git rev-list --count "$first_different"..HEAD 2>/dev/null || echo "unknown")
            
            echo "Note: Current state matches the last commit that modified this path." >&2
            echo "      First commit with different content: $first_different_info" >&2
            if [[ "$commits_to_first_different" != "unknown" ]]; then
              echo "      ($commits_to_first_different commits ago)" >&2
            fi
            echo "      Consider using: gdiff '$path' $first_different" >&2
          else
            echo "Note: Current state matches recent commits for this path." >&2
            echo "      No significantly different commits found in recent history." >&2
          fi
        else
          # Current state is different from last commit (normal case)
          echo "Note: Commit $commit ($specified_info) didn't modify this path." >&2
          echo "      Last commit affecting '$path': $last_info" >&2
          if [[ "$commits_to_last" != "unknown" && "$commits_to_last" -gt 0 ]]; then
            echo "      ($commits_to_last commits ago)" >&2
          fi
          echo "      Consider using: gdiff '$path' (auto-detect) or gdiff '$path' $last_commit" >&2
        fi
        echo "" >&2
      fi
    fi
  fi
  
  echo "$commit"
}