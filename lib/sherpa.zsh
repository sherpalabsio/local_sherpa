source $SHERPA_PATH/lib/logger.sh
source $SHERPA_PATH/lib/trust_verification.zsh
source $SHERPA_PATH/lib/local_env_file_parser.sh

function sherpa() {
  local command="$1"

  local usage_text="Example usage:
  sherpa trust|allow      - Trust the local env file
  sherpa edit|init        - Edit the local env file (creates it if it does not exist)
  sherpa rest|off|disable - Turn Sherpa off for the current session
  sherpa work|on|enable   - Turn Sherpa on for the current session

Tell sherpa how much he should talk (works only for the current session):
  sherpa info               - Messages like the local env file is not trusted etc.
  sherpa debug              - Everything Sherpa knows
  sherpa shh|shhh           - Shotup Sherpa
  sherpa talk               - Set the log level to the specified value (debug, info, no talking)"

  case $command in
 -h|--help|help|'') echo $usage_text;;
       trust|allow) trust_local_env; load_local_env;;
         init|edit) edit; trust_local_env; unload_currently_loaded_env; load_local_env;;
  rest|off|disable) disable;;
    work|on|enable) enable;;
              talk) shift; set_log_level $1;;
             debug) set_log_level "debug";;
              info) set_log_level "info";;
          shh|shhh) set_log_level "no talking";;
  esac
}

edit() {
  echo "hint: Waiting for your editor to close the file..."
  eval "$EDITOR .local-sherpa"
}

disable() {
  unload_currently_loaded_env
  log_info "Sherpa: Local env unloaded. Sherpa goes to sleep."
  unset SHERPA_ENABLED
}

enable() {
  export SHERPA_ENABLED=true
  load_local_env
  log_info "Sherpa: Local env loaded. Sherpa is ready for action."
}

set_log_level() {
  case $1 in
    debug) SHERPA_LOG_LEVEL='debug';;
    info) SHERPA_LOG_LEVEL='info';;
    *) SHERPA_LOG_LEVEL='no talking';;
  esac
  log_message="Sherpa: Log level set to $SHERPA_LOG_LEVEL"
  [ "$SHERPA_LOG_LEVEL" = "no talking" ] && log_message="$log_message 🤫"
  log $log_message
}

alert_sherpa_we_changed_dir() {
  # Skip if sherpa is not enabled
  [ -z "$SHERPA_ENABLED" ] && return
  log_debug "Sherpa-debug: Directory changed. Unloading previous env and loading local env."
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
  # Skip if sherpa is not enabled
  [ -z "$SHERPA_ENABLED" ] && return
  # Does the .local-sherpa file exist?
  [ -f .local-sherpa ] || return
  log_debug "Sherpa-debug: Loading local env"

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
