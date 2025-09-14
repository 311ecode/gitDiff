#!/usr/bin/env bash
testGdiffAbsolutePathFromSubdirectory() {
    echo "Testing absolute path usage from subdirectory"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create structure
    mkdir -p a b
    echo "content in a" > a/file.txt
    echo "content in b" > b/file.txt
    git add a/ b/
    git commit -m "Add directories" --quiet
    
    # Modify files
    echo "modified a" > a/file.txt
    echo "modified b" > b/file.txt
    
    # Get absolute paths before changing directory
    local abs_a_path=$(realpath a/file.txt)
    local abs_b_path=$(realpath b/file.txt)
    
    # Move to subdirectory a
    cd a || return 1
    
    # Test absolute paths from subdirectory
    if gdiff "$abs_a_path" > /dev/null 2>&1 && gdiff "$abs_b_path" > /dev/null 2>&1; then
        echo "SUCCESS: Absolute paths work from subdirectory"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Absolute paths failed from subdirectory"
        cleanupTestRepo
        return 1
    fi
}