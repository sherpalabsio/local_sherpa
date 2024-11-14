# shellcheck disable=SC2034
TIMEFMT=$'%mE'
TIMEFORMAT='%R'

source tests/support/app_helper.sh
_sherpa_trust_dir "performance"

format_time_result() {
  local -r time_result="$1"

  if [ -n "$ZSH_VERSION" ]; then
    # Zsh
    echo "${time_result//ms/}"
  else
    # Bash
    awk "BEGIN {print $time_result * 1000}"
  fi
}

time_result=$( { time (cd performance); } 2>&1 )
format_time_result "$time_result"
