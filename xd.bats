#!./vendor/bats-core/bin/bats

load 'vendor/bats-support/load.bash'
load 'vendor/bats-assert/load.bash'

PROJECT_ROOT="$(pwd)"

# source $PROJECT_ROOT/xd.sh

setup() {
    EXEC_ROOT="$(dirname "${BASH_SOURCE[0]}")"
    PLAYGROUND="$EXEC_ROOT/playground"
    RAND_VAL=$(shuf -i 10000000-99999999 -n 1)

    rm -rf $PLAYGROUND
    mkdir --parents $PLAYGROUND/existing_dir
    echo -e "This file does exist\n random value: $RAND_VAL\n" \
        > "$PLAYGROUND/existing_file.txt"

    echo -e "The file in the dir\n random value: $RAND_VAL\n" \
        > "$PLAYGROUND/existing_dir/existing_file.txt"

    echo -e "Another file in the dir\n const value: 123\n" \
        > "$PLAYGROUND/existing_dir/another_file.txt"

    cd $PLAYGROUND

    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
}

dbgout() {
    cat $DEBUG_XD
}

assert_file() {
    if is_file "$1"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$1' to be a file" \
        'actual' "$(file "$1")" \
        | batslib_decorate 'it is not a file' \
        | fail
}

assert_dir() {
    if is_dir "$1"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$1' to be a file" \
        'actual' "$(file "$1")" \
        | batslib_decorate 'it is not a file' \
        | fail
}

assert_gz_contain() {
    if zgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_bz2_contain() {
    if bzgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_xz_contain() {
    if xzgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_zst_contain() {
    if zstdgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_lzma_contain() {
    if lzgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_zip_contain() {
    if zipgrep "$1" "$2"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_7z_contain() {
    if 7z x -so "$2" | grep "$1"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_rar_contain() {
    if unrar p "$2" | grep "$1"; then return 0; fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

assert_tar_contain() {
    local extension=$(extension "$2")

    if tar --extract \
           --to-stdout \
           --use-compress-program=$(tar_compressor $extension) \
           --file "$2" | grep "$1"
    then 
        return 0
    fi
    
    batslib_print_kv_single_or_multi 8 \
        'expected' "'$2' to contain '$1'" \
        | batslib_decorate 'it did not contain it' \
        | fail
}

@test 'changing working directory' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh

    DEBUG_XD="$DEBUG_XD" run xd existing_dir
    
    assert_regex "$(dbgout)" "cd $PLAYGROUND/existing_dir"
}

@test 'listing working directory' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd
    assert_line --partial 'existing_dir'
    assert_line --partial 'existing_file.txt'
}

@test 'compressing single file to gz (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.gz

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.gz"
    assert_gz_contain "$RAND_VAL" "existing_file.txt.gz"
}

@test 'compressing single file to bz2 (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.bz2

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.bz2"
    assert_bz2_contain "$RAND_VAL" "existing_file.txt.bz2"
}

@test 'compressing single file to xz (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.xz

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.xz"
    assert_xz_contain "$RAND_VAL" "existing_file.txt.xz"
}

@test 'compressing single file to zst (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.zst

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.zst"
    assert_zst_contain "$RAND_VAL" "existing_file.txt.zst"
}

@test 'compressing single file to lzma (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.lzma

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.lzma"
    assert_lzma_contain "$RAND_VAL" "existing_file.txt.lzma"
}

@test 'compressing single file to zip (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.zip

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.zip"
    assert_zip_contain "$RAND_VAL" "existing_file.txt.zip"
}

@test 'compressing single file to 7z (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.7z

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.7z"
    assert_7z_contain "$RAND_VAL" "existing_file.txt.7z"
}

@test 'compressing single file to rar (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt.rar

    assert_file "existing_file.txt"
    assert_file "existing_file.txt.rar"
    assert_rar_contain "$RAND_VAL" "existing_file.txt.rar"
}

@test 'compressing a dir to tar.gz (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.gz

    assert_dir "existing_dir"
    assert_file "existing_dir.tar.gz"
    assert_tar_contain "$RAND_VAL" "existing_dir.tar.gz"
}

@test 'compressing a dir to tar.bz2 (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.bz2

    assert_dir "existing_dir"
    assert_file "existing_dir.tar.bz2"
    assert_tar_contain "$RAND_VAL" "existing_dir.tar.bz2"
}

@test 'compressing a dir to tar.xz (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.xz

    assert_dir "existing_dir"
    assert_file "existing_dir.tar.xz"
    assert_tar_contain "$RAND_VAL" "existing_dir.tar.xz"
}

@test 'compressing a dir to tar.zst (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.zst

    assert_dir "existing_dir"
    assert_file "existing_dir.tar.zst"
    assert_tar_contain "$RAND_VAL" "existing_dir.tar.zst"
}

@test 'compressing a dir to tar.lzma (short version)' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir.tar.lzma

    assert_dir "existing_dir"
    assert_file "existing_dir.tar.lzma"
    assert_tar_contain "$RAND_VAL" "existing_dir.tar.lzma"
}

