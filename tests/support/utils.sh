is_item_defined_error_message() {
  local item_name=$1

  if [ -n "$ZSH_VERSION" ]; then
    echo $(which $item_name)
  else
    echo $(type $item_name 2>&1 > /dev/null)
  fi
}
