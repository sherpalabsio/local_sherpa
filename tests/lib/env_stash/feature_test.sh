source tests/support/test_helper.sh
source "$SHERPA_DIR/lib/env_stash/utils.sh"
source "$SHERPA_DIR/lib/env_stash/aliases.sh"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                      Stashing and unstashing environment
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ We can stash and unstash aliases

alias existing_alias1="echo existing_alias original content 1"
alias existing_alias2="echo existing_alias original content 2"

sherpa::env_stash.stash_aliases "$PWD" "existing_alias1" \
                                       "existing_alias2" \
                                       "not_yet_existing_alias1" \
                                       "not_yet_existing_alias2"

alias existing_alias1="echo CHANGED 1"
alias existing_alias2="echo CHANGED 2"
alias not_yet_existing_alias1="echo not yet existing alias content 1"
alias not_yet_existing_alias2="echo not yet existing alias content 2"

# Senety check
is "$(existing_alias1)" "CHANGED 1" "The existed alias1 changed"
is "$(existing_alias2)" "CHANGED 2" "The existed alias2 changed"
is "$(not_yet_existing_alias1)" "not yet existing alias content 1" "The new alias1 is set"
is "$(not_yet_existing_alias2)" "not yet existing alias content 2" "The new alias2 is set"

sherpa::env_stash.unstash_aliases "$PWD"

# ++++ It restores the overwritten aliases
is "$(existing_alias1)" "existing_alias original content 1" "The existed alias1 is restored"
is "$(existing_alias2)" "existing_alias original content 2" "The existed alias2 is restored"
# ++++ It removes the aliases which did not exist at the time of stashing
is_undefined "not_yet_existing_alias1" "The new alias1 is removed"
is_undefined "not_yet_existing_alias2" "The new alias2 is removed"
