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

alias alias_name='echo "alias content"'

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

  cat > /tmp/fzf_input_list.txt

  sleep 1
}

sherpa palette &
sherpa_palette_pid=$!
sleep 0.2 # Wait for the command palette to finish until the first fzf call

# ==============================================================================
# ++++ Smoke test

actual_content=$(cat /tmp/local_sherpa_command_palette/\$var_1)
expected_content="var_1 content"

assert_equal "$actual_content" "$expected_content" "It does not smoke"

# ==============================================================================
# ++++ Calls fzf with the correct env items

actual_env_items=$(cat /tmp/fzf_input_list.txt)
expected_env_items="\$var_1
alias_name
function_name"

assert_equal "$actual_env_items" "$expected_env_items" "It calls fzf with the correct env items"

# ==============================================================================
# ++++ Teardown

rm -f /tmp/fzf_input_list.txt
wait $sherpa_palette_pid
