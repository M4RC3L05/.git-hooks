#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=sql,deno,sh"
touch foo.ts

git add .

mock_binary "deno" "exit 1" >/dev/null
mock_binary "sqlfluff" "exit 0" >/dev/null

git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running sql pre-commit
+ /usr/bin/env sh /app/hooks/sql/pre-commit

Running deno pre-commit
+ /usr/bin/env sh /app/hooks/deno/pre-commit
=> Check code format...
+ deno fmt --check foo.ts
EXIT_CODE:1
"
