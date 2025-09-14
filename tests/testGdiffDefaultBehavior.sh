#!/usr/bin/env bash
testGdiffDefaultBehavior() {
        echo "🧪 Testing default behavior (no arguments)"
        
        if ! setupTestRepo; then
            echo "❌ ERROR: Failed to setup test repo"
            return 1
        fi

        # Make a change
        echo "modified content" > testfile.txt
        
        # Test gdiff with no args
        local result
        if result=$(gdiff 2>&1); then
            echo "✅ SUCCESS: gdiff executed without errors"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: gdiff failed: $result"
            cleanupTestRepo
            return 1
        fi
    }