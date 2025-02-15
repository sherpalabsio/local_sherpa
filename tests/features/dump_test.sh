source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                           Pruning permissions files
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

stub_env_file

# ==============================================================================
# ++++ It dumps the current env file into an example file

overwrite_env_file "export VAR_2=\"local var 1\""

sherpa dump

actual_env_file=$(cat "$SHERPA_ENV_FILENAME.example")

assert_equal "$actual_env_file" "export VAR_2=\"local var 1\""
