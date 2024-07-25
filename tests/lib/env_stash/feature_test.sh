source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"
source "$SHERPA_DIR/lib/env_stash/aliases.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                      Stashing and unstashing environment
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ We can stash and unstash aliases

alias existing_alias="echo ori_existing_alias_content"

sherpa::env_stash.stash_aliases "$PWD" "existing_alias" "not_yet_existing_alias"

alias existing_alias="echo CHANGED"
alias not_yet_existing_alias="echo not_yet_existing_alias_content"

# Senety check
is "$(existing_alias)" "CHANGED"
is "$(not_yet_existing_alias)" "not_yet_existing_alias_content"

sherpa::env_stash.unstash_aliases "$PWD"

# ++++ It restores the overwritten aliases
is "$(existing_alias)" "ori_existing_alias_content"
# ++++ It removes the aliases which did not exist at time of stashing
is_undefined "not_yet_existing_alias"
