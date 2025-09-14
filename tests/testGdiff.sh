#!/usr/bin/env bash
# Test suite for gdiff utility function
# Tests various functionality including:
# - Default behavior with no arguments
# - Commit reference notations (~N, HEAD~N, commit hashes)
# - Path argument handling
# - Argument order flexibility
# - Error handling in non-git repositories
# - Directory-specific diff functionality
# - Nested directory support
# - File vs directory diff distinction

testGdiff() {
    export LC_NUMERIC=C  # 🔢 Ensure consistent numeric formatting

    # Test function registry 📋
    local test_functions=(
        "testGdiffDefaultBehavior"
        "testGdiffTildeNotation"
        "testGdiffNumberNotation"
        "testGdiffPathArgument"
        "testGdiffArgumentOrder"
        "testGdiffNotGitRepo"
        "testGdiffCommitHash"
        "testGdiffHeadNotation"
        "testGdiffDirectorySpecific"
        "testGdiffDirectoryWithCommit"
        "testGdiffNestedDirectories"
        "testGdiffDirectoryVsFile"
    )

    local ignored_tests=()  # 🚫 Add test names to skip here

    bashTestRunner test_functions ignored_tests
    return $?
}