
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