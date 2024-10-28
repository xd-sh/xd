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

@test 'decompress a gz file in place' {
	echo "This file is compressed with gz" \
		| gzip --stdout \
		> $PLAYGROUND/compressed_file.txt.gz

	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.gz

	assert_file "compressed_file.txt.gz"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with gz" \
				 "$(cat compressed_file.txt)"
}

@test 'decompress a gz file into an existing dir' {
	echo "This file is compressed with gz" \
		| gzip --stdout \
		> $PLAYGROUND/compressed_file.txt.gz

	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.gz existing_dir

	assert_file "compressed_file.txt.gz"
	assert_file "existing_dir/compressed_file.txt"
	assert_equal "This file is compressed with gz" \
				 "$(cat existing_dir/compressed_file.txt)"
}

@test 'decompress a gz file into an non existing dir' {
	echo "This file is compressed with gz" \
		| gzip --stdout \
		> $PLAYGROUND/compressed_file.txt.gz

	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.gz "non_existing_dir/"
	echo DEBUG_XD: $DEBUG_XD

	assert_file "compressed_file.txt.gz"
	assert_dir "non_existing_dir"
	assert_file "non_existing_dir/compressed_file.txt"
	assert_equal "This file is compressed with gz" \
	             "$(cat non_existing_dir/compressed_file.txt)"
}

@test 'decompress a gz file under different name' {
	echo "This file is compressed with gz" \
		| gzip --stdout \
		> $PLAYGROUND/compressed_file.txt.gz

	DEBUG_XD=$(mktemp)
	source "$PROJECT_ROOT/xd.sh"
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.gz "non_existing_dir/new_file.txt"
	echo DEBUG_XD: $DEBUG_XD

	assert_file "compressed_file.txt.gz"
	assert_dir "non_existing_dir"
	assert_file "non_existing_dir/new_file.txt"
	assert_equal "This file is compressed with gz" \
	             "$(cat non_existing_dir/new_file.txt)"
}

@test 'decompress a bz2 file' {
	echo "This file is compressed with bz2" \
		| bzip2 --stdout \
		> $PLAYGROUND/compressed_file.txt.bz2

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.bz2

	assert_file "compressed_file.txt.bz2"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with bz2" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a xz file' {
	echo "This file is compressed with xz" \
		| xz --stdout \
		> $PLAYGROUND/compressed_file.txt.xz

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.xz

	assert_file "compressed_file.txt.xz"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with xz" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a zst file' {
	echo "This file is compressed with zst" \
		| zstd --stdout \
		> $PLAYGROUND/compressed_file.txt.zst

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.zst

	assert_file "compressed_file.txt.zst"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with zst" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a lzma file' {
	echo "This file is compressed with lzma" \
		| lzma --stdout \
		> $PLAYGROUND/compressed_file.txt.lzma

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.lzma

	assert_file "compressed_file.txt.lzma"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with lzma" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a zip file' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with zip" > "$to_be_compressed"
	zip -r "compressed_file.zip" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.zip

	assert_file "compressed_file.zip"
	assert_file "compressed_file.txt"
	assert_equal "This file is compressed with zip" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a zip file into an existing dir' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with zip" > "$to_be_compressed"
	zip -r "compressed_file.zip" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.zip existing_dir

	assert_file "compressed_file.zip"
	assert_file "existing_dir/compressed_file.txt"
	assert_equal "This file is compressed with zip" \
	             "$(cat existing_dir/compressed_file.txt)"
}

@test 'decompress a 7z file' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with 7z" > "$to_be_compressed"
	7z a "compressed_file.7z" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.7z

	 assert_file "compressed_file.7z"
	 assert_file "compressed_file.txt"
	assert_equal "This file is compressed with 7z" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a 7z file into an non existing dir' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with 7z" > "$to_be_compressed"
	7z a "compressed_file.7z" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.7z not_present_dir

	 assert_file "compressed_file.7z"
	 assert_file "not_present_dir/compressed_file.txt"
	assert_equal "This file is compressed with 7z" \
	             "$(cat not_present_dir/compressed_file.txt)"
}

