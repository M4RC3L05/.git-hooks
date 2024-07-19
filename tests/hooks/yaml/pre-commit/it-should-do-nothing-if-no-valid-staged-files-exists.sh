#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=yaml"
touch foo.txt .shellcheckrc

git add .

yamlfmt_mock="$(mock_binary "yamlfmt" "exit 0")"
yamllint_mock="$(mock_binary "yamllint" "exit 0")"

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:
commit
-m
foo
-q
OUTPUT:
Running yaml pre-commit
+ /app/hooks/yaml/pre-commit
EXIT_CODE:
0
"
is_same_calls_diff "$yamlfmt_mock" ""
is_same_calls_diff "$yamllint_mock" ""
