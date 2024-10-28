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

@test 'copy file under new name' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt initialy_absent_dir/new_file.txt

	refute_output
	  assert_file "existing_file.txt"
	   assert_dir "initialy_absent_dir"
	  assert_file "initialy_absent_dir/new_file.txt"
	 assert_equal "$(cat existing_file.txt)" "$(cat initialy_absent_dir/new_file.txt)"
}

@test 'copy file into a dir' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt another_existing_dir

	refute_output
	  assert_file "existing_file.txt"
	  assert_file "another_existing_dir/existing_file.txt"
	 assert_equal "$(cat existing_file.txt)" "$(cat another_existing_dir/existing_file.txt)"
}

@test 'copy file into a new dir' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt no_existant_dir/

	refute_output
	  assert_file "existing_file.txt"
	  assert_file "no_existant_dir/existing_file.txt"
	 assert_equal "$(cat existing_file.txt)" "$(cat no_existant_dir/existing_file.txt)"
}

@test 'copy dir under new name' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir initialy_absent_dir/new_dir

	assert_dir "existing_dir"
	assert_dir "initialy_absent_dir/new_dir"
	assert_equal "$(ls existing_dir)" "$(ls initialy_absent_dir/new_dir)"
}

@test 'copy dir into a dir' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir another_existing_dir

	assert_dir "existing_dir"
	assert_dir "another_existing_dir/existing_dir"
	assert_equal "$(ls existing_dir)" "$(ls another_existing_dir/existing_dir)"
}