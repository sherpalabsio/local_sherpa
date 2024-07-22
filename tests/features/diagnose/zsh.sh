stub() {
  local stub_definition=$1=$2

  echo "$stub_definition" >> "$ZSHRC"
}

reset_stubs() {
  echo "source $SHERPA_LIB_DIR/init.sh" > "$ZSHRC"
}

# ==============================================================================
# ++++ Setup
source tests/support/app_helper.sh

# ++ Stubbing
ZSHRC_DIR=$(mktemp -d)
cleanup_file_or_dir_at_teardown "$ZSHRC_DIR"
export ZDOTDIR="$ZSHRC_DIR"
ZSHRC="$ZDOTDIR/.zshrc"

echo "source $SHERPA_LIB_DIR/init.sh" > "$ZSHRC"

# ++ Reading from stdout and stderr
STDOUT_FILE=$(mktemp)
cleanup_file_or_dir_at_teardown "$STDOUT_FILE"
STDERR_FILE=$(mktemp)
cleanup_file_or_dir_at_teardown "$STDERR_FILE"

subject() {
  sherpa diagnose 1> "$STDOUT_FILE" 2> "$STDERR_FILE"
}


# ==============================================================================
# ++++ It warns when the cd hook is not setup correctly
stub "chpwd_functions=\"\""

subject

like "$(cat "$STDERR_FILE")" "\[NOT OK\] cd hook setup" "It warns when the cd hook is not setup correctly"

reset_stubs


# ==============================================================================
# ++++ It acknowledges when the cd hook is setup correctly
subject

like "$(cat "$STDOUT_FILE")" "\[OK\] cd hook setup" "It acknowledges when the cd hook is setup correctly"
