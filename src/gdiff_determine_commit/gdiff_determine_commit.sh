gdiff_determine_commit() {
  local commit="$1"
  local path="$2"
  local useLastCommit="$3"
  local was_auto_detected="false"

  # Handle path-aware numeric shortcuts
  if [[ $useLastCommit =~ ^nth_different:([0-9]+)$ ]]; then
    local nth="${BASH_REMATCH[1]}"
    local nth_commit
    if nth_commit=$(gdiff_determine_commit_find_nth_different "$path" "$nth"); then
      commit="$nth_commit"
      was_auto_detected="nth_different"
      [[ -n ${DEBUG:-} ]] &&
        echo "DEBUG: Using ${nth}th different commit: $commit" >&2
    else
      echo "Error: Could not find ${nth}th different commit for path '$path'" >&2
      return 1
    fi
  # Auto-detect last commit for a specific path
  elif [[ $useLastCommit == true && $path != "." ]]; then
    local tmpCommit
    if ! tmpCommit=$(
      gdiff_determine_commit_find_last_commit "$commit" "$path"
    ); then
      # Propagate failure when path doesn't exist (exit 1)
      return 1
    fi
    commit="$tmpCommit"
    was_auto_detected="true"
  else
    # Validate that the specified commit actually touched the path (if not auto-detected)
    if [[ $path != "." ]]; then
      commit=$(gdiff_determine_commit_validate_commit "$commit" "$path")
    fi
  fi

  commit=$(gdiff_determine_commit_adjust_commit "$commit")

  # Show gap information
  if [[ $was_auto_detected == "nth_different" ]]; then
    local nth="${useLastCommit#nth_different:}"
    local commit_info
    commit_info=$(git log -1 --format="%h (%ar) %s" "$commit" 2>/dev/null || echo "unknown")
    local commits_to_commit
    commits_to_commit=$(git rev-list --count "$commit"..HEAD 2>/dev/null || echo "unknown")

    echo "Using ${nth}th different commit for this path:" >&2
    echo "  $commit_info" >&2
    if [[ $commits_to_commit != "unknown" && $commits_to_commit -gt 0 ]]; then
      echo "  ($commits_to_commit commits ago)" >&2
    fi
    echo "" >&2
  else
    gdiff_determine_commit_show_gap_info "$commit" "$path" "$was_auto_detected"
  fi

  echo "$commit"
}
