#!/bin/bash

calculate_checksum() {
  sha256sum .local-sherpa | cut -d ' ' -f 1
}

verify_trust() {
  local checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"

  local current_checksum=$(calculate_checksum)

  # No checksum file?
  if [[ ! -f "$checksum_file" ]]; then
    echo "Local sherpa enviroment file is not trusted. Run \`sherpa trust\` to mark it as trusted."
    return 1
  fi

  local stored_checksum=$(cat "$checksum_file")

  # Did the local env file change?
  if [[ "$current_checksum" != "$stored_checksum" ]]; then
    echo "The .local-sherpa file has changed. Run \`sherpa trust\` to mark it as trusted."
    return 1
  fi

  # The local env file is trusted
  return 0
}

trust_local_sherpa() {
  if [[ ! -f .local-sherpa ]]; then
    echo "Sherpa: .local-sherpa file not found in the current directory."
    echo "Sherpa: the local env config file is not found in the current directory."
    return 1
  fi

  mkdir -p "$SHERPA_CHECKSUM_DIR"

  local checksum_file="$SHERPA_CHECKSUM_DIR/$(pwd | md5sum | cut -d ' ' -f 1)"
  local current_checksum=$(calculate_checksum)

  echo "$current_checksum" > "$checksum_file"
  echo "Sherpa: the local env config file is now trusted."

  alert_sherpa

  return 0
}
