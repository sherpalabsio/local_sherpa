source tests/support/init.sh

# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#                                      Setup
# ______________________________________________________________________________
# shellcheck disable=SC2034
SHERPA_CONFIG_DIR="$TMP_TEST_DIR/tests/playground/local_sherpa_config"

# ==============================================================================
# ++++ Senety checks: Project 1 env is not loaded
is_undefined "var_1"
is_undefined "alias_1"
is_undefined "function_1"

# ==============================================================================
# PWD: /
# ++++ It symlinks the Project 1 env and loads its env
sherpa symlink project_1

# shellcheck disable=SC2154
is "$var_1" "LOCAL VAR PROJECT 1" "Symlinked env is loaded (var)"
is "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Symlinked env is loaded (alias)"
is "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Symlinked env is loaded (function)"
