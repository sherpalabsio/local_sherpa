# shellcheck disable=SC2034
TIMEFMT=$'%mE'
TIMEFORMAT='%Rs'

source tests/support/app_helper.sh

varstash_dir="$SHERPA_DIR/tests/playground/performance"
cd "$SHERPA_DIR/tests/playground/performance"

source .envrc

# shellcheck disable=SC2207
alias_names=($(_sherpa_fetch_aliase_names_from_env_file))

stash_varstash() {
  varstash::autostash "${alias_names[@]}"
  varstash::autounstash
}

stash_env_stash() {
  sherpa::env_stash.stash_aliases "$varstash_dir" "${alias_names[@]}"
  sherpa::env_stash.unstash_aliases "$varstash_dir"
}

printf "Varstash: "
time (stash_varstash)

printf "Envstash: "
time (stash_env_stash)
