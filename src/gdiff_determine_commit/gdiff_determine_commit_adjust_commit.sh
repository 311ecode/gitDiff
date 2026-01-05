gdiff_determine_commit_adjust_commit() {
  local commit="$1"

  # Expand ~N → HEAD~N
  if [[ $commit =~ ^~[0-9]+$ ]]; then
    commit="HEAD${commit}"
    [[ -n ${DEBUG:-} ]] &&
      echo "DEBUG: Expanded to $commit" >&2
  fi

  # Handle default when HEAD~1 isn't available (shallow repo)
  if [[ $commit == "HEAD~1" ]] &&
    ! git rev-parse --verify -q "$commit" >/dev/null; then
    commit="HEAD"
    [[ -n ${DEBUG:-} ]] &&
      echo "DEBUG: HEAD~1 not available; using HEAD" >&2
  fi

  # Clamp too-deep ancestry (HEAD~N) to repo history depth
  if ! git rev-parse --verify -q "$commit" >/dev/null; then
    if [[ $commit =~ ^HEAD~([0-9]+)$ ]]; then
      local wantN="${BASH_REMATCH[1]}"
      local count
      count=$(git rev-list --count HEAD 2>/dev/null || echo 1)
      local maxN=$((count > 0 ? count - 1 : 0))
      if ((wantN > maxN)); then
        if ((maxN <= 0)); then
          commit="HEAD"
        else
          commit="HEAD~$maxN"
        fi
        [[ -n ${DEBUG:-} ]] &&
          echo "DEBUG: Clamped to existing $commit" >&2
      fi
    fi
  fi

  echo "$commit"
}
