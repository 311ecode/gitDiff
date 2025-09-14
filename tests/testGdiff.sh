#!/usr/bin/env bash
# Complete test suite for gdiff utility function with all features
# Tests various functionality including:
# - Default behavior with no arguments
# - Commit reference notations (~N, HEAD~N, commit hashes, numeric shortcuts)
# - Path argument handling
# - Argument order flexibility
# - Error handling in non-git repositories
# - Directory-specific diff functionality
# - Nested directory support
# - File vs directory diff distinction
# - Automatic last commit detection for paths
# - Numeric shortcut functionality

testGdiff() {
    export LC_NUMERIC=C  # Ensure consistent numeric formatting

    # Test function registry
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
        "testGdiffLastCommit"
        "testGdiffLastCommitFile"
        "testGdiffLastCommitMixed"
        "testGdiffLastCommitNonExistentPath"
        "testGdiffLastCommitUncommittedFile"
        "testGdiffLastCommitDefaultPath"
        "testGdiffNumericShortcutBasic"
        "testGdiffNumericShortcutWithPath"
        "testGdiffNumericShortcutPathPriority"
        "testGdiffNumericShortcutMixedScenarios"
        "testGdiffNumericShortcutSecondArgument"
        "testGdiffNumericShortcutEdgeCases"
    )

    local ignored_tests=()  # Add test names to skip here

    bashTestRunner test_functions ignored_tests
    return $?
}