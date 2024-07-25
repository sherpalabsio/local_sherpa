# shellcheck disable=SC2034
TIMEFMT=$'%mE'
TIMEFORMAT='%Rs'

source tests/support/app_helper.sh

varstash_dir="$SHERPA_DIR/tests/playground/performance"
cd "$SHERPA_DIR/tests/playground/performance"
# shellcheck disable=SC1091
source .envrc

echo "=============================== Aliases ==============================="

# shellcheck disable=SC2207
alias_names=($(_sherpa_fetch_aliase_names_from_env_file))

run_varstash() {
  varstash::autostash "${alias_names[@]}"
  varstash::autounstash
}

run_env_stash() {
  sherpa::env_stash.stash_aliases "$varstash_dir" "${alias_names[@]}"
  sherpa::env_stash.unstash_aliases "$varstash_dir"
}

printf "Varstash: "
time (run_varstash)

printf "Envstash: "
time (run_env_stash)


echo "=============================== Functions ==============================="

# shellcheck disable=SC2207
function_names=($(_sherpa_fetch_function_names_from_env_file))

run_varstash() {
  varstash::autostash "${function_names[@]}"
  varstash::autounstash
}

run_env_stash() {
  sherpa::env_stash.stash_functions "$varstash_dir" "${function_names[@]}"
  sherpa::env_stash.unstash_functions "$varstash_dir"
}

printf "Varstash: "
time (run_varstash)

printf "Envstash: "
time (run_env_stash)
