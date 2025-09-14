# gdiff - Git Diff Utility

A Bash utility function for quickly comparing Git changes between commits and paths.

## Usage

```bash
gdiff [COMMIT_REF] [PATH]
gdiff [PATH] [COMMIT_REF]
gdiff [PATH]  # Automatically uses last commit that modified the path
```

### Parameters

- **COMMIT_REF** (optional): Git commit reference - defaults to `HEAD~1` (previous commit)
  - Accepts: `~N`, `HEAD~N`, `HEAD^N`, commit hashes
  - Examples: `~2`, `HEAD~3`, `abc123def`

- **PATH** (optional): File or directory path to compare - defaults to current directory (`.`)
  - When specified without a commit reference, automatically uses the last commit that modified the path

### Examples

```bash
# Compare current directory with previous commit (default)
gdiff

# Compare specific file with the last commit that modified it
gdiff src/utils.js

# Compare specific directory with the last commit that modified it
gdiff src/components/

# Compare current directory with commit 2 steps back
gdiff ~2

# Compare specific file with commit 2 steps back
gdiff src/utils.js ~2

# Compare using commit hash
gdiff abc123def
gdiff src/ src/abc123def

# Compare specific file with explicit commit (overrides auto-detection)
gdiff src/utils.js HEAD~3
```

### Help

Use `-h` or `--help` for additional information about usage and available options.

## Features

- **Smart Argument Parsing**: Automatically detects whether first argument is a commit reference or path
- **Automatic Last Commit Detection**: When a path is specified without a commit reference, uses the last commit that modified that path
- **Relative Commit Support**: Expands `~N` notation to `HEAD~N` automatically
- **Git Repository Validation**: Checks if current directory is a Git repository before executing
- **Flexible Parameter Order**: Accepts both `commit path` and `path commit` ordering

## Implementation Details

The function is implemented as a Bash shell function that:
1. Validates current directory is a Git repository
2. Parses arguments intelligently based on pattern matching
3. Automatically detects and uses the last commit that modified a specified path
4. Expands relative commit references
5. Executes `git diff` with the appropriate parameters

## Automatic Last Commit Detection

When you specify a file or directory path without an explicit commit reference, `gdiff` automatically:
1. Finds the last commit that modified the specified path using `git log -1 --format=%H -- <path>`
2. Uses that commit for the diff comparison
3. Falls back to the default commit (`HEAD~1`) if no commits are found for the path

## Error Handling

- Returns error code 1 if not in a Git repository
- Uses standard Git diff error handling for invalid commit references or paths
- Gracefully handles uncommitted files and non-existent paths

## Installation

Simply source the `gdiff.sh` file in your Bash environment:

```bash
source gdiff.sh
```

Or add it to your `.bashrc` or `.bash_profile` for permanent availability.