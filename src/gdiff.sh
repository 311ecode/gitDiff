gdiff() {
  # Check if we're in a git repository
  if ! git rev-parse --git-dir >/dev/null 2>&1; then
    echo "Error: Not in a git repository" >&2
    return 1
  fi

  local commit="HEAD~1"         # default: previous commit
  local path="."                # default: current directory
  local useLastCommit=false

  if [[ -n "${DEBUG:-}" ]]; then
    echo "DEBUG: Starting gdiff with $# args: $*" >&2
  fi

  # Parse arguments and determine commit/path values
  gdiff_parse_args "$@"

  # Determine the appropriate commit to use
  local determinedCommit
  if ! determinedCommit=$(gdiff_determine_commit "$commit" "$path" "$useLastCommit"); then
    return 1  # Propagate error from gdiff_determine_commit
  fi
  commit="$determinedCommit"

  # Final debug and execute
  if [[ -n "${DEBUG:-}" ]]; then
    echo "DEBUG: Final - commit: '$commit', path: '$path'" >&2
    echo "DEBUG: Executing: git diff \"$commit\" -- \"$path\"" >&2
  fi

  git diff "$commit" -- "$path"
  local exitStatus=$?

  [[ -n "${DEBUG:-}" ]] && \
    echo "DEBUG: git diff exit: $exitStatus" >&2
  return $exitStatus
}