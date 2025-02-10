source tests/support/app_helper.sh

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                           Pruning permissions files
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

# ==============================================================================
# ++++ Setup

_sherpa_trust_dir "project_1"

# == Sanity checks: the permissions files was created
file_count=$(ls local_sherpa_checksums | wc -l | awk '{print $1}')
assert_equal "$file_count" "1"

# ==============================================================================
# ++++ It removes permissions files pointing to non-existing directories

rm -rf project_1

sherpa prune

file_count=$(ls local_sherpa_checksums | wc -l | awk '{print $1}')

assert_equal "$file_count" "0" "The permission file is removed"
