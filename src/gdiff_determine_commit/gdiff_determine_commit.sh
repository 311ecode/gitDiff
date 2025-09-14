gdiff_determine_commit() {
  local commit="$1"
  local path="$2"
  local useLastCommit="$3"

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
  fi

  commit=$(gdiff_determine_commit_adjust_commit "$commit")

  echo "$commit"
}

