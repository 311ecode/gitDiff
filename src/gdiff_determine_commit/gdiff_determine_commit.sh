gdiff_determine_commit() {
  local commit="$1"
  local path="$2"
  local useLastCommit="$3"
  local was_auto_detected="false"

  # Auto-detect last commit for a specific path
  if [[ "$useLastCommit" == true && "$path" != "." ]]; then
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
    if [[ "$path" != "." ]]; then
      commit=$(gdiff_determine_commit_validate_commit "$commit" "$path")
    fi
  fi

  commit=$(gdiff_determine_commit_adjust_commit "$commit")
  
  # Show gap information
  gdiff_determine_commit_show_gap_info "$commit" "$path" "$was_auto_detected"

  echo "$commit"
}