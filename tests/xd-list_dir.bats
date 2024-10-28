#!./vendor/bats-core/bin/bats

DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
PATH="$DIR/..:$PATH"

PROJECT_ROOT="$(readlink --canonicalize-missing "$DIR/..")"

load "$PROJECT_ROOT/vendor/bats-support/load.bash"
load "$PROJECT_ROOT/vendor/bats-assert/load.bash"

source "$DIR/test_helpers.sh"

setup() {
	EXEC_ROOT="$(dirname "${BASH_SOURCE[0]}")"
	PLAYGROUND="$EXEC_ROOT/playground"
	RAND_VAL=$(shuf -i 10000000-99999999 -n 1)

	rm -rf "$PLAYGROUND"
	mkdir --parents "$PLAYGROUND/existing_dir"
	mkdir --parents "$PLAYGROUND/another_existing_dir"
	echo -e "This file does exist\n random value: $RAND_VAL\n" \
		> "$PLAYGROUND/existing_file.txt"

	echo -e "The file in the dir\n random value: $RAND_VAL\n" \
		> "$PLAYGROUND/existing_dir/existing_file.txt"

	echo -e "Another file in the dir\n const value: 123\n" \
		> "$PLAYGROUND/existing_dir/another_file.txt"

	cd "$PLAYGROUND"
}

teardown() {
	echo DEBUG_XD:
	echo ---
	cat "$DEBUG_XD"
	echo ---
}

@test 'listing working directory' {
	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"
	DEBUG_XD="$DEBUG_XD" run xd
	assert_line --partial 'existing_dir/'
	assert_line --partial 'existing_file.txt'
}