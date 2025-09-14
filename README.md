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
  - Accepts: `~N`, `HEAD~N`, `HEAD^N`, `N` (numeric shortcuts), commit hashes
  - Examples: `~2`, `HEAD~3`, `2`, `abc123def`
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

# Compare current directory with commit 2 steps back (all equivalent)
gdiff ~2
gdiff 2      # Numeric shortcut (if no file/dir named "2" exists)
gdiff HEAD~2

# Compare specific file with commit 2 steps back
gdiff src/utils.js ~2
gdiff src/utils.js 2    # Numeric shortcut
gdiff 2 src/utils.js

# Compare using commit hash
gdiff abc123def
gdiff abc123def src/

# Compare specific file with explicit commit (overrides auto-detection)
gdiff src/utils.js HEAD~3
gdiff HEAD~3 src/utils.js
gdiff src/utils.js 3
```

### Numeric Shortcuts

Bare numbers are automatically treated as commit shortcuts (`N` → `HEAD~N`), but with intelligent path detection:

```bash
gdiff 2        # HEAD~2 (if no file/directory named "2" exists)
gdiff 3        # HEAD~3 (if no file/directory named "3" exists)

# If a file or directory named "2" exists:
gdiff 2        # Diffs the path "2" (uses its last commit)
gdiff ~2       # Still refers to HEAD~2 (explicit tilde notation)
gdiff 2 ~3     # Diffs path "2" against HEAD~3
```

### Help

Use `-h` or `--help` for additional information about usage and available options.

## Features

- **Smart Argument Parsing**: Automatically detects whether arguments are commit references or paths
- **Numeric Shortcuts**: Bare numbers (`2`) are treated as `HEAD~2` unless a path with that name exists
- **Automatic Last Commit Detection**: When a path is specified without a commit reference, uses the last commit that modified that path
- **Relative Commit Support**: Expands `~N` notation to `HEAD~N` automatically
- **Git Repository Validation**: Checks if current directory is a Git repository before executing
- **Flexible Parameter Order**: Accepts both `commit path` and `path commit` ordering

## Implementation Details

The function is implemented as a Bash shell function that:

1. Validates current directory is a Git repository
2. Parses arguments intelligently based on pattern matching and path existence
3. Handles numeric shortcuts with path priority detection
4. Automatically detects and uses the last commit that modified a specified path
5. Expands relative commit references
6. Executes `git diff` with the appropriate parameters

## Automatic Last Commit Detection

When you specify a file or directory path without an explicit commit reference, `gdiff` automatically:

1. Finds the last commit that modified the specified path using `git log -1 --format=%H -- <path>`
2. Uses that commit for the diff comparison
3. Falls back to the default commit (`HEAD~1`) if no commits are found for the path

This feature is particularly useful when working with files or directories that haven't been modified recently, as it will show you the actual changes since the last time that specific path was touched, rather than showing no changes against the previous commit.

## Numeric Shortcut Logic

The numeric shortcut feature follows this priority:

1. **Path exists**: If a file or directory with the numeric name exists, treat it as a path
2. **No path exists**: Treat the number as a commit reference (`N` → `HEAD~N`)
3. **Second argument**: When a number appears as the second argument after a path, always treat it as a commit reference
4. **Explicit notation**: `~N` always refers to commits, regardless of path existence

## Error Handling

- Returns error code 1 if not in a Git repository
- Returns error code 1 if specified path does not exist
- Uses standard Git diff error handling for invalid commit references
- Gracefully handles uncommitted files and falls back to default behavior

## Debug Mode

Set the `DEBUG` environment variable to see detailed execution information:

```bash
DEBUG=1 gdiff src/components/
```

This will show:
- Argument parsing decisions
- Path existence checks
- Commit reference expansions
- Final parameters used for `git diff`


Or add it to your `.bashrc` or `.bash_profile` for permanent availability:

```bash
echo "source /path/to/gdiff.sh" >> ~/.bashrc
```