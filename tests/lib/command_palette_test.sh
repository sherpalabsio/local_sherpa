source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                    __sherpa_command_palette__load_env_items
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

rm -rf /tmp/local_sherpa_command_palette # Just in case if a previous run left it behind

mkdir project_x

cat << EOF > project_x/.envrc
export var_1="var_1 content"
export var_2="var_2 content"

function_name1() {
  echo "function content"
}

function_name2() {
  echo "function content"
}

alias alias_name1='echo "alias content"'
alias alias_name2="echo 'alias content'"
EOF

_sherpa_trust_dir "project_x"
cd project_x

__sherpa_command_palette__load_env_items > /dev/null

# ==============================================================================
# ++++ It stores definition of variables a temporary file

actual_content=$(cat /tmp/local_sherpa_command_palette/\$var_1)
expected_content="var_1 content"

assert_equal "$actual_content" "$expected_content" "It stores the definition of variables"

# ==============================================================================
# ++++ It stores definition of aliases in a temporary file

actual_content=$(cat /tmp/local_sherpa_command_palette/alias_name1)
expected_content='echo "alias content"'

assert_equal "$actual_content" "$expected_content" "It stores the definition of aliases with double quotes"

actual_content=$(cat /tmp/local_sherpa_command_palette/alias_name2)
expected_content="echo 'alias content'"

assert_equal "$actual_content" "$expected_content" "It stores the definition of aliases with single quotes"

# ==============================================================================
# ++++ It stores definition of functions in a temporary file

actual_content=$(cat /tmp/local_sherpa_command_palette/function_name1)

assert_contain "$actual_content" "function_name1 ()" "It stores the definition of functions"

# ==============================================================================
# ++++ It returns a sorted unique list of variables, aliases and functions

mkdir sub_project

cat << EOF > sub_project/.envrc
export var_1="overwritten var_1 content"

function_name1() {
  echo "overwritten function content"
}

alias alias_name1='overwritten alias content'
EOF

_sherpa_trust_dir "sub_project"
cd sub_project

__sherpa_command_palette__load_env_items > /dev/null

actual_content=$(__sherpa_command_palette__load_env_items)
expected_content="\$var_1
\$var_2
alias_name1
alias_name2
function_name1
function_name2"

assert_equal "$actual_content" "$expected_content" "It returns a sorted unique list of variables, aliases and functions"
