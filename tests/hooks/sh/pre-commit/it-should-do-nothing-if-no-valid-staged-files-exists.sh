#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=sh"
touch foo.txt .shellcheckrc

git add .

shfmt_mock="$(mock_binary "shfmt" "exit 0")"
shellcheck_mock="$(mock_binary "shellcheck" "exit 0")"

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running sh pre-commit
+ /usr/bin/env sh /app/hooks/sh/pre-commit
EXIT_CODE:0
"
is_same_calls_diff "$shfmt_mock" "---
ARGS:-f foo.txt
"
is_same_calls_diff "$shellcheck_mock" ""
