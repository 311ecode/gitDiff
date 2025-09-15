#!/usr/bin/env bash
# Tests smart commit detection that finds first different commit

testGdiffFindFirstDifferentCommit() {
    echo "Testing find first different commit functionality"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create file with initial content
    echo "version 1" > target.txt
    git add target.txt
    git commit -m "Add target file v1" --quiet
    
    # Change content to version 2
    echo "version 2" > target.txt
    git add target.txt
    git commit -m "Update to v2" --quiet
    
    # Make several commits that don't touch this file at all
    for i in {1..3}; do
        echo "unrelated $i" > "unrelated$i.txt"
        git add "unrelated$i.txt"
        git commit -m "Unrelated commit $i" --quiet
    done
    
    # Current working directory has no changes (clean state = version 2)
    # Test using HEAD~1 which is an unrelated commit that didn't touch target.txt
    local output
    output=$(gdiff target.txt 1 2>&1)
    
    # Should detect that HEAD~1 didn't modify this path
    if echo "$output" | grep -q "didn't modify this path" || \
       echo "$output" | grep -q "Consider using:"; then
        echo "SUCCESS: Detected that recent commit didn't modify the path"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Didn't detect commit/path mismatch"
        echo "Output: $output"
        cleanupTestRepo
        return 1
    fi
}

testGdiffCurrentMatchesLastCommit() {
    echo "Testing behavior when current state matches last commit"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create file
    echo "stable content" > stable.txt
    git add stable.txt
    git commit -m "Add stable file" --quiet
    
    # Make some unrelated commits (that don't touch stable.txt)
    for i in {1..3}; do
        echo "unrelated $i" > "file$i.txt"
        git add "file$i.txt"
        git commit -m "Unrelated commit $i" --quiet
    done
    
    # Current working state matches the committed state (no local changes to stable.txt)
    
    # Test gdiff with recent commit that didn't touch the file
    local output
    output=$(gdiff stable.txt 1 2>&1)
    
    # Should detect that the recent commit didn't modify this path
    if echo "$output" | grep -q "didn't modify this path" || \
       echo "$output" | grep -q "Current state matches" || \
       echo "$output" | grep -q "No significantly different commits"; then
        echo "SUCCESS: Detected commit/path mismatch or matching state"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Didn't detect the issue"
        echo "Output: $output"
        cleanupTestRepo
        return 1
    fi
}

testGdiffWithActualWorkingChanges() {
    echo "Testing first different commit when working directory has changes"
    
    if ! setupTestRepo; then
        echo "ERROR: Failed to setup test repo"
        return 1
    fi

    # Create file
    echo "version 1" > evolving.txt
    git add evolving.txt
    git commit -m "Add evolving file v1" --quiet
    
    # Update it
    echo "version 2" > evolving.txt
    git add evolving.txt
    git commit -m "Update to v2" --quiet
    
    # Make commits that don't touch this file
    for i in {1..2}; do
        echo "other $i" > "other$i.txt"
        git add "other$i.txt"  
        git commit -m "Other commit $i" --quiet
    done
    
    # Now make working directory changes
    echo "version 3 - current work" > evolving.txt
    
    # Test with a commit that didn't touch the file
    local output
    output=$(gdiff evolving.txt 1 2>&1)
    
    # Should suggest using the last commit that actually modified the file
    if echo "$output" | grep -q "didn't modify this path" && \
       echo "$output" | grep -q "Consider using:"; then
        echo "SUCCESS: Suggested better commit for comparison"
        cleanupTestRepo
        return 0
    else
        echo "ERROR: Didn't provide helpful suggestion"
        echo "Output: $output"
        cleanupTestRepo
        return 1
    fi
}