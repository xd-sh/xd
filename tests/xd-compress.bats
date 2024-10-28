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

@test 'compressing single file to gz (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.gz

	    refute_output
	      assert_file "existing_file.txt"
	      assert_file "existing_file.txt.gz"
	assert_gz_contain "$RAND_VAL" "existing_file.txt.gz"
}

@test 'compressing single file to bz2 (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.bz2

	     refute_output
	       assert_file "existing_file.txt"
	       assert_file "existing_file.txt.bz2"
	assert_bz2_contain "$RAND_VAL" "existing_file.txt.bz2"
}

@test 'compressing single file to xz (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.xz

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.xz"
	assert_xz_contain "$RAND_VAL" "existing_file.txt.xz"
}

@test 'compressing single file to zst (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.zst

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.zst"
	assert_zst_contain "$RAND_VAL" "existing_file.txt.zst"
}

@test 'compressing single file to lzma (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.lzma

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.lzma"
	assert_lzma_contain "$RAND_VAL" "existing_file.txt.lzma"
}

@test 'compressing single file to zip (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.zip

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.zip"
	assert_zip_contain "$RAND_VAL" "existing_file.txt.zip"
}

@test 'compressing single file to 7z (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.7z

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.7z"
	assert_7z_contain "$RAND_VAL" "existing_file.txt.7z"
}

@test 'compressing single file to rar (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.rar

	refute_output
	assert_file "existing_file.txt"
	assert_file "existing_file.txt.rar"
	assert_rar_contain "$RAND_VAL" "existing_file.txt.rar"
}

@test 'compressing a dir to tar.gz (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.gz

	refute_output
	assert_dir "existing_dir"
	assert_file "existing_dir.tar.gz"
	assert_tar_contain "$RAND_VAL" "existing_dir.tar.gz"
}

@test 'compressing a dir to tar.bz2 (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.bz2

	refute_output
	assert_dir "existing_dir"
	assert_file "existing_dir.tar.bz2"
	assert_tar_contain "$RAND_VAL" "existing_dir.tar.bz2"
}

@test 'compressing a dir to tar.xz (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.xz

	refute_output
	assert_dir "existing_dir"
	assert_file "existing_dir.tar.xz"
	assert_tar_contain "$RAND_VAL" "existing_dir.tar.xz"
}

@test 'compressing a dir to tar.zst (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.zst

	refute_output
	assert_dir "existing_dir"
	assert_file "existing_dir.tar.zst"
	assert_tar_contain "$RAND_VAL" "existing_dir.tar.zst"
}

@test 'compressing a dir to tar.lzma (short version)' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.lzma

	refute_output
	assert_dir "existing_dir"
	assert_file "existing_dir.tar.lzma"
	assert_tar_contain "$RAND_VAL" "existing_dir.tar.lzma"
}

@test 'compressing single file to gz under given filename' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt new_file.txt.gz

	refute_output
	assert_file "existing_file.txt"
	assert_file "new_file.txt.gz"
	assert_gz_contain "$RAND_VAL" "new_file.txt.gz"
}

@test 'compressing single file to zip under given filename' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_file.txt new_file.txt.zip

	refute_output
	assert_file "existing_file.txt"
	assert_file "new_file.txt.zip"
	assert_zip_contain "$RAND_VAL" "new_file.txt.zip"
}

@test 'compressing a dir to tar.gz under given filename' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir new_archive.tar.gz

	refute_output
	assert_dir "existing_dir"
	assert_file "new_archive.tar.gz"
	assert_tar_contain "$RAND_VAL" "new_archive.tar.gz"
}

@test 'compressing a dir to zip under given filename' {
	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd existing_dir new_archive.zip

	refute_output
	assert_dir "existing_dir"
	assert_file "new_archive.zip"
	assert_zip_contain "$RAND_VAL" "new_archive.zip"
}