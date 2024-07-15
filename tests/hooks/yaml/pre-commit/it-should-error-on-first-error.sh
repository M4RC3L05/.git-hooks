#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=yaml"
touch foo.yaml foo.yml foo.txt

git add .

yamlfmt_mock="$(mock_binary "yamlfmt" "exit 1")"
yamllint_mock="$(mock_binary "yamllint" "exit 0")"

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running yaml pre-commit
+ /usr/bin/env sh /app/hooks/yaml/pre-commit
+ yamlfmt -dry -lint foo.yaml foo.yml
EXIT_CODE:1
"
is_same_calls_diff "$yamlfmt_mock" "---
ARGS:-dry -lint foo.yaml foo.yml
"
is_same_calls_diff "$yamllint_mock" ""
