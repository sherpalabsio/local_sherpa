source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                      It won't load the already loaded env
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"

# == Sanity checks: the Global env is loaded
assert_equal "$var_1" "GLOBAL VAR" "Global env is ready (var)"

cd project_1
cd subfolder_with_no_env

actual_warning_message=$(SHERPA_LOG_LEVEL="debug" ; cd ..)
expected_warning_message="Env is already loaded"

assert_contain "$actual_warning_message" "$expected_warning_message" "It does not reload the Project 1 env"
