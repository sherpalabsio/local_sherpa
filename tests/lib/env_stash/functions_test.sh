source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"
source "$SHERPA_DIR/lib/env_stash/functions.sh"
source "$SHERPA_DIR/lib/env_stash/aliases.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                stash_functions
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

dir_path="/parent/child"

# ==============================================================================
# xxxx When the function already exists
# ++++ It stores the functions definition in the correct list

existing_function1() { function1 content; }
existing_function2() { function2 content; }

expected_existing_function_definition1="existing_function1() { function1 content }"
expected_existing_function_definition2="existing_function2() { function2 content }"

sherpa::env_stash.stash_functions "$dir_path" "existing_function1" "existing_function2"

actual_existing_function_definition1=${__sherpa__env_stash__functions_to_restore__parent_child[*]:0:1}
assert_equal_compact "$actual_existing_function_definition1" "$expected_existing_function_definition1"

actual_existing_function_definition2=${__sherpa__env_stash__functions_to_restore__parent_child[*]:1:1}
assert_equal_compact "$actual_existing_function_definition2" "$expected_existing_function_definition2"

# ==============================================================================
# xxxx When the function is new
# ++++ It stores the functions definition in the correct list

sherpa::env_stash.stash_functions "$dir_path" "non_existing_function1" "non_existing_function2"

expected_new_function_names="__super_existing_function1 __super_existing_function2 non_existing_function1 non_existing_function2"
# shellcheck disable=SC2154
actual_new_function_names=${__sherpa__env_stash__functions_to_remove__parent_child[*]}

assert_equal "$actual_new_function_names" "$expected_new_function_names"

# ==============================================================================
# xxxx When the function is new but there is an alias with the same name
# ++++ It stores the functions definition in the correct list

__sherpa__env_stash__functions_to_remove__parent_child=()

alias non_existing_function1="echo 1"

sherpa::env_stash.stash_functions "$dir_path" "non_existing_function1"

expected_new_function_names="non_existing_function1"
# shellcheck disable=SC2154
actual_new_function_names=${__sherpa__env_stash__functions_to_remove__parent_child[*]}

assert_equal "$actual_new_function_names" "$expected_new_function_names"

# ==============================================================================
# ++++ It sanitizes the definition of existing functions

__sherpa__env_stash__functions_to_restore__parent_child=()

# shellcheck disable=SC2016,SC2288
function_with_special_chars1() { 'echo "My name is `custom_function`"'; }
expected_function_definition1="function_with_special_chars1() { 'echo \"My name is \`custom_function\`\"' }"

# shellcheck disable=SC2016,SC2288
function_with_special_chars2() { 'echo "$custom_var"'; }
expected_function_definition2="function_with_special_chars2() { 'echo \"\$custom_var\"' }"

sherpa::env_stash.stash_functions "$dir_path" "function_with_special_chars1" "function_with_special_chars2"

actual_function_definition1=${__sherpa__env_stash__functions_to_restore__parent_child[*]:0:1}
assert_equal_compact "$actual_function_definition1" "$expected_function_definition1"

actual_function_definition2=${__sherpa__env_stash__functions_to_restore__parent_child[*]:1:1}
assert_equal_compact "$actual_function_definition2" "$expected_function_definition2"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                               unstash_functions
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It removes the variables that we use to store the tmp stash data

existing_function() { :; }

sherpa::env_stash.stash_functions "$dir_path" "existing_function" "non_existing_function"
sherpa::env_stash.unstash_functions "$dir_path"

assert_undefined "__sherpa__env_stash__functions_to_restore__parent_child"
assert_undefined "__sherpa__env_stash__functions_to_remove__parent_child"
