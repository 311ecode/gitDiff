gdiff_determine_commit_show_gap_info() {
  local commit="$1"
  local path="$2"
  local was_auto_detected="$3"

  if [[ $path != "." ]]; then
    # Get the last commit that touched this path
    local last_commit
    last_commit=$(git log -1 --format=%H -- "$path" 2>/dev/null)

    if [[ -n $last_commit ]]; then
      local current_commit_hash
      current_commit_hash=$(git rev-parse "$commit" 2>/dev/null)

      # Count commits between the specified commit and HEAD
      local commits_to_head
      commits_to_head=$(git rev-list --count "$commit"..HEAD 2>/dev/null || echo "0")

      # Count commits between last path commit and HEAD
      local commits_to_last
      commits_to_last=$(git rev-list --count "$last_commit"..HEAD 2>/dev/null || echo "0")

      # Get commit info
      local commit_info
      commit_info=$(git log -1 --format="%h (%ar) %s" "$commit" 2>/dev/null || echo "unknown")

      local last_commit_info
      last_commit_info=$(git log -1 --format="%h (%ar) %s" "$last_commit" 2>/dev/null || echo "unknown")

      if [[ $was_auto_detected == "true" ]]; then
        echo "Comparing against last commit that modified this path:" >&2
        echo "  $last_commit_info" >&2
        if [[ $commits_to_last -gt 0 ]]; then
          echo "  ($commits_to_last commits ago)" >&2
        fi
      else
        # Show gap information when using explicit commit
        if [[ $current_commit_hash != "$last_commit" ]]; then
          echo "Comparing against: $commit_info" >&2
          if [[ $commits_to_head -gt 0 ]]; then
            echo "  ($commits_to_head commits from HEAD)" >&2
          fi
          echo "Last change to this path: $last_commit_info" >&2
          if [[ $commits_to_last -gt 0 && $commits_to_last != "$commits_to_head" ]]; then
            echo "  ($commits_to_last commits ago)" >&2
          fi
        else
          echo "Comparing against last commit that modified this path:" >&2
          echo "  $commit_info" >&2
        fi
      fi
      echo "" >&2
    fi
  fi
}
