# gdiff - Quick Git Diff

Smart Git diff utility with automatic commit detection, path-aware shortcuts, and intelligent gap analysis.

## Usage

```bash
gdiff [COMMIT_REF] [PATH]
gdiff [PATH] [COMMIT_REF] 
gdiff [PATH]  # Auto-detects last commit for path
```

## Examples

```bash
gdiff                    # Compare current dir with HEAD~1
gdiff src/utils.js       # Compare file with its last commit
gdiff ~2                 # Compare current dir with HEAD~2
gdiff 2                  # Same as ~2 (if no file "2" exists)
gdiff src/ HEAD~3        # Compare directory with specific commit
gdiff src/ 3             # Same as above using numeric shortcut

# Path-aware numeric shortcuts (NEW!)
gdiff file.txt 1         # Find 1st commit that differs from current
gdiff file.txt 2         # Find 2nd commit that differs from current
```

## Key Features

- **Auto Last Commit**: `gdiff file.js` automatically finds the last commit that modified `file.js`
- **Path-Aware Shortcuts**: `gdiff file.txt 2` finds the 2nd commit that actually differs from current state
- **Flexible Order**: Both `gdiff ~2 src/` and `gdiff src/ ~2` work
- **Traditional Numeric Shortcuts**: `2` → `HEAD~2` (unless file/dir "2" exists)
- **Smart Parsing**: Detects commits vs paths automatically
- **Gap Information**: Shows when commits didn't modify the target path
- **Validation**: Warns about irrelevant commits and suggests better choices

## Path-Aware vs Traditional Shortcuts

```bash
# Path-aware (skips commits with identical content)
gdiff file.txt 1         # 1st different commit for this file
gdiff file.txt 2         # 2nd different commit for this file

# Traditional (raw commit distance)
gdiff 2                  # HEAD~2 (if no path "2" exists)
gdiff ~2                 # Always HEAD~2
```

## Numeric Shortcuts Logic

```bash
gdiff 2        # HEAD~2 (if no path "2" exists)
gdiff 3        # HEAD~3 (if no path "3" exists)

# If file "2" exists:
gdiff 2        # Diffs the file "2" (auto last commit)
gdiff 2 1      # Path-aware: 1st different commit for file "2"
gdiff ~2       # Still means HEAD~2
```

## Commit References

- `N` → `HEAD~N` (if path "N" doesn't exist)
- `path N` → Path-aware: Nth different commit for path
- `~N` → `HEAD~N` (always)
- `HEAD~N`, `HEAD^N` → As-is
- `abc123def` → Commit hash

## Smart Features

- **Auto-detection**: Finds last commit that modified specific paths
- **Gap analysis**: Shows time gaps and suggests better commits
- **Commit validation**: Warns when commits didn't touch target paths
- **Path resolution**: Handles absolute and relative paths correctly
