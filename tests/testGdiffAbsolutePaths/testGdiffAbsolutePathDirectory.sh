#!/usr/bin/env bash
testGdiffAbsolutePathDirectory() {
    echo "Testing absolute path for directories"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create directory structure
    mkdir -p project/src
    echo "index content" > project/src/index.js
    echo "utils content" > project/src/utils.js
    git add project/
    git commit -m "Add project" --quiet
    
    # Modify files
    echo "modified index" > project/src/index.js
    echo "modified utils" > project/src/utils.js
    
    # Get absolute path to directory
    local abs_dir_path=$(realpath project/src)
    
    # Test absolute directory path
    if gdiff "$abs_dir_path" > /dev/null 2>&1; then
        local diff_output
        diff_output=$(gdiff "$abs_dir_path")
        if echo "$diff_output" | grep -q "index.js" && echo "$diff_output" | grep -q "utils.js"; then
            echo "SUCCESS: Absolute directory path shows changes for all files"
            cleanupTestRepo
            return 0
        else
            echo "ERROR: Absolute directory path missing some file changes"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Absolute directory path failed"
        cleanupTestRepo
        return 1
    fi
}