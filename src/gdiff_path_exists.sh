gdiff_path_exists() {
  local path="$1"
  
  # Check if path exists relative to current directory
  # This handles both absolute and relative paths correctly
  [[ -e "$path" ]]
}