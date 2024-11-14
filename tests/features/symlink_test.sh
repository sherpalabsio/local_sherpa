source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                              Symlinking env files
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# == Senety checks: Project 1 env is not loaded
assert_undefined "var_1"
assert_undefined "alias_1"
assert_undefined "function_1"

# ==============================================================================
# ++++ It symlinks the Project 1 env file and loads it

sherpa symlink project_1

# shellcheck disable=SC2154
assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Symlinked env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Symlinked env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Symlinked env is loaded (function)"
