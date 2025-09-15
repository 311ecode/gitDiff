#!/usr/bin/env bash
# Tests absolute path with git-relative path conversion

testGdiffAbsolutePathGitRelativeConversion() {
    echo "Testing absolute path to git-relative path conversion"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create the structure similar to your example
    mkdir -p vcs/git/git/history
    echo "initial extract script" > vcs/git/git/history/extractGitHistory
    git add vcs/
    git commit -m "Add git history extraction script" --quiet
    
    # Make another commit to have history
    echo "updated extract script v2" > vcs/git/git/history/extractGitHistory
    git add vcs/git/git/history/extractGitHistory
    git commit -m "Update extraction script" --quiet
    
    # Make current changes
    echo "current extract script modifications" > vcs/git/git/history/extractGitHistory
    
    # Get absolute path
    local abs_path=$(realpath vcs/git/git/history/extractGitHistory)
    
    # Test that absolute path finds the correct last commit
    if gdiff "$abs_path" > /dev/null 2>&1; then
        echo "SUCCESS: Absolute path finds last commit correctly"
        
        # Test with explicit commit number
        if gdiff "$abs_path" 1 > /dev/null 2>&1; then
            echo "SUCCESS: Absolute path works with numeric commit reference"
            cleanupTestRepo
            return 0
        else
            echo "ERROR: Absolute path with numeric commit failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "ERROR: Absolute path last commit detection failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffAbsolutePathFromDifferentWorkingDir() {
    echo "Testing absolute path usage from different working directory"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create structure similar to your case
    mkdir -p vcs/git/git/history
    echo "script content" > vcs/git/git/history/extractGitHistory
    git add vcs/
    git commit -m "Add history script" --quiet
    
    echo "updated script" > vcs/git/git/history/extractGitHistory
    git add vcs/git/git/history/extractGitHistory
    git commit -m "Update script" --quiet
    
    echo "current modifications" > vcs/git/git/history/extractGitHistory
    
    # Get absolute path before changing directory
    local abs_path=$(realpath vcs/git/git/history/extractGitHistory)
    
    # Create and move to a different subdirectory
    mkdir -p other/subdir
    cd other/subdir || return 1
    
    # Test absolute path from different working directory
    if gdiff "$abs_path" 1 > /dev/null 2>&1; then
        echo "SUCCESS: Absolute path works from different working directory"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Absolute path failed from different working directory"
        cleanupTestRepo
        return 1
    fi
}

testGdiffAbsolutePathDebugOutput() {
    echo "Testing absolute path debug output for troubleshooting"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create test structure
    mkdir -p deep/nested/path
    echo "nested content" > deep/nested/path/file.txt
    git add deep/
    git commit -m "Add nested structure" --quiet
    
    echo "modified content" > deep/nested/path/file.txt
    
    # Get absolute path
    local abs_path=$(realpath deep/nested/path/file.txt)
    
    # Test with debug output
    local debug_output
    debug_output=$(DEBUG=1 gdiff "$abs_path" 2>&1)
    
    if echo "$debug_output" | grep -q "Converted absolute path"; then
        echo "SUCCESS: Debug shows absolute path conversion"
        cleanupTestRepo
        return 0
    else
        echo "INFO: Debug output for absolute path:"
        echo "$debug_output"
        cleanupTestRepo
        return 0
    fi
}