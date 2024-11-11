_sherpa_utils::array::remove_first_element() {
  local -r array_name=$1

  # shellcheck disable=SC1087,SC2116,SC2086
  eval "$array_name=(\"\${$(echo $array_name)[@]:1}\")"
}
