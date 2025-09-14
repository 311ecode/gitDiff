#!/usr/bin/env bash
# Tests error handling when not in a git repository
# Verifies that gdiff correctly detects and reports non-git repository environments

testGdiffNotGitRepo() {
        echo "🧪 Testing error handling (not a git repo)"
        
        local temp_dir=$(mktemp -d)
        cd "$temp_dir" || return 1
        
        # Test in non-git directory
        local result
        if result=$(gdiff 2>&1); then
            echo "❌ ERROR: Should have failed in non-git repo"
            rm -rf "$temp_dir"
            return 1
        else
            if echo "$result" | grep -q "Not in a git repository"; then
                echo "✅ SUCCESS: Correctly detected non-git repo"
                rm -rf "$temp_dir"
                return 0
            else
                echo "❌ ERROR: Unexpected error message: $result"
                rm -rf "$temp_dir"
                return 1
            fi
        fi
    }