# Test harness for the diagnose feature
# We need to test Zsh and Bash separately because they setup the cd hook differently

set -e

case $TARGET_SHELL_NAME in
  Bash)
    TARGET_SHELL_NAME="Bash"
    # We run the tests in interactive mode to be able to test aliases
    bash --noprofile --norc -i ./tests/features/diagnose/bash.sh;;
  Zsh)
    zsh ./tests/features/diagnose/zsh.sh;;
    *)
    echo "Unknown shell: $TARGET_SHELL_NAME" >&2 ; exit 1;;
esac
