source lib/init.zsh
source tests/support/tap-functions

SHERPA_CHECKSUM_DIR="$SHERPA_PATH/tests/playground/local_sherpa_checksums"
export SHERPA_LOG_LEVEL='no talk' # debug, info, no talking

if [ ! -n "$ZSH_VERSION" ]; then
  # Emulate the behavior of `cd` in interactive bash
  cd() {
    builtin cd "$@"
    alert_sherpa_we_changed_dir
  }
fi
