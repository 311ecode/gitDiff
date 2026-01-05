gdiff_determine_commit_find_last_commit() {
  local commit="$1"
  local path="$2"

  [[ -n ${DEBUG:-} ]] &&
    echo "DEBUG: Finding last commit for '$path'..." >&2

  # Convert absolute path to relative path for git log if needed
  local git_path="$path"
  if [[ $path =~ ^/ ]]; then
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n $git_root && $path =~ ^"$git_root" ]]; then
      # Convert absolute path to relative path from git root
      git_path="${path#$git_root/}"
      # Remove leading slash if it exists
      git_path="${git_path#/}"
      [[ -n ${DEBUG:-} ]] &&
        echo "DEBUG: Converted absolute path '$path' to git-relative path '$git_path'" >&2
    else
      [[ -n ${DEBUG:-} ]] &&
        echo "DEBUG: Absolute path '$path' is outside git repository" >&2
    fi
  fi

  local lastCommit
  lastCommit=$(git log -1 --format=%H -- "$git_path" 2>/dev/null)
  if [[ -n $lastCommit ]]; then
    commit="$lastCommit"
    [[ -n ${DEBUG:-} ]] &&
      echo "DEBUG: Using last commit: $commit for path '$git_path'" >&2
  else
    if [[ ! -e $path ]]; then
      echo "Error: Path '$path' does not exist" >&2
      return 1
    fi
    # Uncommitted/new path → compare against HEAD (not HEAD~1)
    commit="HEAD"
    [[ -n ${DEBUG:-} ]] &&
      echo "DEBUG: No history found for '$git_path'; fallback to $commit" >&2
  fi

  echo "$commit"
}
