#!/usr/bin/env bash
testGdiffLastCommitFile() {
    echo "🧪 Testing automatic last commit detection for files"
    
    if ! setupTestRepo; then
        echo "❌ ERROR: Failed to setup test repo"
        return 1
    fi

    # Create multiple files
    echo "file1 initial" > file1.txt
    git add file1.txt
    git commit -m "Add file1" --quiet
    
    echo "file2 initial" > file2.txt
    git add file2.txt
    git commit -m "Add file2" --quiet
    
    echo "file3 initial" > file3.txt
    git add file3.txt
    git commit -m "Add file3" --quiet
    
    # Modify files
    echo "file1 modified" > file1.txt
    echo "file2 modified" > file2.txt
    echo "file3 modified" > file3.txt
    
    # Test that gdiff automatically uses last commit for each file
    if gdiff file1.txt > /dev/null 2>&1 && \
       gdiff file2.txt > /dev/null 2>&1 && \
       gdiff file3.txt > /dev/null 2>&1; then
        echo "✅ SUCCESS: Automatic last commit detection works for files"
        cleanupTestRepo
        return 0
    else
        echo "❌ ERROR: Automatic last commit detection for files failed"
        cleanupTestRepo
        return 1
    fi
}