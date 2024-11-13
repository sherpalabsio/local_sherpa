source tests/support/app_helper.sh

stub_env_file

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                   Fetching variable names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple variables

overwrite_env_file "export var_1="local var 1""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "var_1"


# ==============================================================================
# ++++ It is not case sensitive

overwrite_env_file "export VAR_2="local var 1""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "VAR_2"


# ==============================================================================
# ++++ It works for multiline variables

cat <<EOF | overwrite_env_file
export var_multi_line="local var
multi line"
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "var_multi_line"


# ==============================================================================
# ++++ It ignores commented lines

overwrite_env_file "# export var_commented="local var 0""

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""


# ==============================================================================
# ++++ It works for dynamically created variables

SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING=true

# shellcheck disable=SC2034
existing_non_changed_var="1"
# shellcheck disable=SC2034
existing_changed_var="1"

cat <<EOF | overwrite_env_file
eval "existing_changed_var=CHANGED"
eval "new_var=new"
EOF

expected_list="existing_changed_var
new_var"

actual_list=$(_sherpa_parse_local_env_file | sort)

assert_equal "$actual_list" "$expected_list"

unset SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                     Fetching alias names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple aliases

overwrite_env_file "alias alias_1='echo "local alias 1"'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "alias_1"


# ==============================================================================
# ++++ It is not case sensitive

overwrite_env_file "alias ALIAS_2='echo "local alias 2"'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "ALIAS_2"


# ==============================================================================
# ++++ It works for multiline aliases

cat <<EOF | overwrite_env_file
alias alias_multi_line='echo "local alias 1";
echo "local alias 2";'
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "alias_multi_line"


# ==============================================================================
# ++++ It ignores commented lines

overwrite_env_file "# alias alias_commented='echo "local alias 0";'"

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""


# ==============================================================================
# ++++ It works for aliases removed by the env file

override_env_file "unalias removed_alias1 removed_alias2
unalias removed_alias3"

actual_list=$(_sherpa_parse_local_env_file)
expect_list="removed_alias1
removed_alias2
removed_alias3"

assert_equal "$actual_list" "$expect_list"


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                Dynamic parsing
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING=true

# ==============================================================================
# ++++ It works for dynamically created aliases

alias untouched_existing_alias="echo 1"
alias overriden_existing_alias="echo 1"

cat <<EOF | overwrite_env_file
eval "alias overriden_existing_alias='echo 2'";
alias new_alias='echo 1';
echo "Trick" # It ignores print commands in the env file
EOF

actual_list=$(_sherpa_parse_local_env_file)
expected_list="new_alias
overriden_existing_alias"

assert_equal "$actual_list" "$expected_list"


# ==============================================================================
# ++++ It works for aliases removed by the env file

override_env_file "unalias removed_alias1 removed_alias2
unalias removed_alias3"

actual_list=$(_sherpa_parse_local_env_file)
expect_list="removed_alias1
removed_alias2
removed_alias3"

assert_equal "$actual_list" "$expect_list"


unset SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING


# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                   Fetching function names from the env file
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ It works for simple aliases

cat <<EOF | overwrite_env_file
function_1() {
  echo "local function 1"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "function_1"


# ==============================================================================
# ++++ It is not case sensitive

cat <<EOF | overwrite_env_file
FUNCTION_2() {
  echo "local function 2"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "FUNCTION_2"


# ==============================================================================
# ++++ It works for functions defined with the function keyword

cat <<EOF | overwrite_env_file
function function_3() {
  echo "local function 3"
}
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "function_3"


# ==============================================================================
# ++++ It ignores commented lines

cat <<EOF | overwrite_env_file
# Commented function
# function_commented() {
#   # comment
#   echo "local function 0"
# }
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" ""


# ==============================================================================
# ++++ It works for dynamically created functions

SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING=true

existing_function() { echo 1; }
function_1() { echo 1; }

cat <<EOF | overwrite_env_file
eval "function function_1() { echo 1; }"
EOF

actual_list=$(_sherpa_parse_local_env_file)

assert_equal "$actual_list" "function_1"

unset SHERPA_ENABLE_DYNAMIC_ENV_FILE_PARSING
