# if TARGET_SHELL_NAME == bash then run bash

set -e

case $TARGET_SHELL_NAME in
  Bash)
    TARGET_SHELL_NAME="Bash"
    # We run the tests in interactive mode to be able to test aliases
    bash --noprofile --norc -i ./tests/features/diagnose_bash.sh;;
  Zsh)
    zsh ./tests/features/diagnose_zsh.sh;;
    *)
    echo "Unknown shell: $TARGET_SHELL_NAME"; exit 1;;
esac
