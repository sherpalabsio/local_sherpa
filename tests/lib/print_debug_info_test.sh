source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                        Print the loaded shell entities
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

_sherpa_trust_dir "project_1"
_sherpa_trust_dir "project_1/subfolder_with_no_env/subproject"
cd project_1
cd subfolder_with_no_env/subproject

# ==============================================================================
# ++++ It lists the added or changed variables

expected_output="
== Variables
- custom_var_1
- var_1"

assert_contain "$(_sherpa_print_debug_info)" "$expected_output"

# ==============================================================================
# ++++ It lists the added or changed aliases

expected_output="
== Aliases
- alias_1
- custom_alias_1
- existing_function_shadowing_new_alias"

assert_contain "$(_sherpa_print_debug_info)" "$expected_output"

# ==============================================================================
# ++++ It lists the added or changed functions

expected_output="
== Functions
- custom_function_1
- existing_alias_shadowing_new_function
- function_1"

assert_contain "$(_sherpa_print_debug_info)" "$expected_output"

# ==============================================================================
# ++++ It removes items when they are unloaded

cd ~

assert_not_contain "$(_sherpa_print_debug_info)" "== Functions"
