source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                                Command palette
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

rm -rf /tmp/local_sherpa_command_palette
rm -f /tmp/fzf_input_list_1.txt /tmp/fzf_input_list_2.txt

stub_env_file

cat << EOF | overwrite_env_file "$@"
export var_1="var_1 content"

alias alias_name='echo "alias content"'

function_name() {
  echo "function content"
}
EOF

_sherpa_trust_dir "/"
cd /

# Stub fzf
# It hits tab on the first call to switch to the other list
echo 0 > /tmp/fzf_call_count.txt

fzf() {
  local -r first_param="$1"

  if [[ "$first_param" == "--version" ]]; then
    echo "0.42.0"
    return
  fi

  local -r call_count=$(($(cat /tmp/fzf_call_count.txt) + 1))
  echo "$call_count" > /tmp/fzf_call_count.txt

  cat > "/tmp/fzf_input_list_$call_count.txt"

  if [[ "$call_count" == 1 ]]; then
    echo "tab"
    return
  fi

  sleep 1
}

sherpa palette &
sherpa_palette_pid=$!
sleep 0.2 # Wait for the command palette to finish until the last fzf call

# ==============================================================================
# ++++ Smoke test

actual_content=$(cat /tmp/local_sherpa_command_palette/\$var_1)
expected_content="var_1 content"

assert_equal "$actual_content" "$expected_content" "It does not smoke"

# ==============================================================================
# ++++ Hides the variables by default

actual_env_items=$(cat /tmp/fzf_input_list_1.txt)
expected_env_items="alias_name
function_name"

assert_equal "$actual_env_items" "$expected_env_items" "It shows the commands only by default"

# ==============================================================================
# ++++ Tab switches to the variables

actual_env_items=$(cat /tmp/fzf_input_list_2.txt)
expected_env_items="\$var_1"

assert_equal "$actual_env_items" "$expected_env_items" "It shows the variables after hitting tab"

# ==============================================================================
# ++++ Teardown

rm -f /tmp/fzf_input_list_1.txt /tmp/fzf_input_list_2.txt /tmp/fzf_call_count.txt
wait $sherpa_palette_pid
