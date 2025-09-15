# gdiff - Git Diff Utility

A Bash utility function for quickly comparing Git changes between commits and paths with intelligent path-aware shortcuts.

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
  - When specified with a numeric value, uses path-aware numeric shortcuts

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

# Path-aware numeric shortcuts - find Nth different commit for the path
gdiff src/utils.js 1    # Find 1st commit that differs from current state
gdiff src/utils.js 2    # Find 2nd commit that differs from current state

# Compare using commit hash
gdiff abc123def
gdiff abc123def src/

# Compare specific file with explicit commit (overrides auto-detection)
gdiff src/utils.js HEAD~3
gdiff HEAD~3 src/utils.js
gdiff src/utils.js 3
```

### Path-Aware Numeric Shortcuts

When a numeric value is used as the second argument after a path, it uses **path-aware behavior**:

```bash
gdiff file.txt 1    # Find 1st commit that has different content than current
gdiff file.txt 2    # Find 2nd commit that has different content than current
gdiff file.txt 3    # Find 3rd commit that has different content than current
```

This is particularly useful when:
- A file hasn't changed in recent commits (skips commits with identical content)
- You want to see meaningful differences rather than empty diffs
- Working with files that have sparse change history

### Traditional Numeric Shortcuts

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
- **Path-Aware Numeric Shortcuts**: Find Nth commit that actually differs from current state
- **Traditional Numeric Shortcuts**: Bare numbers (`2`) are treated as `HEAD~2` unless a path with that name exists
- **Automatic Last Commit Detection**: When a path is specified without a commit reference, uses the last commit that modified that path
- **Relative Commit Support**: Expands `~N` notation to `HEAD~N` automatically
- **Git Repository Validation**: Checks if current directory is a Git repository before executing
- **Flexible Parameter Order**: Accepts both `commit path` and `path commit` ordering
- **Intelligent Gap Information**: Shows when commits didn't touch the specified path
- **Commit Validation**: Warns when using commits that didn't modify the target path

## Implementation Details

The function is implemented as a modular Bash shell function suite that:

1. **Argument Parsing** (`gdiff_parse_args`): Intelligently parses arguments based on pattern matching and path existence
2. **Commit Determination** (`gdiff_determine_commit`): Handles auto-detection, path-aware shortcuts, and validation
3. **Path Resolution** (`gdiff_resolve_path`): Resolves absolute and relative paths correctly
4. **Smart Features**:
   - Finds the last commit that modified a specified path
   - Implements path-aware numeric shortcuts that skip identical commits
   - Provides gap information when commits don't touch target paths
   - Suggests better commit choices when appropriate

## Automatic Last Commit Detection

When you specify a file or directory path without an explicit commit reference, `gdiff` automatically:

1. Finds the last commit that modified the specified path using `git log -1 --format=%H -- <path>`
2. Uses that commit for the diff comparison
3. Falls back to the default commit (`HEAD~1`) if no commits are found for the path

This feature is particularly useful when working with files or directories that haven't been modified recently, as it will show you the actual changes since the last time that specific path was touched.

## Path-Aware Numeric Shortcuts

The path-aware numeric shortcut feature introduces intelligent commit selection:

1. **Skip Identical Commits**: When using `gdiff path N`, finds the Nth commit that actually has different content
2. **Meaningful Diffs**: Avoids showing empty diffs from commits that didn't change the file
3. **Handles Sparse History**: Works well with files that change infrequently
4. **Informative Output**: Shows which commit was selected and gap information

### Priority Logic

1. **Path exists + number**: Use path-aware numeric shortcut (`gdiff file.txt 2`)
2. **No path exists + number**: Use traditional commit shortcut (`gdiff 2` → `HEAD~2`)
3. **Explicit tilde**: Always refers to commits (`~N` → `HEAD~N`)
4. **Second argument after path**: Always path-aware behavior

## Commit Validation and Gap Information

`gdiff` provides intelligent feedback:

- **Gap Information**: Shows time gaps between commits and paths
- **Commit Validation**: Warns when specified commits didn't modify the target path
- **Better Suggestions**: Recommends more appropriate commit choices
- **First Different Detection**: Helps find meaningful commit comparisons

## Error Handling

- Returns error code 1 if not in a Git repository
- Returns error code 1 if specified path does not exist
- Uses standard Git diff error handling for invalid commit references
- Gracefully handles uncommitted files and falls back to default behavior
- Provides helpful error messages for path-aware shortcuts when no different commits exist

## Debug Mode

Set the `DEBUG` environment variable to see detailed execution information:

```bash
DEBUG=1 gdiff src/components/
```

This will show:
- Argument parsing decisions
- Path existence checks and resolution
- Commit reference expansions and path-aware selections
- Final parameters used for `git diff`
- Gap analysis and commit validation details

## Installation

Source the function file:

```bash
source /path/to/gdiff.sh
```

Or add it to your `.bashrc` or `.bash_profile` for permanent availability:

```bash
echo "source /path/to/gdiff.sh" >> ~/.bashrc
```

The modular implementation automatically loads all required sub-functions.