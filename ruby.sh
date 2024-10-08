# Ruby.sh - Make Bash more Rubysh

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

trim_1_extention() {
  echo "${1%.*}"
}

trim_2_extentions() {
  echo "${1%.*.*}"
}

extension() {
  echo "${1##*.}"
}

root_dir() {
  echo "$(dirname "${BASH_SOURCE[0]}")"
}
