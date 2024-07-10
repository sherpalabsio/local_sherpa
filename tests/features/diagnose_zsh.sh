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
