source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"
source "$SHERPA_DIR/lib/env_stash/variables.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                stash_variables
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

dir_path="/parent/child"

# ==============================================================================
# ++++ It stores the definition of existing variables in the right list

# shellcheck disable=SC2034
existing_variable1="variable1 content"
# shellcheck disable=SC2034
existing_variable2="variable2 content"

expected_existing_variable_definition1="existing_variable1=.variable1 content."
expected_existing_variable_definition2="existing_variable2=.variable2 content."

sherpa::env_stash.stash_variables "$dir_path" "existing_variable1" "existing_variable2"

# shellcheck disable=SC2154
actual_existing_variable_definition1=${__sherpa__env_stash__variables_to_restore__parent_child[*]:0:1}
assert_contain "$actual_existing_variable_definition1" "$expected_existing_variable_definition1"

actual_existing_variable_definition2=${__sherpa__env_stash__variables_to_restore__parent_child[*]:1:1}
assert_contain "$actual_existing_variable_definition2" "$expected_existing_variable_definition2"


# ==============================================================================
# ++++ It stores the names of new variables in the right list

sherpa::env_stash.stash_variables "$dir_path" "non_existing_variable1" "non_existing_variable2"

expected_new_variable_names="non_existing_variable1 non_existing_variable2"
# shellcheck disable=SC2154
actual_new_variable_names=${__sherpa__env_stash__variables_to_remove__parent_child[*]}

assert_contain "$actual_new_variable_names" "$expected_new_variable_names"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                               unstash_variables
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It removes the variables that we use to store the tmp stash data

# shellcheck disable=SC2034
existing_variable="_"

sherpa::env_stash.stash_variables "$dir_path" "existing_variable" "non_existing_variable"
sherpa::env_stash.unstash_variables "$dir_path"

assert_undefined "__sherpa__env_stash__variables_to_restore__parent_child"
assert_undefined "__sherpa__env_stash__variables_to_remove__parent_child"