@test 'making dir chain and changing working dir to it' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd "new_dir/internal_dir"

    assert_dir "$PLAYGROUND/new_dir/internal_dir"
    assert_regex "$(dbgout)" "cd $PLAYGROUND/new_dir/internal_dir"
}

@test 'compressing single file to gz under given filename' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt new_file.txt.gz

    assert_file "existing_file.txt"
    assert_file "new_file.txt.gz"
    assert_gz_contain "$RAND_VAL" "new_file.txt.gz"
}

@test 'compressing single file to zip under given filename' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt new_file.txt.zip

    assert_file "existing_file.txt"
    assert_file "new_file.txt.zip"
    assert_zip_contain "$RAND_VAL" "new_file.txt.zip"
}

@test 'compressing a dir to tar.gz under given filename' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir new_archive.tar.gz

    assert_dir "existing_dir"
    assert_file "new_archive.tar.gz"
    assert_tar_contain "$RAND_VAL" "new_archive.tar.gz"
}

@test 'compressing a dir to zip under given filename' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir new_archive.zip

    assert_dir "existing_dir"
    assert_file "new_archive.zip"
    assert_zip_contain "$RAND_VAL" "new_archive.zip"
}

@test 'copy file' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt new_file.txt

    assert_file "existing_file.txt"
    assert_file "new_file.txt"
    assert_equal "$(cat existing_file.txt)" "$(cat new_file.txt)"
}

@test 'copy dir' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd existing_dir new_dir

    assert_dir "existing_dir"
    assert_dir "new_dir"
    assert_equal "$(ls existing_dir)" "$(ls new_dir)"
}

@test 'decompres a gz file' {
    echo "This file is compressed with gz" \
        | gzip --stdout \
        > $PLAYGROUND/compressed_file.txt.gz
    
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd compressed_file.txt.gz

    assert_file "compressed_file.txt.gz"
    assert_file "compressed_file.txt"
    assert_equal "This file is compressed with gz" \
                 "$(cat compressed_file.txt)"
}

@test 'decompres a bz2 file' {
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

@test 'decompres a xz file' {
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

@test 'decompres a zst file' {
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

@test 'decompres a lzma file' {
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

@test 'decompres a zip file' {
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

@test 'decompres a 7z file' {
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

@test 'decompres a rar file' {
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

@test 'decompres a tar.gz archive into a new dir' {
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

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with tar.gz" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a tar.bz2 archive into a new dir' {
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
    DEBUG_XD="$DEBUG_XD" run xd compressed_dir.tar.bz2

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with tar.bz2" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a tar.xz archive into a new dir' {
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

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with tar.xz" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a tar.zst archive into a new dir' {
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

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with tar.zst" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a tar.lzma archive into a new dir' {
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

@test 'decompres a zip archive into a new dir' {
    local to_be_compressed=compressed_dir
    mkdir "$to_be_compressed"
    echo "This file is compressed with zip" > "$to_be_compressed/file1.txt"
    echo "This file is also compressed with zip" > "$to_be_compressed/file2.txt"
    zip -r "${to_be_compressed}.zip" "$to_be_compressed"
    rm -fr "$to_be_compressed"

    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd compressed_dir.zip

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with zip" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a 7z archive into a new dir' {
    local to_be_compressed=compressed_dir
    mkdir "$to_be_compressed"
    echo "This file is compressed with 7z" > "$to_be_compressed/file1.txt"
    echo "This file is also compressed with 7z" > "$to_be_compressed/file2.txt"
    7z a "${to_be_compressed}.7z" "$to_be_compressed" > /dev/null
    rm -fr "$to_be_compressed"
    pwd
    ls -lh

    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd compressed_dir.7z

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with 7z" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'decompres a rar archive into a new dir' {
    local to_be_compressed=compressed_dir
    mkdir "$to_be_compressed"
    echo "This file is compressed with rar" > "$to_be_compressed/file1.txt"
    echo "This file is also compressed with rar" > "$to_be_compressed/file2.txt"
    rar a "${to_be_compressed}.rar" "$to_be_compressed" > /dev/null
    rm -fr "$to_be_compressed"
    pwd
    ls -lh

    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd compressed_dir.rar

    cat $DEBUG_XD

    assert_dir "$to_be_compressed"
    assert_file "$to_be_compressed/file1.txt"
    assert_file "$to_be_compressed/file2.txt"
    assert_equal "This file is compressed with rar" \
                 "$(cat "$to_be_compressed/file1.txt")"
}

@test 'edit a file with editor' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh

    local editor='dbg editing'

    DEBUG_XD="$DEBUG_XD" run xd existing_file.txt

    assert_regex "$(dbgout)" "editing existing_file.txt"
}

# @test 'encode a file' {

# }

# @test 'decode a file' {

# }

@test 'print version on -v parameter' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd -v

    assert_output 'XD version: 1.0.0'
}

@test 'print version on --version parameter' {
    DEBUG_XD=$(mktemp)
    source $PROJECT_ROOT/xd.sh
    DEBUG_XD="$DEBUG_XD" run xd --version

    assert_output 'XD version: 1.0.0'
}