# gdiff - Git Diff Utility

A Bash utility function for quickly comparing Git changes between commits and paths.

## Usage

```bash
gdiff [COMMIT_REF] [PATH]
gdiff [PATH] [COMMIT_REF]
```

### Parameters

- **COMMIT_REF** (optional): Git commit reference - defaults to `HEAD~1` (previous commit)
  - Accepts: `~N`, `HEAD~N`, `HEAD^N`, commit hashes
  - Examples: `~2`, `HEAD~3`, `abc123def`

- **PATH** (optional): File or directory path to compare - defaults to current directory (`.`)

### Examples

```bash
# Compare current directory with previous commit (default)
gdiff

# Compare specific file with previous commit
gdiff src/utils.js

# Compare current directory with commit 2 steps back
gdiff ~2

# Compare specific file with commit 2 steps back
gdiff src/utils.js ~2

# Compare using commit hash
gdiff abc123def
gdiff src/ src/abc123def
```

### Help

Use `-h` or `--help` for additional information about usage and available options.

## Features

- **Smart Argument Parsing**: Automatically detects whether first argument is a commit reference or path
- **Relative Commit Support**: Expands `~N` notation to `HEAD~N` automatically
- **Git Repository Validation**: Checks if current directory is a Git repository before executing
- **Flexible Parameter Order**: Accepts both `commit path` and `path commit` ordering

## Implementation Details

The function is implemented as a Bash shell function that:
1. Validates current directory is a Git repository
2. Parses arguments intelligently based on pattern matching
3. Expands relative commit references
4. Executes `git diff` with the appropriate parameters

## Error Handling

- Returns error code 1 if not in a Git repository
- Uses standard Git diff error handling for invalid commit references or paths

## Installation

Simply source the `a.sh` file in your Bash environment:

```bash
source a.sh
```

Or add it to your `.bashrc` or `.bash_profile` for permanent availability.