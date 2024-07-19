#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=deno"
touch foo.txt

git add .

deno_mock="$(mock_binary "deno" "exit 0")"
git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:
commit
-m
foo
-q
OUTPUT:
Running deno pre-commit
+ /app/hooks/deno/pre-commit
EXIT_CODE:
0
"
is_same_calls_diff "$deno_mock" ""
