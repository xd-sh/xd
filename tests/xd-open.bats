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

@test 'edit a file with editor' {
	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"

	local editor='dbg editing'

	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt

	refute_output
	assert_regex "$(dbgout)" "editing existing_file.txt"
}

# @test 'open non text file' {
# 	DEBUG_XD=$(mktemp)
# 	source "$PROJECT_ROOT/xd.sh"

# 	DEBUG_XD="$DEBUG_XD" run xd existing_file.pdf

# 	refute_output
# }