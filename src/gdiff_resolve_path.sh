gdiff_resolve_path() {
  local path="$1"
  
  # If path is empty or ".", return current directory
  if [[ -z "$path" || "$path" == "." ]]; then
    echo "."
    return 0
  fi
  
  # If path is absolute, return as-is
  if [[ "$path" =~ ^/ ]]; then
    echo "$path"
    return 0
  fi
  
  # For relative paths, resolve from current working directory
  # This handles cases like:
  # - "b" -> "./b"
  # - "dir/file" -> "./dir/file"
  # - "../file" -> "../file"
  
  # Normalize the path by removing redundant ./ and resolving ..
  local resolved_path
  resolved_path=$(realpath -m "$path" 2>/dev/null || echo "$path")
  
  # If realpath failed or isn't available, fall back to simple resolution
  if [[ $? -ne 0 || -z "$resolved_path" ]]; then
    # Simple fallback: just ensure we have a proper relative path
    if [[ "$path" =~ ^\.\./ || "$path" =~ ^\. ]]; then
      echo "$path"
    else
      echo "./$path"
    fi
  else
    # Convert absolute path back to relative if it's within the git repo
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [[ -n "$git_root" && "$resolved_path" =~ ^"$git_root" ]]; then
      # Make it relative to git root
      local relative_to_root="${resolved_path#$git_root/}"
      # But we want it relative to current directory
      local current_dir
      current_dir=$(pwd)
      local relative_to_git_root="${current_dir#$git_root}"
      if [[ "$relative_to_git_root" == "$current_dir" ]]; then
        # We're outside git repo somehow, use original path
        echo "$path"
      else
        # Calculate relative path from current dir
        local relative_path
        relative_path=$(realpath --relative-to="$current_dir" "$resolved_path" 2>/dev/null || echo "$path")
        echo "$relative_path"
      fi
    else
      echo "$path"
    fi
  fi
}