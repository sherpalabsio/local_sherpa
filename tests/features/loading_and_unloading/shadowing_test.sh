source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                   Shadowing
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

source .bash_profile # Imitate global env
_sherpa_trust_dir "project_1"

# == Senety checks: the Global env is loaded
assert_equal "$(existing_alias_shadowing_new_function)" "ORIGINAL ALIAS" "The global env is loaded (alias)"
assert_equal "$(existing_function_shadowing_new_alias)" "ORIGINAL FUNCTION" "The global env is loaded (function)"

# ==============================================================================
# ++++ It makes sure that newly created functions take precedence over existing aliases

cd project_1

assert_equal "$(existing_alias_shadowing_new_function)" "OVERWRITTEN ALIAS" "The new function takes precedence over the existing alias"


# ==============================================================================
# ++++ It restores the original alias

cd ..

assert_equal "$(existing_alias_shadowing_new_function)" "ORIGINAL ALIAS" "The original alias is restored"


# ==============================================================================
# ++++ It makes sure that newly created aliases take precedence over existing functions

cd project_1

assert_equal "$(existing_function_shadowing_new_alias)" "OVERWRITTEN FUNCTION" "The new alais takes precedence over the existing function"


# ==============================================================================
# ++++ It restores the original function

cd ..

assert_equal "$(existing_function_shadowing_new_alias)" "ORIGINAL FUNCTION" "The original function is restored"
