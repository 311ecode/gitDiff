#!/usr/bin/env bash
# Tests argument order flexibility
# Verifies that gdiff accepts both "commit path" and "path commit" argument orders

testGdiffArgumentOrder() {
        echo "🧪 Testing argument order flexibility"
        
        if ! setupTestRepo; then
            echo "❌ ERROR: Failed to setup test repo"
            return 1
        fi

        # Make a commit and modify file
        echo "content" > example.txt
        git add example.txt
        git commit -m "Add example" --quiet
        
        echo "modified" > example.txt
        
        # Test both orders: commit path and path commit
        if gdiff ~1 example.txt > /dev/null 2>&1 && gdiff example.txt ~1 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Both argument orders work"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Argument order flexibility failed"
            cleanupTestRepo
            return 1
        fi
    }