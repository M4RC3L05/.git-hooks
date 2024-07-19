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

run_and_print() {
  (
    set -x
    "$@"
  )
}
