source tests/support/app_helper.sh

stub_env_file

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                   Fetching variable names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple variables

override_env_file "export var_1="local var 1""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "var_1"

# ==============================================================================
# ++++ It is not case sensitive

override_env_file "export VAR_2="local var 1""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "VAR_2"

# ==============================================================================
# ++++ It works for multiline variables

cat <<EOF | override_env_file
export var_multi_line="local var
multi line"
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "var_multi_line"

# ==============================================================================
# ++++ It ignores commented lines

override_env_file "# export var_commented="local var 0""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                     Fetching alias names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple aliases

override_env_file "alias alias_1='echo "local alias 1"'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "alias_1"

# ==============================================================================
# ++++ It is not case sensitive

override_env_file "alias ALIAS_2='echo "local alias 2"'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "ALIAS_2"

# ==============================================================================
# ++++ It works for multiline aliases

cat <<EOF | override_env_file
alias alias_multi_line='echo "local alias 1";
echo "local alias 2";'
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "alias_multi_line"

# ==============================================================================
# ++++ It ignores commented lines

override_env_file "# alias alias_commented='echo "local alias 0";'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                   Fetching function names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple aliases

cat <<EOF | override_env_file
function_1() {
  echo "local function 1"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "function_1"

# ==============================================================================
# ++++ It is not case sensitive

cat <<EOF | override_env_file
FUNCTION_2() {
  echo "local function 2"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "FUNCTION_2"

# ==============================================================================
# ++++ It works for functions defined with the function keyword

cat <<EOF | override_env_file
function function_3() {
  echo "local function 3"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "function_3"

# ==============================================================================
# ++++ It ignores commented lines

cat <<EOF | override_env_file
# Commented function
# function_commented() {
#   # comment
#   echo "local function 0"
# }
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""
