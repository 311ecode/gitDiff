#!/usr/bin/env bash
# Tests edge cases for automatic last commit detection
# Verifies behavior with non-existent paths, uncommitted files, etc.

testGdiffLastCommitNonExistentPath() {
    echo "🧪 Testing automatic last commit with non-existent path"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Test with non-existent path - should fail
    if gdiff non-existent-path > /dev/null 2>&1; then
        echo "❌ ERROR: Should have failed with non-existent path"
        cleanupTestRepo
        return 1
    else
        local exit_status=$?
        if [[ $exit_status -eq 1 ]]; then
            echo "✅ SUCCESS: Correctly failed with non-existent path (exit status: $exit_status)"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Wrong exit status for non-existent path: $exit_status (expected 1)"
            cleanupTestRepo
            return 1
        fi
    fi
}

testGdiffLastCommitUncommittedFile() {
    echo "🧪 Testing automatic last commit with uncommitted file"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Create but don't commit a file
    echo "uncommitted" > newfile.txt
    
    # Test with uncommitted file (should fall back to default commit and work)
    if gdiff newfile.txt > /dev/null 2>&1; then
        echo "✅ SUCCESS: Handled uncommitted file gracefully"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Failed with uncommitted file"
        cleanupTestRepo
        return 1
    fi
}

testGdiffLastCommitDefaultPath() {
    echo "🧪 Testing that default path (.) doesn't trigger last commit detection"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Make multiple commits
    echo "commit1" > file1.txt
    git add file1.txt
    git commit -m "Commit 1" --quiet
    
    echo "commit2" > file2.txt
    git add file2.txt
    git commit -m "Commit 2" --quiet
    
    # Modify files
    echo "modified1" > file1.txt
    echo "modified2" > file2.txt
    
    # Test that default path (.) uses default commit, not last commit detection
    # This should show changes from both files since we're diffing the whole repo
    local diff_output
    diff_output=$(gdiff 2>&1)
    local exit_status=$?
    
    if [[ $exit_status -eq 0 ]] && \
       echo "$diff_output" | grep -q "file1.txt" && \
       echo "$diff_output" | grep -q "file2.txt"; then
        echo "✅ SUCCESS: Default path uses default commit behavior"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Default path behavior incorrect"
        echo "Diff output: $diff_output"
        echo "Exit status: $exit_status"
        cleanupTestRepo
        return 1
    fi
}