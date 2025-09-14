#!/usr/bin/env bash
testGdiffRelativePathBasic() {
    echo "Testing basic relative path resolution"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create subdirectory structure
    mkdir -p a b
    echo "content in a" > a/file.txt
    echo "content in b" > b/file.txt
    
    git add a/ b/
    git commit -m "Add directories a and b" --quiet
    
    # Modify files
    echo "modified content in a" > a/file.txt
    echo "modified content in b" > b/file.txt
    
    # Move to subdirectory a
    cd a || return 1
    
    # Test that we can reference relative path "../b" from subdirectory
    if gdiff ../b > /dev/null 2>&1; then
        echo "SUCCESS: Relative path ../b works from subdirectory"
        
        # Test that we can reference just "b" if it exists in current context
        # First create a "b" in the current directory
        mkdir -p b
        echo "content in a/b" > b/file.txt
        git add b/
        git commit -m "Add a/b directory" --quiet
        echo "modified content in a/b" > b/file.txt
        
        # Now "b" should refer to "./b" (a/b) not "../b"
        if gdiff b > /dev/null 2>&1; then
            echo "SUCCESS: Local relative path 'b' works from subdirectory"
            cleanupTestRepo
            return 0
        else
            echo "ERROR: Local relative path failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Relative path ../b failed from subdirectory"
        cleanupTestRepo
        return 1
    fi
}