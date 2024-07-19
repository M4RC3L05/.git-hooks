#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=sql"
touch foo.sql foo.txt foo\ bar.sql

git add .

sqlfluff_mock="$(mock_binary "sqlfluff" "exit 0")"
git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:
commit
-m
foo
-q
OUTPUT:
Running sql pre-commit
+ /app/hooks/sql/pre-commit
+ sqlfluff lint foo bar.sql foo.sql
EXIT_CODE:
0
"
is_same_calls_diff "$sqlfluff_mock" "---
ARGS:
lint
foo bar.sql
foo.sql
"
