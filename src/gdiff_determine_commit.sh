gdiff_determine_commit() {
  local commit="$1"
  local path="$2"
  local useLastCommit="$3"

  # Auto-detect last commit for specific path
  if [[ "$useLastCommit" == true && "$path" != "." ]]; then
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: Finding last commit for '$path'..." >&2
    local lastCommit
    lastCommit=$(git log -1 --format=%H -- "$path" 2>/dev/null)
    if [[ -n "$lastCommit" ]]; then
      commit="$lastCommit"
      [[ -n "${DEBUG:-}" ]] && \
        echo "DEBUG: Using last commit: $commit" >&2
    else
      if [[ ! -e "$path" ]]; then
        echo "Error: Path '$path' does not exist" >&2
        return 1  # Fix: Return error code 1 for non-existent paths
      fi
      # Uncommitted/new path → compare against HEAD (not HEAD~1)
      commit="HEAD"
      [[ -n "${DEBUG:-}" ]] && \
        echo "DEBUG: No history; fallback to $commit" >&2
    fi
  fi

  # Expand ~N → HEAD~N
  if [[ "$commit" =~ ^~[0-9]+$ ]]; then
    commit="HEAD${commit}"
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: Expanded to $commit" >&2
  fi

  # Handle default commit when HEAD~1 doesn't exist (shallow repo)
  if [[ "$commit" == "HEAD~1" ]] && ! git rev-parse --verify -q "$commit" >/dev/null; then
    commit="HEAD"
    [[ -n "${DEBUG:-}" ]] && \
      echo "DEBUG: HEAD~1 not available; using HEAD" >&2
  fi

  # Clamp too-deep ancestry (HEAD~N) to repo history depth
  if ! git rev-parse --verify -q "$commit" >/dev/null; then
    if [[ "$commit" =~ ^HEAD~([0-9]+)$ ]]; then
      local wantN="${BASH_REMATCH[1]}"
      local count
      count=$(git rev-list --count HEAD 2>/dev/null || echo 1)
      local maxN=$(( count > 0 ? count - 1 : 0 ))
      if (( wantN > maxN )); then
        if (( maxN <= 0 )); then
          commit="HEAD"
        else
          commit="HEAD~$maxN"
        fi
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Clamped to existing $commit" >&2
      fi
    fi
  fi

  echo "$commit"
}