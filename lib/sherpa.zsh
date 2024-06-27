source $SHERPA_PATH/lib/logger.sh
source $SHERPA_PATH/lib/trust_verification.zsh
source $SHERPA_PATH/lib/local_env_file_parser.sh

function sherpa() {
  local command="$1"

  local usage_text="Example usage:
  sherpa trust|allow - Trust the sherpa environment file in the current directory
  sherpa edit        - Initialize and edit the sherpa environment file in the current directory"

  case $command in
-h|--help|help|'') echo $usage_text;;
      trust|allow) trust_local_env; alert_sherpa;;
        init|edit) edit; trust_local_env; unload_currently_loaded_env; load_local_env;;
  esac
}

edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR .local-sherpa"
}

alert_sherpa() {
  unload_previously_loaded_env
  load_local_env
}

unload_previously_loaded_env() {
  varstash_dir=$OLDPWD
  autounstash
}

unload_currently_loaded_env() {
  varstash_dir=$PWD
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
  parse_local_env_file | while read -r env_item_name; do
    autostash "$env_item_name"
  done
}
