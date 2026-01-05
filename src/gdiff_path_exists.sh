gdiff_path_exists() {
  local path="$1"

  # Handle both relative and absolute paths correctly
  if [[ $path =~ ^/ ]]; then
    # Absolute path - check directly
    [[ -e $path ]]
  else
    # Relative path - check relative to current directory
    [[ -e $path ]]
  fi
}
