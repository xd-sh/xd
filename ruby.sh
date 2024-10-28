# Ruby.sh - Make Bash more Rubysh

are_the_same() {
	[[ "$1" == "$2" ]]
}

are_equal() {
	[[ "$1" -eq "$2" ]]
}

is_empty() {
	[[ -z "$1" ]]
}

is_not_empty() {
	[[ -n "$1" ]]
}

exists() {
	[[ -e "$1" ]]
}

does_not_exist() {
	is_not_empty "$1" && ! exists "$1"
}

is_dir() {
	[[ -d "$1" ]]
}

is_not_dir() {
	! is_dir "$1"
}

ends_with_slash() {
	# does it ends with "/"
	[[ "$1" =~ .+\/$ ]]
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
	basename $( command -v "$1" || echo "$2" )
}

is_own() {
	[[ "$( stat -c "%u" "$1" )" -eq "$( id -u )" ]]
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

is_text() {
	local mime
	mime="$( file --mime-type --brief "$1" )"

	are_the_same "text/plain" "$mime"
}

is_not_text() {
	! is_text "$1"
}