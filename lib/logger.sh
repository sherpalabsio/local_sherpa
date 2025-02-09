export SHERPA_LOG_LEVEL_DEBUG=0
export SHERPA_LOG_LEVEL_INFO=1
export SHERPA_LOG_LEVEL_WARN=2
export SHERPA_LOG_LEVEL_ERROR=3
export SHERPA_LOG_LEVEL_SILENT=4

_sherpa_get_log_level_in_text() {
  local -r log_level=${1:-$SHERPA_LOG_LEVEL}

  case $log_level in
    "$SHERPA_LOG_LEVEL_DEBUG")  echo "debug" ;;
    "$SHERPA_LOG_LEVEL_INFO")   echo "info" ;;
    "$SHERPA_LOG_LEVEL_WARN")   echo "warn" ;;
    "$SHERPA_LOG_LEVEL_ERROR")  echo "error" ;;
    "$SHERPA_LOG_LEVEL_SILENT") echo "silent 🤫" ;;
    *)                          echo "unknown" ;;
  esac
}

_sherpa_set_log_level() {
  local -r input_log_level=$1
  local log_level_in_number

  case $input_log_level in
    "$SHERPA_LOG_LEVEL_DEBUG" | debug) log_level_in_number="$SHERPA_LOG_LEVEL_DEBUG" ;;
    "$SHERPA_LOG_LEVEL_INFO" | info)   log_level_in_number="$SHERPA_LOG_LEVEL_INFO" ;;
    "$SHERPA_LOG_LEVEL_WARN" | warn)   log_level_in_number="$SHERPA_LOG_LEVEL_WARN" ;;
    "$SHERPA_LOG_LEVEL_ERROR" | error) log_level_in_number="$SHERPA_LOG_LEVEL_ERROR" ;;
    "$SHERPA_LOG_LEVEL_SILENT" | *)    log_level_in_number="$SHERPA_LOG_LEVEL_SILENT" ;;
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

__sherpa_log_level_menu() {
  if command -v fzf &> /dev/null; then
    __sherpa_log_level_menu_fzf
  else
    __sherpa_log_level_menu_basic
  fi
}

__sherpa_log_level_menu_fzf() {
  local menu_items=(
    "0 1) $(_sherpa_get_log_level_in_text 0)"
    "1 2) $(_sherpa_get_log_level_in_text 1)"
    "2 3) $(_sherpa_get_log_level_in_text 2)"
    "3 4) $(_sherpa_get_log_level_in_text 3)"
    "4 5) $(_sherpa_get_log_level_in_text 4)"
  )

  local menu_string
  printf -v menu_string "%s\n" "${menu_items[@]}"
  menu_string=${menu_string%$'\n'} # Remove trailing newline

  local fzf_starting_position=""
  for ((i = 0; i < SHERPA_LOG_LEVEL; i++)); do
      if [[ $i -gt 0 ]]; then
          fzf_starting_position+="+"
    fi
      fzf_starting_position+="down"
  done

  local choice
  choice=$(echo "$menu_string" | fzf \
    --prompt="Select the log level: " \
    --height=~10 \
    --layout=reverse \
    --exit-0 \
    --cycle \
    --no-multi \
    --ansi \
    --color="prompt:green" \
    --bind="esc:abort" \
    --border=rounded \
    --with-nth 2.. \
    --bind 'enter:become(echo {1})' \
    --bind start:$fzf_starting_position)

  if [ -z "$choice" ]; then
    return 1
  fi

  _sherpa_set_log_level "$choice"
}

__sherpa_log_level_menu_basic() {
  trap "__sherpa_cli_clear_last_lines 6; trap - SIGINT; return 1" SIGINT

  local -r current="\033[32m ❮ current\033[0m"

  echo "Select the log level:"
  echo -e "1) Debug$( [[ "$SHERPA_LOG_LEVEL" == "0" ]] && echo -e "$current ")"
  echo -e "2) Info$( [[ "$SHERPA_LOG_LEVEL" == "1" ]] && echo -e "$current ")"
  echo -e "3) Warn$( [[ "$SHERPA_LOG_LEVEL" == "2" ]] && echo -e "$current ")"
  echo -e "4) Error$( [[ "$SHERPA_LOG_LEVEL" == "3" ]] && echo -e "$current ")"
  echo -e "5) Silent 🤫$( [[ "$SHERPA_LOG_LEVEL" == "4" ]] && echo -e "$current ")"
  echo -n "Enter your choice [1-5]: "

  local choice

  if [[ -n $ZSH_VERSION ]]; then
    read -rk1 choice
  else
    read -rn1 choice
  fi

  trap - SIGINT

  __sherpa_cli_clear_last_lines 6

  local -r esc=$(printf "\033")
  if [[ "$choice" == "$esc" ]]; then
    return 1
  fi

  local -r enter=$'\n'
  if [[ "$choice" == "$enter" ]]; then
    __sherpa_cli_clear_last_lines 1
    return 1
  fi

  [[ "$choice" =~ ^[0-9]$ ]] && choice=$((choice - 1))

  _sherpa_set_log_level "$choice"
}
