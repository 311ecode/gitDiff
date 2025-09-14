#!/usr/bin/env bash
testGdiffAbsolutePathSymlinks() {
    echo "Testing absolute paths with symlinks"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create file and symlink
    mkdir -p data
    echo "data content" > data/file.txt
    ln -s data/file.txt linked_file.txt
    git add data/ linked_file.txt
    git commit -m "Add data and symlink" --quiet
    
    echo "modified data" > data/file.txt
    
    # Get absolute paths
    local abs_original=$(realpath data/file.txt)
    local abs_symlink=$(realpath linked_file.txt)
    
    # Test both absolute paths
    if gdiff "$abs_original" > /dev/null 2>&1 && gdiff "$abs_symlink" > /dev/null 2>&1; then
        echo "SUCCESS: Absolute paths work with symlinks"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Absolute paths with symlinks failed"
        cleanupTestRepo
        return 1
    fi
}