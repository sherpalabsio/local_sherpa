source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                Command palette
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

rm -rf /tmp/local_sherpa_command_palette

stub_env_file

cat << EOF | overwrite_env_file "$@"
export var_1="var_1 content"

alias alias_name1='echo "alias content"'
alias alias_name2="echo 'alias content'"

function_name() {
  echo "function content"
}
EOF

_sherpa_trust_dir "/"
cd /

# Stub fzf
fzf() {
  local -r first_param="$1"

  if [[ "$first_param" == "--version" ]]; then
    echo "0.42.0"
    return
  fi

  sleep 1
}

sherpa palette &
sherpa_palette_pid=$!
sleep 0.2 # Wait for the command palette to finish until the first fzf call

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

actual_content=$(cat /tmp/local_sherpa_command_palette/function_name)

assert_contain "$actual_content" "function_name ()" "It stores the definition of functions"

# ==============================================================================
# ++++ Teardown

wait $sherpa_palette_pid
