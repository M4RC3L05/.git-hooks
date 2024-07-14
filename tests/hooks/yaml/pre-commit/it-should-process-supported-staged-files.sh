#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=yaml"
touch foo.yaml foo.yml foo.txt

git add .

yamlfmt_mock="$(mock_binary "yamlfmt" "exit 0")"
yamllint_mock="$(mock_binary "yamllint" "exit 0")"

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running yaml pre-commit
+ /usr/bin/env sh /app/hooks/yaml/pre-commit
=> Check code format...
+ yamlfmt -dry -lint foo.yaml foo.yml
=> Check code lint...
+ yamllint foo.yaml foo.yml
EXIT_CODE:01
"
is_same_calls_diff "$yamlfmt_mock" "---
ARGS:-dry -lint foo.yaml foo.yml
"
is_same_calls_diff "$yamllint_mock" "---
ARGS:foo.yaml foo.yml
"
