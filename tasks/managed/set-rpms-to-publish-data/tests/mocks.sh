#!/usr/bin/env bash
set -ex

# Mock functions for set-rpms-to-publish-data tests.
# These mocks are injected into the task step script by pre-apply-task-hook.sh.

CONTENT_EXISTS_MODE_FILE="/tmp/mock_content_exists_mode"

function select-oci-auth() {
  echo "Mock select-oci-auth called with: $*"
  # The real helper writes registry credentials to $AUTHFILE; tests don't require it.
  : > "${AUTHFILE}"
}

function oras() {
  echo "Mock oras called with: $*"
  echo $* >> $(params.dataDir)/mock_oras.txt
  local args="$*"

  if [[ "$*" == "pull --registry-config"* ]]; then
    output_file_dir=""
    echo "none" > "${CONTENT_EXISTS_MODE_FILE}"
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -o|--output)
          output_file_dir="$2"
          shift 2
          ;;
        *)
          shift
          ;;
      esac
    done

    if [[ "$args" == *"quay.io/test/alreadyexists"* ]]; then
      echo "all" > "${CONTENT_EXISTS_MODE_FILE}"
    elif [[ "$args" == *"quay.io/test/digestmismatch"* ]]; then
      echo "all" > "${CONTENT_EXISTS_MODE_FILE}"
      printf '%s\n' "not-empty" > "${output_file_dir}/hello-2.12.1-6.fc44.x86_64.rpm"
      mkdir -p "${output_file_dir}/logs"
      touch "${output_file_dir}/logs/hello-2.12.1-6.fc44.x86_64.rpm.log"
      return 0
    fi

    # Default: create empty RPM files
    mkdir -p "${output_file_dir}"
    touch "${output_file_dir}/hello-2.12.1-6.fc44.aarch64.rpm"
    touch "${output_file_dir}/hello-2.12.1-6.fc44.ppc64le.rpm"
    touch "${output_file_dir}/hello-2.12.1-6.fc44.s390x.rpm"
    touch "${output_file_dir}/hello-2.12.1-6.fc44.src.rpm"
    touch "${output_file_dir}/hello-2.12.1-6.fc44.x86_64.rpm"
    touch "${output_file_dir}/hello-docs-2.12.1-6.fc44.noarch.rpm"
    mkdir -p "${output_file_dir}/logs"
    touch "${output_file_dir}/logs/hello-2.12.1-6.fc44.x86_64.rpm.log"
    return 0
  fi
}

# The unit tests create dummy RPM files (empty placeholders). The production task
# parses NEVRA from the RPM header via `rpm -qp`, so we mock that behavior here.
function rpm() {
  # Only mock RPM header queries used by parse_nevra() (`rpm -qp --qf ... <file>`).
  if [[ "${1-}" == "-qp" ]]; then
    local file_path=""
    local filename base nvra namever version_with_epoch name epoch version release arch

    # Extract the RPM path from args (ignore query flags/format).
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -qp)
          shift
          ;;
        --qf)
          shift 2
          ;;
        *)
          file_path="$1"
          shift
          ;;
      esac
    done

    if [[ -z "${file_path}" ]]; then
      echo "mock rpm: missing rpm file path" >&2
      return 1
    fi

    filename="$(basename "${file_path}")"
    base="${filename%.rpm}"
    arch="${base##*.}"
    nvra="${base%.*}"
    release="${nvra##*-}"
    namever="${nvra%-*}"
    version_with_epoch="${namever##*-}"
    name="${namever%-*}"
    epoch="0"
    if [[ "${version_with_epoch}" == *:* ]]; then
      epoch="${version_with_epoch%%:*}"
      version="${version_with_epoch#*:}"
    else
      version="${version_with_epoch}"
    fi

    printf '%s|%s|%s|%s|%s\n' "${name}" "${epoch}" "${version}" "${release}" "${arch}"
    return 0
  fi

  command rpm "$@"
}
