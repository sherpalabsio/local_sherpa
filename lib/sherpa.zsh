source $SHERPA_PATH/lib/trust_verification.zsh

function sherpa() {
  local command="$1"

  local usage_text="Example usage:
  sherpa trust|allow - Trust the sherpa environment file in the current directory"

  case $command in
-h|--help|help|'') echo $usage_text;;
      trust|allow) trust_local_sherpa;;
  esac
}

alert_sherpa() {
  unload_previously_loaded_env
  load_local_env
}

unload_previously_loaded_env() {
  varstash_dir=$OLDPWD
  autounstash
}

load_local_env() {
  # Does the .local-sherpa file exist?
  [ -f .local-sherpa ] || return

  # Is the .local-sherpa env file trusted?
  verify_trust || return 1

  varstash_dir=$PWD
  stash_existing_env
  source .local-sherpa
}

stash_existing_env() {
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
