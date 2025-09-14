#!/usr/bin/env bash
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