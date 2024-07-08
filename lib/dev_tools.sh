var_dump() {
  for var_name in "$@"; do
    set | grep "^$var_name="
  done
}

timer() {
  if [ "$#" -eq 2 ]; then
    echo "$1"
    shift
  fi

  time ( "$@" ) > /dev/null
}
