#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=deno"
touch foo.js foo.jsx foo.ts foo.tsx foo.json foo.jsonc foo.md foo.markdown foo.txt foo.html foo.css

git add .

deno_mock="$(mock_binary "deno" "exit 1")"
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
+ deno fmt --check foo.js foo.json foo.jsonc foo.jsx foo.markdown foo.md foo.ts foo.tsx
EXIT_CODE:
1
"
is_same_calls_diff "$deno_mock" "---
ARGS:
fmt
--check
foo.js
foo.json
foo.jsonc
foo.jsx
foo.markdown
foo.md
foo.ts
foo.tsx
"
