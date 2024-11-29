source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                            _path_to_variable_prefix
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It replaces all non alphanumeric characters with underscores and removes
#      the first slash

dir_path="/parent/child/ space /áé/-dash-"
expected="parent_child__space________dash_"

actual=$(sherpa::env_stash._path_to_variable_prefix "$dir_path")

assert_equal "$actual" "$expected" "It replaces all non alphanumeric characters with underscores"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                             _item_to_variable_name
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It returns the correct variable name

item_name="alias_name"
dir_path="/parent/child"
expected="__sherpa__env_stash__alias_name__parent_child"

actual=$(sherpa::env_stash._item_to_variable_name "$item_name" "$dir_path")

assert_equal "$actual" "$expected"
