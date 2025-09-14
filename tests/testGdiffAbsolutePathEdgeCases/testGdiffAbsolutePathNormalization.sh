#!/usr/bin/env bash
testGdiffAbsolutePathNormalization() {
    echo "Testing absolute path normalization"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create nested structure
    mkdir -p a/b/c
    echo "nested content" > a/b/c/file.txt
    git add a/
    git commit -m "Add nested structure" --quiet
    
    echo "modified nested" > a/b/c/file.txt
    
    # Test various forms of absolute paths
    local repo_root=$(pwd)
    local normal_abs="$repo_root/a/b/c/file.txt"
    local redundant_abs="$repo_root/a/./b/../b/c/file.txt"
    
    if gdiff "$normal_abs" > /dev/null 2>&1 && gdiff "$redundant_abs" > /dev/null 2>&1; then
        echo "SUCCESS: Path normalization works for absolute paths"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Path normalization failed"
        cleanupTestRepo
        return 1
    fi
}