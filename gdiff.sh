gdiff() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    local commit="HEAD~1"  # Default to previous commit
    local path="."         # Default to current directory
    local use_last_commit=false
    
    # Debug output if DEBUG is set
    if [[ -n "${DEBUG:-}" ]]; then
        echo "DEBUG: Starting gdiff with $# arguments: $*" >&2
    fi
    
    # Parse arguments
    if [[ $# -gt 0 ]]; then
        # Check if first argument is a commit reference (starts with ~, HEAD, or looks like a hash)
        if [[ "$1" =~ ^(~[0-9]*|HEAD([~^][0-9]*)?|[0-9a-fA-F]+)$ ]]; then
            commit="$1"
            # If there's a second argument, use it as path
            if [[ $# -gt 1 ]]; then
                path="$2"
                # If path is specified (not default), use last commit for that path
                use_last_commit=true
            fi
        else
            # First argument is a path
            path="$1"
            use_last_commit=true  # Path specified, use last commit for that path
            
            # If there's a second argument that looks like a commit, use it instead of last commit
            if [[ $# -gt 1 ]] && [[ "$2" =~ ^(~[0-9]*|HEAD([~^][0-9]*)?|[0-9a-fA-F]+)$ ]]; then
                commit="$2"
                use_last_commit=false  # Explicit commit provided, don't use last commit
            fi
        fi
    fi

    # If we should use the last commit for the specified path
    if [[ "$use_last_commit" == true && "$path" != "." ]]; then
        local last_commit
        last_commit=$(git log -1 --format=%H -- "$path" 2>/dev/null)
        if [[ -n "$last_commit" ]]; then
            commit="$last_commit"
            if [[ -n "${DEBUG:-}" ]]; then
                echo "DEBUG: Using last commit for '$path': $commit" >&2
            fi
        else
            # No commits found for this path, check if path exists
            if [[ ! -e "$path" ]]; then
                echo "Error: Path '$path' does not exist" >&2
                return 1
            fi
            if [[ -n "${DEBUG:-}" ]]; then
                echo "DEBUG: No commits found for path '$path', using default commit" >&2
            fi
        fi
    fi

    # Expand relative commit references like ~2 to HEAD~2
    if [[ "$commit" =~ ^~[0-9]*$ ]]; then
        commit="HEAD${commit}"
        if [[ -n "${DEBUG:-}" ]]; then
            echo "DEBUG: Expanded commit reference to: $commit" >&2
        fi
    fi

    # Debug output if DEBUG is set
    if [[ -n "${DEBUG:-}" ]]; then
        echo "DEBUG: Final parameters - commit: '$commit', path: '$path'" >&2
        echo "DEBUG: Executing: git diff \"$commit\" -- \"$path\"" >&2
    fi

    # Execute git diff
    git diff "$commit" -- "$path"
    
    # Debug exit status
    if [[ -n "${DEBUG:-}" ]]; then
        local exit_status=$?
        echo "DEBUG: git diff exited with status: $exit_status" >&2
        return $exit_status
    fi
}