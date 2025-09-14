#!/usr/bin/env bash
testGdiffHeadNotation() {
        echo "🧪 Testing HEAD notation variants"
        
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
        
        # Test HEAD~ notation
        if gdiff HEAD~1 > /dev/null 2>&1 && gdiff HEAD~2 > /dev/null 2>&1; then
            echo "✅ SUCCESS: HEAD~ notation works"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: HEAD~ notation failed"
            cleanupTestRepo
            return 1
        fi
    }