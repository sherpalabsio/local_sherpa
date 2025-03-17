__SHERPA_ENV_STASH_VAR_PREFIX="__sherpa__env_stash"

# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰
#                            Environment Stash Utils
# 〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰〰

sherpa::env_stash.unstash_all() {
  local -r dir_path="$1"

  if [ -n "$ZSH_VERSION" ]; then
    unset "SHERPA_STATUS_INFO__VARS[\"$dir_path\"]"
    unset "SHERPA_STATUS_INFO__ALIASES[\"$dir_path\"]"
    unset "SHERPA_STATUS_INFO__FUNCTIONS[\"$dir_path\"]"
  else
    unset "SHERPA_STATUS_INFO__VARS[$dir_path]"
    unset "SHERPA_STATUS_INFO__ALIASES[$dir_path]"
    unset "SHERPA_STATUS_INFO__FUNCTIONS[$dir_path]"
  fi

  sherpa::env_stash.unstash_variables "$dir_path"
  sherpa::env_stash.unstash_functions "$dir_path"
  sherpa::env_stash.unstash_aliases "$dir_path"
}

sherpa::env_stash._item_to_variable_name() {
  local -r item_type="$1"
  local -r dir_path=${2:-$PWD}

  local -r directory_prefix=$(sherpa::env_stash._path_to_variable_prefix "$dir_path")

  echo "${__SHERPA_ENV_STASH_VAR_PREFIX}__${item_type}__${directory_prefix}"
}

sherpa::env_stash._path_to_variable_prefix() {
  local dir_path=${1:-$PWD}
  dir_path="${dir_path:1}" # Remove the first slash

  # Set the locale to ensure compatibility with non-ASCII characters
  local LC_CTYPE=C # This might be necessary only for Bash 4.x

  echo "${dir_path//[^a-zA-Z0-9]/_}"
}

sherpa::env_stash._escape_for_eval() {
  local string="$1"

  string="${string//\\/\\\\}"
  string="${string//\"/\\\"}"
  string="${string//\`/\\\`}"
  string="${string//\$/\\\$}"

  echo "$string"
}
