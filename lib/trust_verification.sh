#!/bin/bash

set -o pipefail

_calculate_checksum() {
  if ! sha256sum "$SHERPA_ENV_FILENAME" | cut -d ' ' -f 1; then
    if [ -r "$FILE" ]; then
      _local_sherpa_log_error "Checksum calculation failed"
    else
      _local_sherpa_log_error "The local env file is not readable. Permission issue?"
    fi

    return 1
  fi
}

_local_sherpa_verify_trust() {
  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"

  local current_checksum

  if ! current_checksum=$(_calculate_checksum); then
    # Skip if the checksum calculation failed
    return 1
  fi

  # No checksum file?
  if [[ ! -f "$checksum_file" ]]; then
    _local_sherpa_log_info "The local env file is not trusted. Run \`sherpa trust\` to mark it as trusted."
    return 1
  fi

  local stored_checksum
  stored_checksum=$(cat "$checksum_file")

  # Did the local env file change?
  if [[ "$current_checksum" != "$stored_checksum" ]]; then
    _local_sherpa_log_info "The local env file has changed. Run \`sherpa trust\` to mark it trusted."
    return 1
  fi

  # The local env file is trusted
  return 0
}

_local_sherpa_trust_current_dir() {
  if [[ ! -f "$SHERPA_ENV_FILENAME" ]]; then
    _local_sherpa_log_info "Nothing to trust. The current directory has no local env file. Run \`sherpa edit\` to create one."
    return 1
  fi

  mkdir -p "$SHERPA_CHECKSUM_DIR"

  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"
  local current_checksum

  if ! current_checksum=$(_calculate_checksum); then
    # Skip if the checksum calculation failed
    return 1
  fi

  echo "$current_checksum" > "$checksum_file"
  _local_sherpa_log_info "Trusted!"

  return 0
}

_local_sherpa_untrust_current_dir() {
  local checksum_file
  checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"

  if [[ -f "$checksum_file" ]]; then
    rm "$checksum_file"
    _local_sherpa_log_info "Trust revoked!"
  else
    _local_sherpa_log_info "The local env file was not trusted before."
  fi
}
