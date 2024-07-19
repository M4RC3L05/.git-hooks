#!/usr/bin/env sh

set -e

# shellcheck disable=SC1091
. "$TESTS_DIR"/setup.sh

init_githooksrc "HOOKS=deno"
touch foo.js foo.jsx foo.ts foo.tsx foo.json foo.jsonc foo.md foo.markdown foo.txt foo.css foo.html

git add .

deno_mock="$(mock_binary "deno" "exit 0")"
git_spy="$(spy_binary "git")"

/app/.bin/git commit -m "foo" -q

is_same_calls_diff "$git_spy" "---
ARGS:commit -m foo -q
OUTPUT:Running deno pre-commit
+ /usr/bin/env sh /app/hooks/deno/pre-commit
+ deno fmt --check --use-tabs=false --line-width=80 --indent-width=2 --single-quote=false --no-semicolons=false foo.js foo.json foo.jsonc foo.jsx foo.markdown foo.md foo.ts foo.tsx
+ deno run -A --no-lock npm:prettier -c --end-of-line=lf --html-whitespace-sensitivity=css --print-width=80 --prose-wrap=preserve --no-semi=false --single-quote=false --tab-width=2 --trailing-comma=all --use-tabs=false foo.html foo.css
+ deno lint --rules-tags=recommended --rules-include=no-console,no-throw-literal,verbatim-module-syntax,no-undef foo.js foo.jsx foo.ts foo.tsx
+ deno run -A --no-lock npm:html-validate foo.html
EXIT_CODE:0
"
is_same_calls_diff "$deno_mock" "---
ARGS:fmt --check --use-tabs=false --line-width=80 --indent-width=2 --single-quote=false --no-semicolons=false foo.js foo.json foo.jsonc foo.jsx foo.markdown foo.md foo.ts foo.tsx
---
ARGS:run -A --no-lock npm:prettier -c --end-of-line=lf --html-whitespace-sensitivity=css --print-width=80 --prose-wrap=preserve --no-semi=false --single-quote=false --tab-width=2 --trailing-comma=all --use-tabs=false foo.html foo.css
---
ARGS:lint --rules-tags=recommended --rules-include=no-console,no-throw-literal,verbatim-module-syntax,no-undef foo.js foo.jsx foo.ts foo.tsx
---
ARGS:run -A --no-lock npm:html-validate foo.html
"
