#!/usr/bin/env bash
testGdiffPathArgument() {
        echo "🧪 Testing path argument handling"
        
        if ! setupTestRepo; then
            echo "❌ ERROR: Failed to setup test repo"
            return 1
        fi

        # Create a file and modify it
        mkdir -p src
        echo "source code" > src/utils.js
        git add src/utils.js
        git commit -m "Add source file" --quiet
        
        echo "modified code" > src/utils.js
        
        # Test path argument
        if gdiff src/utils.js > /dev/null 2>&1; then
            echo "✅ SUCCESS: Path argument works"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Path argument failed"
            cleanupTestRepo
            return 1
        fi
    }