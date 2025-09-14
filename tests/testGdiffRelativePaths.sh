#!/usr/bin/env bash
# Tests relative path resolution functionality
# Verifies that gdiff correctly handles relative paths from different working directories

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

testGdiffRelativePathWithCommit() {
    echo "Testing relative path with commit reference"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create structure
    mkdir -p subdir
    echo "initial" > subdir/file.txt
    git add subdir/
    git commit -m "Add subdir" --quiet
    
    echo "commit2" > subdir/file.txt
    git add subdir/file.txt
    git commit -m "Modify subdir" --quiet
    
    echo "current" > subdir/file.txt
    
    # Move to root and test relative path with commit
    if gdiff subdir 2 > /dev/null 2>&1 && gdiff 2 subdir > /dev/null 2>&1; then
        echo "SUCCESS: Relative path with commit works from root"
        
        # Move to subdirectory and test
        cd subdir || return 1
        if gdiff . 2 > /dev/null 2>&1; then
            echo "SUCCESS: Current directory reference works from subdirectory"
            cleanupTestRepo
            return 0
        else
            echo "ERROR: Current directory reference failed from subdirectory"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Relative path with commit failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffRelativePathNumericShortcut() {
    echo "Testing numeric shortcut vs relative path priority"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Make multiple commits
    echo "commit1" > file1.txt
    git add file1.txt
    git commit -m "Commit 1" --quiet
    
    echo "commit2" > file2.txt
    git add file2.txt
    git commit -m "Commit 2" --quiet
    
    # Create directory structure
    mkdir -p a
    cd a || return 1
    
    # Create a directory named "2" inside a/
    mkdir -p 2
    echo "content" > 2/file.txt
    git add 2/
    git commit -m "Add a/2 directory" --quiet
    
    echo "modified" > 2/file.txt
    
    # From a/, "2" should refer to the local directory "./2"
    if gdiff 2 > /dev/null 2>&1; then
        local diff_output
        diff_output=$(gdiff 2)
        if echo "$diff_output" | grep -q "file.txt"; then
            echo "SUCCESS: Local path '2' takes priority over numeric shortcut"
            
            # Test that explicit ~2 still works as commit
            if gdiff ~2 > /dev/null 2>&1; then
                echo "SUCCESS: Explicit ~2 still works as commit reference"
                cleanupTestRepo
                return 0
            else
                echo "ERROR: Explicit ~2 failed"
                cleanupTestRepo
                return 1
            fi
        else
            echo "ERROR: Directory '2' diff doesn't show expected content"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Local directory '2' reference failed"
        cleanupTestRepo
        return 1
    fi
}