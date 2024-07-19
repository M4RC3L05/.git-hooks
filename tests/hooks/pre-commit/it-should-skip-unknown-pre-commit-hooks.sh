#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS='foo deno bar'"
touch foo.txt

git add .

mock_binary "deno" "exit 0" >/dev/null

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:
commit
-m
foo
-q
OUTPUT:
Unknown foo pre-commit
Running deno pre-commit
+ /app/hooks/deno/pre-commit

Unknown bar pre-commit
EXIT_CODE:
0
"
