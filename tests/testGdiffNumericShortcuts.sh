#!/usr/bin/env bash
# Tests numeric shortcut functionality (N vs ~N)
# Verifies that bare numbers are treated as commit shortcuts unless a path with that name exists

testGdiffNumericShortcutBasic() {
    echo "🧪 Testing basic numeric shortcut functionality"
    
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
    
    echo "commit3" > file3.txt
    git add file3.txt
    git commit -m "Commit 3" --quiet
    
    # Modify a file
    echo "modified" > file1.txt
    
    # Test that bare number works as commit shortcut
    if gdiff 2 > /dev/null 2>&1; then
        echo "✅ SUCCESS: Bare number '2' works as commit shortcut (HEAD~2)"
        
        # Test different numbers
        if gdiff 1 > /dev/null 2>&1 && gdiff 3 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Multiple numeric shortcuts work"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Multiple numeric shortcuts failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: Numeric shortcut failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffNumericShortcutWithPath() {
    echo "🧪 Testing numeric shortcut with path argument"
    
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
    
    # Test numeric shortcut with path
    if gdiff 2 file1.txt > /dev/null 2>&1 && gdiff file1.txt 2 > /dev/null 2>&1; then
        echo "✅ SUCCESS: Numeric shortcut works with path in both orders"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Numeric shortcut with path failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffNumericShortcutPathPriority() {
    echo "🧪 Testing path priority over numeric shortcut"
    
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
    
    # Create a directory named with a number
    mkdir -p 2
    echo "content in dir 2" > 2/content.txt
    git add 2/
    git commit -m "Add directory 2" --quiet
    
    # Modify file in directory 2
    echo "modified content" > 2/content.txt
    
    # Test that '2' is treated as path when it exists
    local diff_output
    diff_output=$(gdiff 2 2>&1)
    local exit_status=$?
    
    if [[ $exit_status -eq 0 ]] && echo "$diff_output" | grep -q "content.txt"; then
        echo "✅ SUCCESS: Existing path '2' takes priority over numeric shortcut"
        
        # Test that explicit ~2 still works as commit
        if gdiff ~2 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Explicit ~2 still works as commit reference"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Explicit ~2 failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: Path priority test failed"
        echo "Exit status: $exit_status"
        echo "Diff output: $diff_output"
        cleanupTestRepo
        return 1
    fi
}

testGdiffNumericShortcutMixedScenarios() {
    echo "🧪 Testing mixed numeric shortcut scenarios"
    
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
    
    echo "commit3" > file3.txt
    git add file3.txt
    git commit -m "Commit 3" --quiet
    
    # Create some files with numeric names that don't exist yet
    echo "commit4" > file4.txt
    git add file4.txt
    git commit -m "Commit 4" --quiet
    
    # Create a file named '1' but not '2' or '3'
    echo "file named 1" > 1
    git add 1
    git commit -m "Add file named 1" --quiet
    
    # Modify files
    echo "modified" > file1.txt
    echo "modified" > 1
    
    # Test various scenarios
    if gdiff 1 > /dev/null 2>&1; then  # Should use path '1'
        echo "✅ SUCCESS: '1' treated as existing path"
        
        if gdiff 2 > /dev/null 2>&1; then  # Should use commit HEAD~2
            echo "✅ SUCCESS: '2' treated as commit shortcut (no path exists)"
            
            if gdiff 3 > /dev/null 2>&1; then  # Should use commit HEAD~3
                echo "✅ SUCCESS: '3' treated as commit shortcut (no path exists)"
                
                # Test mixed with paths
                if gdiff 1 file1.txt 2 > /dev/null 2>&1; then  # path, path, commit
                    echo "✅ SUCCESS: Mixed scenario with existing path and numeric commit works"
                    cleanupTestRepo
                    return 0
                else
                    echo "❌ ERROR: Mixed scenario failed"
                    cleanupTestRepo
                    return 1
                fi
            else
                echo "❌ ERROR: '3' as commit shortcut failed"
                cleanupTestRepo
                return 1
            fi
        else
            echo "❌ ERROR: '2' as commit shortcut failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: '1' as existing path failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffNumericShortcutSecondArgument() {
    echo "🧪 Testing numeric shortcut as second argument"
    
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
    
    # Modify file
    echo "modified" > file1.txt
    
    # Test numeric shortcut as second argument
    if gdiff file1.txt 2 > /dev/null 2>&1; then
        echo "✅ SUCCESS: Numeric shortcut works as second argument"
        
        # Test that this works even if a path named '2' exists elsewhere
        mkdir -p somedir
        echo "content" > somedir/2
        git add somedir/2
        git commit -m "Add somedir/2" --quiet
        
        # Should still treat '2' as commit when it's the second argument after a path
        if gdiff file1.txt 2 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Second argument numeric shortcut prioritizes commit interpretation"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Second argument numeric shortcut failed with existing path elsewhere"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: Numeric shortcut as second argument failed"
        cleanupTestRepo
        return 1
    fi
}

testGdiffNumericShortcutEdgeCases() {
    echo "🧪 Testing numeric shortcut edge cases"
    
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
    
    # Test with zero (edge case)
    echo "modified" > file1.txt
    
    if gdiff 0 > /dev/null 2>&1; then
        echo "✅ SUCCESS: Zero as numeric shortcut works (HEAD~0 = HEAD)"
        
        # Test single digit vs multi-digit
        if gdiff 1 > /dev/null 2>&1 && gdiff 10 > /dev/null 2>&1; then
            echo "✅ SUCCESS: Both single and multi-digit numeric shortcuts work"
            cleanupTestRepo
            return 0
        else
            echo "❌ ERROR: Single/multi-digit numeric shortcuts failed"
            cleanupTestRepo
            return 1
        fi
    else
        echo "❌ ERROR: Zero as numeric shortcut failed"
        cleanupTestRepo
        return 1
    fi
}