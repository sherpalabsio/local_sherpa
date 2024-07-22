# Init the test related tools

# shellcheck disable=SC2155
export SHERPA_DIR=$(pwd)
# shellcheck disable=SC2155
readonly TEST_DIR=$(mktemp -d)
export TEST_DIR
export TMP_FILES_OR_DIRS_TO_REMOVE=()

source tests/support/assertions.sh

cp -r "tests/playground" "$TEST_DIR"
cd "$TEST_DIR/playground"

# == Clean up the test directory ==
trap _init_teardown EXIT
_init_teardown() {
  type sherpa &> /dev/null && sherpa off > /dev/null

  cd /

  rm -rf "${TMP_FILES_OR_DIRS_TO_REMOVE[@]}"

  rm -r "$TEST_DIR"
  rm -f "$TMP_TEST_FILE"
}

# == Utilities ==
stub_env_file() {
  # shellcheck disable=SC2155
  export TMP_TEST_FILE=$(mktemp)
  export SHERPA_ENV_FILENAME="$TMP_TEST_FILE"
  readonly TMP_TEST_FILE
}

override_env_file() {
  if [ -n "$1" ]; then
    echo "$1" > "$SHERPA_ENV_FILENAME"
  else
    cat > "$SHERPA_ENV_FILENAME"
  fi
}

cleanup_file_or_dir_at_teardown() {
  local -r item_to_remove="$1"

  TMP_FILES_OR_DIRS_TO_REMOVE=("${TMP_FILES_OR_DIRS_TO_REMOVE[@]}" "$item_to_remove")
}
