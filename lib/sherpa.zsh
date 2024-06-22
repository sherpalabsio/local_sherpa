alert_sherpa() {
  varstash_dir=$OLDPWD
  autounstash
  varstash_dir=$PWD
  load_local_config
}

load_local_config() {
  if [ -f .local-sherpa ]; then
    stash_existing_config
    source .local-sherpa
  fi
}

stash_existing_config() {
  local file_to_parse=".local-sherpa"

  # Stash variables
  grep -o '^\s*export\s\+\([^=]\+\)' "$file_to_parse" | while read -r line; do
    variable_name=$(echo "$line" | awk '{print $2}')
    autostash "$variable_name"
  done

  # Stash aliases
  grep -o '^\s*alias\s\+\([^=]\+\)' "$file_to_parse" | while read -r line; do
    alias=$(echo "$line" | awk '{print $2}')
    autostash $alias
  done

  # Stash functions
  grep -o '^\s*\([^()]\+\)\s*()' "$file_to_parse" | while read -r line; do
    function_name=$(echo "$line" | sed 's/^\s*//; s/\s*()//')
    autostash "$function_name"
  done
}
