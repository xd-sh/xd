
# verbailzer
is_empty() {
  [[ -z "$1" ]]
}

is_not_empty() {
  [[ -n "$1" ]]
}

does_exist() {
  [[ -e "$1" ]]
}

does_not_exist() {
  is_not_empty "$1" && ! does_exist "$1"
}

is_dir() {
  [[ -d "$1" ]]
}

is_file() {
  [[ -f "$1" ]]
}

is_not_file() {
  ! is_file "$1"
}

is_not_ok() {
  [[ $? -ne 0 ]]
}

command_exists() {
  basename $(command -v "$1" || echo "$2")
}

is_tar_path() {
  [[ "$1" == *.tar.* ]]
}

is_compressed() {
  [[ "$1" =~ \.(gz|bz2|xz|zst|lzma|zip|7z|rar)$ ]]
}

is_own() {
  [[ "$(stat -c "%u" "$1")" -eq "$(id -u)" ]]
}

dbg() {
  is_empty "$DEBUG_XD" && return 0

  echo "$@" >> "$DEBUG_XD"
}

error() {
  dbg "$@"
  echo "$@" >&2
}

tar_compressor() {
  case "$1" in
    gz)   echo $gzip_compressor;;
    bz2)  echo $bzip2_compressor;;
    xz)   echo "xz";;
    zst)  echo "zstd";;
    lzma) echo "lzma";;
  esac
}

trim_1_extention() {
  echo "${1%.*}"
}

trim_2_extentions() {
  echo "${1%.*.*}"
}

extension() {
  echo "${1##*.}"
}

compress() {
  local extension=$(extension "$2")

  if is_tar_path "$2"; then
    tar --use-compress-program=$(tar_compressor $extension) \
        --create \
        --file "$2" \
        "$1"
    return $?
  fi

  case "$extension" in
    gz)   $gzip_compressor --keep --stdout "$1" > "$2";;
    bz2)  $bzip2_compressor --compress --keep --stdout "$1" > "$2";;
    xz)   xz --compress --keep --stdout "$1" > "$2";;
    zst)  zstd --compress --keep -o "$2" "$1" 2> /dev/null;;
    lzma) lzma --compress --keep --stdout "$1" > "$2";;
    zip)  zip -r "$2" "$1" > /dev/null;;
    7z)   7z a "$2" "$1" > /dev/null;;
    rar)  rar a "$2" "$1" > /dev/null;;
  esac
}

ensure_dir_and_raport() {
  local dir="$1"
  local report="$2"
  if is_not_empty "$dir"; then
    mkdir --parent "$dir"
    if is_not_empty "$report"; then
      printf "$report" "$dir"
    fi
  fi
}

decompress() {
  local in_file="$1"
  local extension=$(extension "$in_file")

  if is_tar_path "$in_file"; then
    local out_dir="${2:-$(trim_2_extentions "$in_file")}"

    tar --use-compress-program=$(tar_compressor $extension) \
        --extract \
        --file "$in_file" \
        $(ensure_dir_and_raport "$out_dir" "--directory %s")
    return $?
  fi

  local out_file="${2:-$(trim_1_extention "$in_file")}"

  case "$extension" in
    gz)   $gzip_compressor --decompress --keep --stdout "$in_file" > "$out_file";;
    bz2)  $bzip2_compressor --decompress --keep --stdout "$in_file" > "$out_file";;
    xz)   xz --decompress --keep --stdout "$in_file" > "$out_file";;
    zst)  zstd --decompress --keep --stdout "$in_file" > "$out_file";;
    lzma) lzma --decompress --keep --stdout "$in_file" > "$out_file";;
    zip)  unzip "$in_file";;
    7z)   7z x "$in_file";;
    rar)  unrar x "$in_file";;
  esac
}

if is_not_empty "$DEBUG_XD"; then
  cd() {
    builtin cd "$@"
    dbg "cd $(pwd)"
  }
fi

editor=${EDITOR:-vim}
gzip_compressor=$( command_exists 'pigz' 'gzip' )
bzip2_compressor=$( command_exists 'pbzip2' 'pbzip' )
root_dir="$(dirname "${BASH_SOURCE[0]}")"

xd() {
  local XD_VERSION=$(cat $root_dir/VERSION)
  local path1="$1"
  local path2="$2"

  if [[ "$path1" == '-v' ]] || [[ "$path1" == "--version" ]]; then
    echo "XD version: $XD_VERSION"
    return 0
  fi

  if is_empty "$path1"; then
    ls -lF --human-readable --all --group-directories-first
    return $?
  fi

  if does_not_exist "$path1"; then
    if is_compressed "$path1"; then
      local file1=$(trim_1_extention "$path1")
      if does_exist "$file1"; then
        compress "$file1" "$path1"
        return $?
      fi

      local file1=$(trim_2_extentions "$path1")
      if does_exist "$file1"; then
        compress "$file1" "$path1"
        return $?
      fi
    fi

    mkdir --parents "$path1"
    if is_not_ok; then error "dupa..."; return 1; fi
    cd "$path1"
    return $?
  fi

  if does_not_exist "$path2"; then
    if is_compressed "$path2"; then
      compress "$path1" "$path2"
      return $?
    fi

    cp --archive "$path1" "$path2"
    return $?
  fi

  if is_dir "$path1"; then
    cd "$path1"
    return $?
  fi

  if is_file "$path1"; then
    if is_compressed "$path1"; then
      decompress "$1"
      return $?
    fi

    if is_own "$path1"; then
      $editor "$path1"
    else
      sudo $editor "$path1"
    fi
    return $?
  fi

  error "NOT IMPLEMENTED YET..."
  return 1
}
