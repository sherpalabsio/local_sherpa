source tests/lib/init.sh

plan_no_plan

cd tests/fixtures/parsing

expected_list="var_1
VAR_2
var_multi_line
alias_1
ALIAS_2
alias_multi_line
function_1
FUNCTION_2
function_with_comment"

actual_list=$(parse_local_env_file)

is "$actual_list" "$expected_list" "list of variable, function and alias names"
