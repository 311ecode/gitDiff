#!/usr/bin/env bash
# Enhanced test suite for gdiff utility function with last commit detection

testGdiffEnhanced() {
  export LC_NUMERIC=C # 🔢 Ensure consistent numeric formatting

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
    "testGdiffLastCommit"
    "testGdiffLastCommitFile"
    "testGdiffLastCommitMixed"
    "testGdiffLastCommitNonExistentPath"
    "testGdiffLastCommitUncommittedFile"
    "testGdiffLastCommitDefaultPath"
  )

  local ignored_tests=() # 🚫 Add test names to skip here

  bashTestRunner test_functions ignored_tests
  return $?
}
