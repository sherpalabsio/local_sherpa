source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                         Enabling and disabling Sherpa
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"
_sherpa_trust_dir "project_2"


# ==============================================================================
# xxxx When Sherpa is enabled and we go to a project with an env file

cd project_1

# ++++ It loads the env

assert_equal "$var_1" "LOCAL VAR PROJECT 1" "Env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 1" "Env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 1" "Env is loaded (function)"


# ==============================================================================
# xxxx When the user disables Sherpa

sherpa off

# ++++ It unloaded the env and goes to sleep

assert_equal "$var_1" "GLOBAL VAR" "Env is unloaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Env is unloaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Env is unloaded (function)"


# ==============================================================================
# xxxx When we go to another project with an env file while Sherpa is sleeping

cd ../project_2

# ++++ It doesn't load any env

assert_equal "$var_1" "GLOBAL VAR" "Env is NOT loaded (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Env is NOT loaded (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Env is NOT loaded (function)"


# ==============================================================================
# xxxx When the user wakes the Sherpa up
sherpa work

# ++++ It wakes up and loads the env

assert_equal "$var_1" "LOCAL VAR PROJECT 2" "Env is loaded (var)"
assert_equal "$(alias_1)" "LOCAL ALIAS PROJECT 2" "Env is loaded (alias)"
assert_equal "$(function_1)" "LOCAL FUNCTION PROJECT 2" "Env is loaded (function)"
