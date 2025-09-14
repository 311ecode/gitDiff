#!/usr/bin/env bash
testGdiffLastCommitMixed() {
    echo "🧪 Testing mixed commit reference scenarios"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Create multiple commits with different files
    echo "commit1" > file1.txt
    git add file1.txt
    git commit -m "Commit 1" --quiet
    
    echo "commit2" > file2.txt
    git add file2.txt
    git commit -m "Commit 2" --quiet
    
    echo "commit3" > file3.txt
    git add file3.txt
    git commit -m "Commit 3" --quiet
    
    # Modify files
    echo "modified1" > file1.txt
    echo "modified2" > file2.txt
    echo "modified3" > file3.txt
    
    # Test various scenarios
    if gdiff file1.txt > /dev/null 2>&1 && \          # Auto last commit for file1 (should be commit 1)
       gdiff file2.txt HEAD~1 > /dev/null 2>&1 && \  # Explicit commit for file2
       gdiff HEAD~2 file3.txt > /dev/null 2>&1; then # Explicit commit first, then path
        echo "✅ SUCCESS: Mixed commit reference scenarios work"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Mixed commit reference scenarios failed"
        cleanupTestRepo
        return 1
    fi
}