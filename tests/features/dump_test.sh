source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                           Pruning permissions files
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

stub_env_file

# ==============================================================================
# ++++ It dumps the current env file into an example file

cat << EOF | overwrite_env_file "$@"
alias alias_name="command"

function_name() {
  inside_var="value"
}
EOF

expected_env_file=$(
                    cat << EOF
alias alias_name="command"

function_name() {
  inside_var="value"
}
EOF
)

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "$expected_env_file"

# ==============================================================================
# ++++ It sanitizes the exported variables

overwrite_env_file "export VAR_1=\"local var 1\""

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "export VAR_1="

# ==============================================================================
# ++++ It sanitizes the non-exported variables

overwrite_env_file "VAR_1=\"local var 1\""

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "VAR_1="

# ==============================================================================
# ++++ It doesn't sanitize the exported variables if marked to keep

overwrite_env_file "export VAR_1=\"local var 1\" # keep"

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "export VAR_1=\"local var 1\" # keep"

# ==============================================================================
# ++++ It doesn't sanitize the non-exported variables if marked to keep

overwrite_env_file "VAR_1=\"local var 1\" # keep"

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "VAR_1=\"local var 1\" # keep"
