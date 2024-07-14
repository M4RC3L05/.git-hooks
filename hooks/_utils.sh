split() {
  # Disable globbing.
  # This ensures that the word-splitting is safe.
  set -f

  # Store the current value of 'IFS' so we
  # can restore it later.
  old_ifs=$IFS

  # Change the field separator to what we're
  # splitting on.
  IFS=$2

  # Create an argument list splitting at each
  # occurance of '$2'.
  #
  # This is safe to disable as it just warns against
  # word-splitting which is the behavior we expect.
  # shellcheck disable=2086
  set -- $1

  # Print each list value on its own line.
  printf '%s\n' "$@"

  # Restore the value of 'IFS'.
  IFS=$old_ifs

  # Re-enable globbing.
  set +f
}

ensure_command() {
  command -v "$1" >/dev/null || (
    echo "$1 is not installed"
    exit 1
  )
}

ensure_config() {
  if [ ! -f "$(git rev-parse --show-toplevel)"/.githooksrc ]; then
    echo ".githooksrc file not found in root of repo, create one and try again"
    exit 1
  fi
}

get_modified_files() {
  git diff --cached --name-only --diff-filter=ACMR "$@"
}

get_config_path() {
  printf "%s" "$(git rev-parse --show-toplevel)"/.githooksrc
}
