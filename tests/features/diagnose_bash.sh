print_std() {
  echo '-------------------------------SUCCESS'
  cat $STDOUT_FILE
  echo '-------------------------------ERROR'
  cat $STDERR_FILE
  echo '-------------------------------END'
}

# Setup
source tests/support/init.sh

# Sherpa runs the diagnostics with a shell script that would load the
# ~/.bashrc file.
BASHRC=$(mktemp)
echo "source $SHERPA_LIB_PATH/init.sh" > $BASHRC
BASHRC_FILE="$BASHRC"

STDOUT_FILE=$(mktemp)
STDERR_FILE=$(mktemp)

subject() {
  sherpa diagnose 1> "$STDOUT_FILE" 2> "$STDERR_FILE"
}


# ==== It warns when Sherpa is disabled
sherpa disable

subject

like "$(cat $STDERR_FILE)" "Sherpa is disabled!" "It warns when Sherpa is disabled"


# ==== It acknowledges when Sherpa is enabled
sherpa enable

subject

like "$(cat $STDOUT_FILE)" "\[OK\] Enabled" "It acknowledges when Sherpa is enabled"


# When the PROMPT_COMMAND got tempered with
# ==== It warns when the cd hook is not setup correctly
echo "export PROMPT_COMMAND=\"\"" >> $BASHRC

subject

like "$(cat $STDERR_FILE)" "\[NOT OK\] cd hook setup" "It warns when the cd hook is not setup correctly"

echo "source $SHERPA_LIB_PATH/init.sh" > $BASHRC


# ==== It acknowledges when the cd hook is setup correctly
subject

like "$(cat $STDOUT_FILE)" "\[OK\] cd hook setup" "It acknowledges when the cd hook is setup correctly"


# ==== It warns when trusting a directory fails
# Imitate a missing sha256sum command
cat <<EOF >> $BASHRC
sha256sum() {
  echo "sha256sum: command not found" >&2
  exit 1
}
EOF

subject

like "$(cat $STDERR_FILE)" "\[NOT OK\] Trust the current directory" "It warns when trusting a directory fails"
echo "source $SHERPA_LIB_PATH/init.sh" > $BASHRC


# ==== It acknowledges when trusting a directory succeeds
subject

like "$(cat $STDOUT_FILE)" "\[OK\] Trust the current directory" "It acknowledges when trusting a directory succeeds"


# ==== It warns when loading the local env fails
# Stub the echo command to simulate a local env loading failure
cat <<EOF >> $BASHRC
source() {
  return 1
}
EOF

subject

like "$(cat $STDERR_FILE)" "\[NOT OK\] Load the local environment" "It warns when loading the local env fails"
echo "source $SHERPA_LIB_PATH/init.sh" > $BASHRC

# ==== It acknowledges when loading the local env succeeds
subject

like "$(cat $STDOUT_FILE)" "\[OK\] Load the local environment" "It acknowledges when loading the local env succeeds"


# Todo unify the error messages and the success messages [OK] Load local env
# Tear down
# Todo move this to a hook
rm "$STDOUT_FILE"
rm "$STDERR_FILE"
rm "$BASHRC"
