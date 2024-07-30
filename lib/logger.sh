export SHERPA_LOG_LEVEL_DEBUG=0
export SHERPA_LOG_LEVEL_INFO=1
export SHERPA_LOG_LEVEL_WARN=2
export SHERPA_LOG_LEVEL_ERROR=3
export SHERPA_LOG_LEVEL_SILENT=4

_sherpa_get_log_level_in_text() {
  case $SHERPA_LOG_LEVEL in
    "$SHERPA_LOG_LEVEL_DEBUG")  echo "debug";;
    "$SHERPA_LOG_LEVEL_INFO")   echo "info";;
    "$SHERPA_LOG_LEVEL_WARN")   echo "warn";;
    "$SHERPA_LOG_LEVEL_ERROR")  echo "error";;
    "$SHERPA_LOG_LEVEL_SILENT") echo "silent 🤫";;
    *)                          echo "unknown";;
  esac
}

_sherpa_set_log_level() {
  local -r input_log_level=$1
  local log_level_in_number

  case $input_log_level in
    "$SHERPA_LOG_LEVEL_DEBUG"|debug) log_level_in_number="$SHERPA_LOG_LEVEL_DEBUG";;
    "$SHERPA_LOG_LEVEL_INFO"|info)   log_level_in_number="$SHERPA_LOG_LEVEL_INFO";;
    "$SHERPA_LOG_LEVEL_WARN"|warn)   log_level_in_number="$SHERPA_LOG_LEVEL_WARN";;
    "$SHERPA_LOG_LEVEL_ERROR"|error) log_level_in_number="$SHERPA_LOG_LEVEL_ERROR";;
    "$SHERPA_LOG_LEVEL_SILENT"|*)    log_level_in_number="$SHERPA_LOG_LEVEL_SILENT";;
  esac

  _sherpa_save_global_config "SHERPA_LOG_LEVEL" "$log_level_in_number"
}

_sherpa_decrease_log_level() {
  # Do not increase the log level if it is already at the highest level
  if [ "$SHERPA_LOG_LEVEL" -eq $SHERPA_LOG_LEVEL_DEBUG ]; then
    _sherpa_log "The log level is already at the highest level."
    return
  fi

  _sherpa_set_log_level $((SHERPA_LOG_LEVEL - 1))
}

_sherpa_increase_log_level() {
  # Do not decrease the log level if it is already at the lowest level
  if [ "$SHERPA_LOG_LEVEL" -eq $SHERPA_LOG_LEVEL_SILENT ]; then
    _sherpa_log "The log level is already at the lowest level."
    return
  fi

  _sherpa_set_log_level $((SHERPA_LOG_LEVEL + 1))

}

_sherpa_log_debug() {
  [[ $SHERPA_LOG_LEVEL -le $SHERPA_LOG_LEVEL_DEBUG ]] && echo "Sherpa debug: $1"
}

_sherpa_log_info() {
  [[ $SHERPA_LOG_LEVEL -le $SHERPA_LOG_LEVEL_INFO ]] && echo "Sherpa: $1"
}

_sherpa_log_warn() {
  [[ $SHERPA_LOG_LEVEL -le $SHERPA_LOG_LEVEL_WARN ]] && echo "Sherpa: $1"
}

_sherpa_log_error() {
  if [[ $SHERPA_LOG_LEVEL -le $SHERPA_LOG_LEVEL_ERROR ]]; then
    echo "Sherpa: $1" >&2
    [ -z "$2" ] && return
    echo "        $2" >&2
  fi
}

_sherpa_log() {
  echo "$1"
}
