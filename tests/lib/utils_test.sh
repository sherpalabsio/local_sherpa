source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/utils.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                              remove_first_element
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It removes the first item from the given array

_my_list=(1)

_sherpa_utils::array::remove_first_element "_my_list"

assert_equal "${#_my_list[@]}" "0"

unset _my_list
