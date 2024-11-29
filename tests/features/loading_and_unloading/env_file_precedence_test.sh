source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#       Items defined by the env file take precedence over the global env
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"

# == Sanity checks: the Global env is loaded
assert_equal "$(existing_alias_shadowing_new_function)" "ORIGINAL ALIAS" "The global env is loaded (alias)"
assert_equal "$(existing_function_shadowing_new_alias)" "ORIGINAL FUNCTION" "The global env is loaded (function)"

# ==============================================================================
# ++++ Functions created by the env file take precedence over existing aliases

cd project_1

assert_equal "$(existing_alias_shadowing_new_function)" "OVERWRITTEN ALIAS" "The new function takes precedence over the existing alias"


# ==============================================================================
# ++++ It restores the global alias

cd ..

assert_equal "$(existing_alias_shadowing_new_function)" "ORIGINAL ALIAS" "The original alias is restored"


# ==============================================================================
# ++++ Aliases created by the env file take precedence over existing functions

cd project_1

assert_equal "$(existing_function_shadowing_new_alias)" "OVERWRITTEN FUNCTION" "The new alias takes precedence over the existing function"


# ==============================================================================
# ++++ It restores the global function

cd ..

assert_equal "$(existing_function_shadowing_new_alias)" "ORIGINAL FUNCTION" "The original function is restored"