@test 'decompress a rar file' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with rar" > "$to_be_compressed"
	rar a "compressed_file.rar" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.rar

	 assert_file "compressed_file.rar"
	 assert_file "compressed_file.txt"
	assert_equal "This file is compressed with rar" \
	             "$(cat compressed_file.txt)"
}

@test 'decompress a rar file into a dir' {
	local to_be_compressed=compressed_file.txt
	echo "This file is compressed with rar" > "$to_be_compressed"
	rar a "compressed_file.rar" "$to_be_compressed"
	rm "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_file.rar existing_dir

	 assert_file "compressed_file.rar"
	 assert_file "existing_dir/compressed_file.txt"
	assert_equal "This file is compressed with rar" \
	             "$(cat existing_dir/compressed_file.txt)"
}

@test 'decompress a tar.gz archive' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with tar.gz" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with tar.gz" > "$to_be_compressed/file2.txt"
	tar --create \
	    --use-compress-program=gzip \
	    --file "${to_be_compressed}.tar.gz" \
	    "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.tar.gz

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with tar.gz" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a tar.bz2 archive into a new dir' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with tar.bz2" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with tar.bz2" > "$to_be_compressed/file2.txt"
	tar --create \
	    --use-compress-program=bzip2 \
	    --file "${to_be_compressed}.tar.bz2" \
	    "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd "${to_be_compressed}.tar.bz2" brand_new_dir

	      refute_output
	  assert_dir "brand_new_dir"
	  assert_dir "brand_new_dir/$to_be_compressed"
	 assert_file "brand_new_dir/$to_be_compressed/file1.txt"
	 assert_file "brand_new_dir/$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with tar.bz2" \
	             "$(cat "brand_new_dir/$to_be_compressed/file1.txt")"
}

@test 'decompress a tar.xz archive' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with tar.xz" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with tar.xz" > "$to_be_compressed/file2.txt"
	tar --create \
	    --use-compress-program=xz \
	    --file "${to_be_compressed}.tar.xz" \
	    "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.tar.xz

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with tar.xz" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a tar.zst archive' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with tar.zst" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with tar.zst" > "$to_be_compressed/file2.txt"
	tar --create \
	    --use-compress-program=zstd \
	    --file "${to_be_compressed}.tar.zst" \
	    "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.tar.zst

  	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with tar.zst" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a tar.lzma archive into a new dir' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with tar.lzma" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with tar.lzma" > "$to_be_compressed/file2.txt"
	tar --create \
	    --use-compress-program=lzma \
	    --file "${to_be_compressed}.tar.lzma" \
	    "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.tar.lzma

	cat $DEBUG_XD

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with tar.lzma" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a zip archive with dir' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with zip" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with zip" > "$to_be_compressed/file2.txt"
	zip -r "${to_be_compressed}.zip" "$to_be_compressed"
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.zip

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with zip" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a 7z archive into a new dir' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with 7z" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with 7z" > "$to_be_compressed/file2.txt"
	7z a "${to_be_compressed}.7z" "$to_be_compressed" > /dev/null
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.7z

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with 7z" \
	             "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompress a rar archive into a new dir' {
	local to_be_compressed=compressed_dir
	mkdir "$to_be_compressed"
	echo "This file is compressed with rar" > "$to_be_compressed/file1.txt"
	echo "This file is also compressed with rar" > "$to_be_compressed/file2.txt"
	rar a "${to_be_compressed}.rar" "$to_be_compressed" > /dev/null
	rm -fr "$to_be_compressed"

	DEBUG_XD=$(mktemp)
	source $PROJECT_ROOT/xd.sh
	DEBUG_XD="$DEBUG_XD" run xd compressed_dir.rar

	  assert_dir "$to_be_compressed"
	 assert_file "$to_be_compressed/file1.txt"
	 assert_file "$to_be_compressed/file2.txt"
	assert_equal "This file is compressed with rar" \
	             "$(cat "$to_be_compressed/file1.txt")"
}