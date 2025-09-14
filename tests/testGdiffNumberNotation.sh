#!/usr/bin/env bash
testGdiffNumberNotation() {
        echo "🧪 Testing number-only commit references"
        
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
        
        # Test number notation
        if gdiff 1 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Number notation works"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Number notation failed"
            cleanupTestRepo
            return 1
        fi
    }