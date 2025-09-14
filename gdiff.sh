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

  # ----------------- argument parsing -----------------
  if [[ $# -gt 0 ]]; then
    if [[ -n "${DEBUG:-}" ]]; then
      echo "DEBUG: First arg: '$1'" >&2
    fi

    # 1) Bare number first → may be path or commit shortcut
    if [[ "$1" =~ ^[0-9]+$ ]]; then
      if [[ -n "${DEBUG:-}" ]]; then
        echo "DEBUG: '$1' is number; check path..." >&2
      fi

      if [[ -e "$1" ]]; then
        path="$1"
        useLastCommit=true
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: '$1' exists; treat as path" >&2

        if [[ $# -gt 1 ]]; then
          if [[ "$2" =~ ^(~[0-9]+|HEAD([~^][0-9]*)?|HEAD|[0-9a-fA-F]{7,})$ ]]; then
            commit="$2"
            useLastCommit=false
            [[ -n "${DEBUG:-}" ]] && \
              echo "DEBUG: Second '$2' is commit" >&2
          elif [[ "$2" =~ ^[0-9]+$ ]]; then
            commit="HEAD~$2"
            useLastCommit=false
            [[ -n "${DEBUG:-}" ]] && \
              echo "DEBUG: Second '$2' → $commit" >&2
          fi
        fi
      else
        commit="HEAD~$1"
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: No path '$1'; use $commit" >&2

        if [[ $# -gt 1 ]]; then
          path="$2"
          useLastCommit=true
          [[ -n "${DEBUG:-}" ]] && \
            echo "DEBUG: Second '$2' set as path" >&2
        fi
      fi

    # 2) Standard commit refs (tilde, HEAD, 7+ hex)
    elif [[ "$1" =~ ^(~[0-9]+|HEAD([~^][0-9]*)?|HEAD|[0-9a-fA-F]{7,})$ ]]; then
      commit="$1"
      [[ -n "${DEBUG:-}" ]] && \
        echo "DEBUG: '$1' is commit" >&2
      if [[ $# -gt 1 ]]; then
        path="$2"
        useLastCommit=true
        [[ -n "${DEBUG:-}" ]] && \
          echo "DEBUG: Second '$2' set as path" >&2
      fi

    # 3) Otherwise treat as a regular path
    else
      path="$1"
      useLastCommit=true
      [[ -n "${DEBUG:-}" ]] && \
        echo "DEBUG: '$1' treated as path" >&2

      if [[ $# -gt 1 ]]; then
        if [[ "$2" =~ ^(~[0-9]+|HEAD([~^][0-9]*)?|HEAD|[0-9a-fA-F]{7,})$ ]]; then
          commit="$2"
          useLastCommit=false
          [[ -n "${DEBUG:-}" ]] && \
            echo "DEBUG: Second '$2' is commit" >&2
        elif [[ "$2" =~ ^[0-9]+$ ]]; then
          commit="HEAD~$2"
          useLastCommit=false
          [[ -n "${DEBUG:-}" ]] && \
            echo "DEBUG: Second '$2' → $commit" >&2
        fi
      fi
    fi
  fi
  # ----------------------------------------------------

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
        return 1
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