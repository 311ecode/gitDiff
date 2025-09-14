gdiff_parse_args() {
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
}