_sherpa_print_debug_info() {
  echo "================ Loaded shell entities ================"

  local directories dir dir_to_print

  if [ -n "$ZSH_VERSION" ]; then
    # shellcheck disable=SC2296,SC2206
    directories=(${(ko)SHERPA_STATUS_INFO__VARS})
  else
    # shellcheck disable=SC2206
    directories=(${!SHERPA_STATUS_INFO__VARS[*]})
  fi

  for dir in "${directories[@]}"; do
    dir_to_print="${dir//\"/}"
    dir_to_print="${dir_to_print//\/Users\/peter/~}"

    echo "==== $dir_to_print ===="

    echo "== Variables"
    for var in $(echo "${SHERPA_STATUS_INFO__VARS[$dir]}" | tr ' ' '\n' | sort); do
      echo "- $var"
    done

    echo -e "\n== Aliases"
    for var in $(echo "${SHERPA_STATUS_INFO__ALIASES[$dir]}" | tr ' ' '\n' | sort); do
      echo "- $var"
    done

    echo -e "\n== Functions"
    for var in $(echo "${SHERPA_STATUS_INFO__FUNCTIONS[$dir]}" | tr ' ' '\n' | sort); do
      echo "- $var"
    done

    echo
  done
}
