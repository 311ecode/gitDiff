gdiff() {
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "Error: Not in a git repository" >&2
        return 1
    fi

    local commit="HEAD~1"  # Default to previous commit
    local path="."         # Default to current directory
    
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
            fi
        else
            # First argument is a path
            path="$1"
            # If there's a second argument that looks like a commit, use it
            if [[ $# -gt 1 ]] && [[ "$2" =~ ^(~[0-9]*|HEAD([~^][0-9]*)?|[0-9a-fA-F]+)$ ]]; then
                commit="$2"
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