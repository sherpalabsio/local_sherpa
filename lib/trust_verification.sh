#!/bin/bash

set -o pipefail

_calculate_checksum() {
  sha256sum "$SHERPA_LOCAL_ENV_FILE" | cut -d ' ' -f 1
}

verify_trust() {
  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"

  local current_checksum
  current_checksum=$(_calculate_checksum)

  # No checksum file?
  if [[ ! -f "$checksum_file" ]]; then
    log_info "The local env file is not trusted. Run \`sherpa trust\` to mark it as trusted."
    return 1
  fi

  local stored_checksum
  stored_checksum=$(cat "$checksum_file")

  # Did the local env file change?
  if [[ "$current_checksum" != "$stored_checksum" ]]; then
    log_info "The local env file has changed. Run \`sherpa trust\` to mark it trusted."
    return 1
  fi

  # The local env file is trusted
  return 0
}

trust_current_env() {
  # return 1
  if [[ ! -f "$SHERPA_LOCAL_ENV_FILE" ]]; then
    log_info "Nothing to trust. The current directory has no local env file. Run \`sherpa edit\` to create one."
    return 1
  fi

  mkdir -p "$SHERPA_CHECKSUM_DIR"

  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"
  local current_checksum

  if ! current_checksum=$(_calculate_checksum); then
    # Skip if the checksum calculation chrashed
    echo "Sherpa: Checksum calculation failed" >&2
    return 1
  fi

  echo "$current_checksum" > "$checksum_file"
  log_info "Trusted!"

  return 0
}

untrust_current_env() {
  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"

  if [[ -f "$checksum_file" ]]; then
    rm "$checksum_file"
    log_info "Trust revoked!"
  else
    log_info "The local env file was not trusted before."
  fi
}
