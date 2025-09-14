#!/usr/bin/env bash
# Tests nested directory diff functionality
# Verifies that gdiff works correctly with deeply nested directory structures

testGdiffNestedDirectories() {
    echo "🧪 Testing nested directory diff functionality"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Create nested directory structure
    mkdir -p project/src/components/ui
    mkdir -p project/src/utils
    
    # Add files at different levels
    echo "root file" > project/readme.md
    echo "src file" > project/src/index.js
    echo "components file" > project/src/components/app.js
    echo "ui file" > project/src/components/ui/button.js
    echo "utils file" > project/src/utils/helpers.js
    
    git add project/
    git commit -m "Add project structure" --quiet
    
    # Modify files at different levels
    echo "root modified" > project/readme.md
    echo "src modified" > project/src/index.js
    echo "components modified" > project/src/components/app.js
    echo "ui modified" > project/src/components/ui/button.js
    echo "utils modified" > project/src/utils/helpers.js
    
    # Test diff at different directory levels
    if gdiff project > /dev/null 2>&1 && \
       gdiff project/src > /dev/null 2>&1 && \
       gdiff project/src/components > /dev/null 2>&1 && \
       gdiff project/src/components/ui > /dev/null 2>&1 && \
       gdiff project/src/utils > /dev/null 2>&1; then
        echo "✅ SUCCESS: Nested directory diff works at all levels"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Nested directory diff failed"
        cleanupTestRepo
        return 1
    fi
}