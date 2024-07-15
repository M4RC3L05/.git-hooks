#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=sh"
touch foo.sh foo.txt

git add .

shfmt_mock="$(mock_binary_once "shfmt" 'printf "foo.sh\nfoo.sh\n"' "exit 1")"
shellcheck_mock="$(mock_binary "shellcheck" "exit 0")"

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running sh pre-commit
+ /usr/bin/env sh /app/hooks/sh/pre-commit
=> Check code format...
+ shfmt -d foo.sh foo.sh
EXIT_CODE:1
"
is_same_calls_diff "$shfmt_mock" "---
ARGS:-f foo.sh foo.txt
---
ARGS:-d foo.sh foo.sh
"
is_same_calls_diff "$shellcheck_mock" ""