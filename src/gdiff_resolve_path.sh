gdiff_resolve_path() {
  local path="$1"
  
  # If path is empty or ".", return current directory
  if [[ -z "$path" || "$path" == "." ]]; then
    echo "."
    return 0
  fi
  
  # If path is absolute, we need to check if it's within the git repo
  if [[ "$path" =~ ^/ ]]; then
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    
    if [[ -n "$git_root" && "$path" =~ ^"$git_root" ]]; then
      # Path is within git repo - make it relative to current directory
      local current_dir
      current_dir=$(pwd)
      local relative_path
      relative_path=$(realpath --relative-to="$current_dir" "$path" 2>/dev/null || echo "$path")
      echo "$relative_path"
    else
      # Absolute path outside git repo - return as-is for git to handle
      echo "$path"
    fi
    return 0
  fi
  
  # For relative paths, resolve from current working directory
  # This handles cases like:
  # - "b" -> "./b" (if needed)
  # - "dir/file" -> "dir/file"
  # - "../file" -> "../file"
  
  # Check if we need to normalize the path
  if [[ "$path" == *"/./"* || "$path" == *"/../"* || "$path" == *"/." || "$path" == *"/.." ]]; then
    # Normalize the path by removing redundant ./ and resolving ..
    local resolved_path
    resolved_path=$(realpath -m "$path" 2>/dev/null)
    
    if [[ $? -eq 0 && -n "$resolved_path" ]]; then
      # Convert back to relative if it's within current directory tree
      local current_dir
      current_dir=$(pwd)
      local relative_path
      relative_path=$(realpath --relative-to="$current_dir" "$resolved_path" 2>/dev/null || echo "$path")
      echo "$relative_path"
    else
      # Fallback to original path
      echo "$path"
    fi
  else
    # Simple relative path - return as-is
    echo "$path"
  fi
}