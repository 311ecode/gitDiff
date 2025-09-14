# gdiff - Quick Git Diff

Smart Git diff utility with automatic commit detection and numeric shortcuts.

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
```

## Key Features

- **Auto Last Commit**: `gdiff file.js` automatically finds the last commit that modified `file.js`
- **Flexible Order**: Both `gdiff ~2 src/` and `gdiff src/ ~2` work
- **Numeric Shortcuts**: `2` → `HEAD~2` (unless file/dir "2" exists)
- **Smart Parsing**: Detects commits vs paths automatically

## Numeric Shortcuts

```bash
gdiff 2        # HEAD~2 (if no path "2" exists)
gdiff 3        # HEAD~3 (if no path "3" exists)

# If file "2" exists:
gdiff 2        # Diffs the file "2" 
gdiff ~2       # Still means HEAD~2
```

## Commit References

- `N` → `HEAD~N` (if path "N" doesn't exist)
- `~N` → `HEAD~N` (always)
- `HEAD~N`, `HEAD^N` → As-is
- `abc123def` → Commit hash