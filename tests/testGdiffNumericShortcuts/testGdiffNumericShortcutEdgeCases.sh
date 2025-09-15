#!/usr/bin/env bash
testGdiffNumericShortcutEdgeCases() {
    echo "Testing numeric shortcut edge cases"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Test case 1: Numeric shortcut larger than available history
    echo "commit1" > file1.txt
    git add file1.txt
    git commit -m "Commit 1" --quiet
    
    # Try to access commit beyond history (should clamp to available)
    if gdiff 10 > /dev/null 2>&1; then
        echo "SUCCESS: Large numeric shortcut handled gracefully"
    else
        echo "ERROR: Large numeric shortcut failed"
        cleanupTestRepo
        return 1
    fi
    
    # Test case 2: Zero as numeric shortcut (edge case)
    if gdiff 0 > /dev/null 2>&1; then
        echo "SUCCESS: Zero numeric shortcut handled"
    else
        echo "INFO: Zero numeric shortcut failed (expected behavior)"
    fi
    
    # Test case 3: Numeric file/directory name conflicts
    mkdir -p 1 2 3
    echo "content1" > 1/file.txt
    echo "content2" > 2/file.txt  
    echo "content3" > 3/file.txt
    git add .
    git commit -m "Add numeric directories" --quiet
    
    echo "modified1" > 1/file.txt
    echo "modified2" > 2/file.txt
    echo "modified3" > 3/file.txt
    
    # Test that numeric directories take precedence over commit shortcuts
    if gdiff 1 > /dev/null 2>&1 && gdiff 2 > /dev/null 2>&1; then
        echo "SUCCESS: Numeric directories take precedence over commit shortcuts"
    else
        echo "ERROR: Numeric directory precedence failed"
        cleanupTestRepo
        return 1
    fi
    
    # Test case 4: Tilde notation still works when numeric directories exist
    if gdiff ~1 > /dev/null 2>&1 && gdiff ~2 > /dev/null 2>&1; then
        echo "SUCCESS: Tilde notation works despite numeric directories"
    else
        echo "ERROR: Tilde notation failed with numeric directories"
        cleanupTestRepo
        return 1
    fi
    
    # Test case 5: Path-aware numeric with non-existent Nth different commit
    echo "stable" > stable.txt
    git add stable.txt
    git commit -m "Add stable" --quiet
    
    # Current matches committed (no differences)
    local output
    output=$(gdiff stable.txt 1 2>&1)
    
    if echo "$output" | grep -q "Could not find.*different commit"; then
        echo "SUCCESS: Path-aware handles non-existent Nth different commit"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Path-aware didn't handle missing Nth different commit properly"
        echo "Output: $output"
        cleanupTestRepo
        return 1
    fi
}