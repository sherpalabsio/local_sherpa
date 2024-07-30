source tests/support/app_helper.sh

# ‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾‾
#                                      Setup
# ______________________________________________________________________________
source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"

# ++++ Senety checks: the Global env is loaded
assert_equal "$var_1" "GLOBAL VAR" "Global env is ready (var)"
assert_equal "$(alias_1)" "GLOBAL ALIAS" "Global env is ready (alias)"
assert_equal "$(function_1)" "GLOBAL FUNCTION" "Global env is ready (function)"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                             Reloading the same env
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
# PWD: /project_1

cd project_1
cd subfolder_with_no_local_env

# ++++ It does not reload the already loaded Project 1 env
actual_warning_message=$(SHERPA_LOG_LEVEL='debug' ; cd ..)
expected_warning_message="Local env is already loaded"

assert_contain "$actual_warning_message" "$expected_warning_message" "It does not reload the Project 1 env"
