source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"
source "$SHERPA_DIR/lib/env_stash/aliases.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                  stash_aliases
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

dir_path="/parent/child"

# ==============================================================================
# ++++ It stores the definition of existing aliases in the right list

alias existing_alias1="alias1 content"
alias existing_alias2="alias2 content"

expected_existing_alias_definition1="existing_alias1='alias1 content'"
expected_existing_alias_definition2="existing_alias2='alias2 content'"

sherpa::env_stash.stash_aliases "$dir_path" "existing_alias1" "existing_alias2"

actual_existing_alias_definition1=${__sherpa__env_stash__aliases_to_restore__parent_child[*]:0:1}
is "$actual_existing_alias_definition1" "$expected_existing_alias_definition1"

actual_existing_alias_definition2=${__sherpa__env_stash__aliases_to_restore__parent_child[*]:1:1}
is "$actual_existing_alias_definition2" "$expected_existing_alias_definition2"

# ==============================================================================
# ++++ It stores the names of new aliases in the right list

sherpa::env_stash.stash_aliases "$dir_path" "non_existing_alias1" "non_existing_alias2"

expected_new_alias_names="non_existing_alias1 non_existing_alias2"
# shellcheck disable=SC2154
actual_new_alias_names=${__sherpa__env_stash__aliases_to_remove__parent_child[*]}

is "$actual_new_alias_names" "$expected_new_alias_names"

# ==============================================================================
# ++++ It sanitizes the definition of existing aliases

__sherpa__env_stash__aliases_to_restore__parent_child=()

alias alias_with_special_chars1='echo "My name is `custom_function`"'
expected_alias_definition1="alias_with_special_chars1='echo \"My name is \`custom_function\`\"'"

# shellcheck disable=SC2154
alias alias_with_special_chars2='echo "$custom_var"'
expected_alias_definition2="alias_with_special_chars2='echo \"\$custom_var\"'"

sherpa::env_stash.stash_aliases "$dir_path" "alias_with_special_chars1" "alias_with_special_chars2"

actual_alias_definition1=${__sherpa__env_stash__aliases_to_restore__parent_child[*]:0:1}
is "$actual_alias_definition1" "$expected_alias_definition1"

actual_alias_definition2=${__sherpa__env_stash__aliases_to_restore__parent_child[*]:1:1}
is "$actual_alias_definition2" "$expected_alias_definition2"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                unstash_aliases
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It removes the variables that we use to store the tmp stash data

alias existing_alias="_"

sherpa::env_stash.stash_aliases "$dir_path" "existing_alias" "non_existing_alias"
sherpa::env_stash.unstash_aliases "$dir_path"

is_undefined "__sherpa__env_stash__aliases_to_restore__parent_child"
is_undefined "__sherpa__env_stash__aliases_to_remove__parent_child"
