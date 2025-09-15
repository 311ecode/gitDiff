#!/usr/bin/env bash
# Complete test suite for gdiff utility function with all features

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
        "testGdiffRelativePathBasic"
        "testGdiffRelativePathWithCommit"
        "testGdiffRelativePathNumericShortcut"
        "testGdiffSpecificScenario"
        "testGdiffAbsolutePathBasic"
        "testGdiffAbsolutePathWithCommit"
        "testGdiffAbsolutePathNumericShortcut"
        "testGdiffAbsolutePathDirectory"
        "testGdiffAbsolutePathFromSubdirectory"
        "testGdiffAbsolutePathOutsideRepo"
        "testGdiffAbsolutePathNumericConflict"
        "testGdiffAbsolutePathSymlinks"
        "testGdiffAbsolutePathNormalization"
        "testGdiffAbsolutePathDeepNesting"
        "testGdiffAbsolutePathAutoLastCommit"
        "testGdiffAbsolutePathGitRelativeConversion"
        "testGdiffAbsolutePathFromDifferentWorkingDir"
        "testGdiffAbsolutePathDebugOutput"
        "testGdiffCommitValidationBasic"
        "testGdiffGapInformation"
        "testGdiffCommitSuggestions"
        "testGdiffCurrentMatchesLastCommit"
        "testGdiffNoRecentDifferences"
        "testGdiffWithActualWorkingChanges"
        "testGdiffPathAwareNumericBasic"
        "testGdiffPathAwareNumericMultiple"
        "testGdiffPathAwareWithUnrelatedCommits"
        "testGdiffPathAwareErrorHandling"
    )

    local ignored_tests=()  # Add test names to skip here

    bashTestRunner test_functions ignored_tests
    return $?
}