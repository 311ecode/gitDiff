#!/usr/bin/env bash
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
    )

    local ignored_tests=()  # 🚫 Add test names to skip here

    bashTestRunner test_functions ignored_tests
    return $?
}