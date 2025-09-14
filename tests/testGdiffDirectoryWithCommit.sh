#!/usr/bin/env bash
# Tests directory diff with specific commit references
# Verifies that gdiff can diff specific directories against specific commits

testGdiffDirectoryWithCommit() {
    echo "🧪 Testing directory diff with specific commit references"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Create directory structure
    mkdir -p src/utils src/components
    
    # Initial commit for utils
    echo "utils v1" > src/utils/helpers.js
    git add src/utils/helpers.js
    git commit -m "Add utils helpers" --quiet
    
    # Commit for components
    echo "components v1" > src/components/button.js
    git add src/components/button.js
    git commit -m "Add components" --quiet
    
    # Modify files
    echo "utils v2" > src/utils/helpers.js
    echo "components v2" > src/components/button.js
    
    # Test directory diff with commit reference
    if gdiff src/utils ~1 > /dev/null 2>&1 && gdiff ~1 src/utils > /dev/null 2>&1; then
        echo "✅ SUCCESS: Directory diff with commit reference works"
        
        # Test that we can diff specific directory against specific commit
        local utils_diff=$(gdiff src/utils HEAD~1)
        if [[ -n "$utils_diff" ]]; then
            echo "✅ SUCCESS: Directory diff against specific commit shows changes"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Directory diff against commit shows no changes"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: Directory diff with commit reference failed"
        cleanupTestRepo
        return 1
    fi
}