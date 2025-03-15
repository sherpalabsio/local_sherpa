source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                           Pruning permissions files
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

_sherpa_trust_dir "project_1"

# == Sanity checks: the permissions files was created
file_count=$(find local_sherpa_checksums -type f | wc -l | awk '{print $1}')
assert_equal "$file_count" "1"

# ==============================================================================
# ++++ It removes permissions files pointing to non-existing directories

rm -rf project_1

prune_output=$(sherpa prune)

file_count=$(find local_sherpa_checksums -type f | wc -l | awk '{print $1}')

assert_equal "$file_count" "0" "The permission file is removed"
assert_contain "$prune_output" "/project_1" "The output includes '/project_1'"
