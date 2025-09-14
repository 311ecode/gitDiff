#!/usr/bin/env bash
testGdiffAbsolutePathNumericConflict() {
    echo "Testing absolute path vs numeric shortcut conflict resolution"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create commits
    echo "commit1" > file1.txt
    git add file1.txt
    git commit -m "Commit 1" --quiet
    
    echo "commit2" > file2.txt
    git add file2.txt
    git commit -m "Commit 2" --quiet
    
    # Create a file named "2" in the repo
    echo "file named 2" > 2
    git add 2
    git commit -m "Add file named 2" --quiet
    
    echo "modified file 2" > 2
    
    # Get absolute path to the file named "2"
    local abs_path_2=$(realpath 2)
    
    # Test that absolute path to file "2" works
    if gdiff "$abs_path_2" > /dev/null 2>&1; then
        echo "SUCCESS: Absolute path to file named '2' works"
        
        # Test that relative "2" still works as path
        if gdiff 2 > /dev/null 2>&1; then
            echo "SUCCESS: Relative '2' still works as path"
            
            # Test that in a directory without file "2", numeric "2" works as commit
            mkdir -p subdir
            cd subdir || return 1
            if gdiff 2 > /dev/null 2>&1; then
                echo "SUCCESS: Numeric '2' works as commit in directory without file '2'"
                cleanupTestRepo
                return 0
            else
                echo "ERROR: Numeric shortcut failed in subdirectory"
                cleanupTestRepo
                return 1
            fi
        else
            echo "ERROR: Relative file '2' failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Absolute path to file '2' failed"
        cleanupTestRepo
        return 1
    fi
}