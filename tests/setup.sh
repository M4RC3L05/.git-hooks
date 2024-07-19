#!/usr/bin/env sh
# shellcheck disable=SC2059

gen_mock_fn() {
  printf "#/usr/bin/env sh

echo \"---\" >> $1
echo \"ARGS:\" >> $1

for arg in \"\$@\"; do
  echo \"\$arg\" >> $1
done

$2
"
}

gen_mock_once_fn() {
  printf "#/usr/bin/env sh

echo \"---\" >> $1
echo \"ARGS:\" >> $1

for arg in \"\$@\"; do
  echo \"\$arg\" >> $1
done

_counter=\"\$(cat $2)\"

if [ -z \"\$_counter\" ]; then
_counter=0
printf \"0\" > $2
fi

if [ \"\$_counter\" -eq 0 ]; then
$3
_counter=\$((_counter + 1))
printf \"\$_counter\" > $2
else
$4
fi
"
}

noop_binary() {
  touch /app/.bin/"$1"
  chmod +x /app/.bin/"$1"

  printf "/app/.bin/%s" "$1"
}

mock_binary() {
  _mock_binary_mock_path="$(noop_binary "$1")"
  _mock_binary_tmp_path="$(mktemp -t _mock_binary_tmp_path_"$1".XXXXXXXX)"

  gen_mock_fn "$_mock_binary_tmp_path" "$2" >"$_mock_binary_mock_path"

  printf "%s" "$_mock_binary_tmp_path"
}

mock_binary_once() {
  _mock_binary_once_mock_path="$(noop_binary "$1")"
  _mock_binary_once_counter_tmp_path="$(mktemp -t _mock_binary_once_counter_tmp_path_"$1".XXXXXXXX)"
  _mock_binary_once_tmp_path="$(mktemp -t _mock_binary_once_tmp_path_"$1".XXXXXXXX)"

  gen_mock_once_fn "$_mock_binary_once_tmp_path" "$_mock_binary_once_counter_tmp_path" "$2" "$3" >"$_mock_binary_once_mock_path"

  printf "%s" "$_mock_binary_once_tmp_path"
}

spy_binary() {
  _spy_binary_bin_path="$(which "$1")"
  _spy_binary_tmp_path="$(mktemp -t _spy_binary_tmp_path_"$1".XXXXXXXX)"
  _spy_binary_spy_bin_path="$(noop_binary "$1")"

  printf "#/usr/bin/env sh
echo \"---\" >> $_spy_binary_tmp_path
echo \"ARGS:\" >> $_spy_binary_tmp_path

for arg in \"\$@\"; do
  echo \"\$arg\" >> $_spy_binary_tmp_path
done

_output=\"\$($1 \$@ 2>&1)\"
_exit_code=\"\$?\"

echo \"OUTPUT:\" >> $_spy_binary_tmp_path
echo \"\$_output\" >> $_spy_binary_tmp_path
echo \"EXIT_CODE:\" >> $_spy_binary_tmp_path
echo \"\$_exit_code\" >> $_spy_binary_tmp_path
" >"$_spy_binary_spy_bin_path"

  printf "%s" "$_spy_binary_tmp_path"
}

init_githooksrc() {
  echo "$1" >"$(git rev-parse --show-toplevel)"/.githooksrc
}

is_same_calls_diff() {
  _is_same_calls_diff_tmp=$(mktemp)

  printf "%s" "$2" >"$_is_same_calls_diff_tmp"

  colordiff -u "$_is_same_calls_diff_tmp" "$1"
}
