
SCRIPT_PATH="${BASH_SOURCE[0]:-${(%):-%x}}"
SCRIPT_DIR="$( cd "$( dirname "$SCRIPT_PATH" )" && pwd )"
source "$SCRIPT_DIR/ruby.sh"

FINISH_PROCESS=0
TRY_NEXT=1

is_tar_path() {
  [[ "$1" == *.tar.* ]]
}

is_archive_path() {
  [[ "$1" =~ \.(gz|bz2|xz|zst|lzma|zip|7z|rar)$ ]]
}

is_not_archive_path() {
  ! is_archive_path "$1"
}

is_win_archive_path() {
	[[ "$1" =~ \.(zip|7z|rar)$ ]]
}

if is_not_empty "$DEBUG_XD"; then
	cd() {
		builtin cd "$@"
		dbg "cd $(pwd)"
	}
fi

tar_compressor() {
	case "$1" in
		gz   ) echo "$gzip";;
		bz2  ) echo "$bzip2";;
		xz   ) echo "xz";;
		zst  ) echo "zstd";;
		lzma ) echo "lzma";;
	esac
}

compress() {
	local source="$1"
	local target="${2:-$source}"
	local extension
	extension="$( extension "$target" )"

	if is_tar_path "$target"; then
		tar --use-compress-program="$( tar_compressor "$extension" )" \
		    --create \
		    --file "$target" \
		    "$source"
		return $?
	fi

	case "$extension" in
		gz   )  $gzip            --keep --stdout "$source" > "$target";;
		bz2  ) $bzip2 --compress --keep --stdout "$source" > "$target";;
		xz   )     xz --compress --keep --stdout "$source" > "$target";;
		lzma )   lzma --compress --keep --stdout "$source" > "$target";;
		zst  )   zstd --compress --keep -o "$target" "$source" 2> /dev/null;;
		zip  )    zip                   -r "$target" "$source"  > /dev/null;;
		7z   )     7z                    a "$target" "$source"  > /dev/null;;
		rar  )    rar                    a "$target" "$source"  > /dev/null;;
	esac
}

ensure_dir_and_print() {
	local dir="$1"
	local report="$2"

	is_empty "$dir" && return 0

	mkdir --parent "$dir"
	if is_not_empty "$report"; then
		printf "$report" "$dir"
	fi
}

decompress_tar() {
	local in_path="$path1"
	local extension
	extension=$( extension "$in_path" )
	local out_dir="$path2"
	local out_dir_param=''

	if exists "$out_dir"; then
		error "$out_dir does exists - wont override"
		exit 1
	fi

	if is_not_empty "$out_dir"; then
		mkdir --parents "$out_dir"
		out_dir_param="--directory $out_dir"
	fi

	tar --use-compress-program="$( tar_compressor "$extension" )" \
	    --extract \
	    --file "$in_path" \
	    "$out_dir_param"
}

decompress_win() {
	local in_path="$path1"
	local extension
	extension="$( extension "$in_path" )"
	local out_dir=''

	if is_empty "$path2"; then
		out_dir='.'
	elif does_not_exist "$path2" || is_dir "$path2"; then
		out_dir="$path2"
	elif exists "$path2"; then
		error "$path2 does exist - wont override"
		exit 1
	fi

	mkdir --parents "$out_dir"

	case "$extension" in
		 zip )           unzip "$in_path" -d "$out_dir" ;;
		 rar )         unrar x "$in_path" "$out_dir/"   ;;
		  7z ) 7z x -o"$out_dir" "$in_path"               ;;
	esac
}

decompress_file() {
	local in_path="$path1"
	local extension
	extension="$( extension "$in_path" )"
	local default_out_file
	default_out_file="$( trim_1_extention "$( basename "$in_path" )" )"
	local out_path

	if is_dir "$path2"; then
		out_path="$path2/$default_out_file"
	elif is_dir_path "$path2"; then
		out_path="$path2$default_out_file"
	elif is_empty "$path2"; then
		out_path="$( trim_1_extention "$in_path" )"
	else 
		out_path="$path2"
	fi

	if exists "$out_path"; then
		error "$out_path does exist - wont override"
		exit 1
	fi

	local out_dir
	out_dir="$( dirname "$out_path" )"
	mkdir --parents "$out_dir"

	case "$extension" in
		  gz )   $gzip --decompress --keep --stdout "$in_path" > "$out_path" ;;
		 bz2 )  $bzip2 --decompress --keep --stdout "$in_path" > "$out_path" ;;
		  xz )      xz --decompress --keep --stdout "$in_path" > "$out_path" ;;
		 zst )    zstd --decompress --keep --stdout "$in_path" > "$out_path" ;;
		lzma )    lzma --decompress --keep --stdout "$in_path" > "$out_path" ;;
	esac
}

try_decompress() {
	local source="$path1"
	local target="$path2"

	           is_empty "$source" && return $TRY_NEXT
	        is_not_file "$source" && return $TRY_NEXT
	is_not_archive_path "$source" && return $TRY_NEXT
	
	         exists "$target" \
	      && is_not_dir "$target" && return $TRY_NEXT
	
	if is_tar_path "$source"; then
		decompress_tar
		return $FINISH_PROCESS
	fi

	if is_win_archive_path "$source"; then
		decompress_win
		return $FINISH_PROCESS
	fi
	
	decompress_file
	return $FINISH_PROCESS
}

try_compress() {
	local source
	local target
	if is_tar_path "$path1"; then
		source="$( trim_2_extentions "$path1" )"
		target="$path1"
	elif is_archive_path "$path1"; then
		source="$( trim_1_extention "$path1" )"
		target="$path1"
	elif is_archive_path "$path2"; then
		source="$path1"
		target="$path2"
	else
		return $TRY_NEXT
	fi

	if does_not_exist "$source"; then return $TRY_NEXT; fi
	if exists "$target";         then return $TRY_NEXT; fi

	compress "$source" "$target"
	return $FINISH_PROCESS
}

try_copy() {
	local source="$path1"
	local target
	local target_dir
	
	if ends_with_slash "$path2"; then
		target="$path2/$(basename "$source")"	
	else
		target="$path2"
	fi

	if does_not_exist "$source"                 ; then return $TRY_NEXT; fi
	if is_empty "$target"                       ; then return $TRY_NEXT; fi
	if exists "$target" && is_not_dir "$target" ; then return $TRY_NEXT; fi

	target_dir="$(dirname "$target")"
	mkdir --parents "$target_dir"
	cp --archive "$source" "$target"

	return $FINISH_PROCESS
}

try_open() {
	local target="$path1"

	if is_not_file "$target"; then return $TRY_NEXT; fi

	if is_not_text "$target"; then
		xdg-open "$target"
		return $FINISH_PROCESS
	fi

	if is_own "$target"; then
		$editor "$target"
	else
		sudo $editor "$target"
	fi

	return $FINISH_PROCESS
}

try_setup_path() {
	local target="$path1"
	
	if is_empty "$target"                       ; then return $TRY_NEXT; fi
	if exists "$target" && is_not_dir "$target" ; then return $TRY_NEXT; fi

	mkdir --parents "$target"
	cd "$target"

	return $FINISH_PROCESS
}

list() {
	ls -lF --human-readable --all --group-directories-first
}

			    editor="${EDITOR:-vim}"
			      gzip="$( command_exists 'pigz' 'gzip' )"
			     bzip2="$( command_exists 'pbzip2' 'pbzip' )"
			XD_VERSION="$( cat "$SCRIPT_DIR/VERSION" )"

xd() {
	path1="$1"
	path2="$2"

	if [[ "$path1" == '-v' ]] || [[ "$path1" == "--version" ]]; then
		echo "XD version: $XD_VERSION"
		return 0
	fi

	try_decompress       \
		|| try_compress   \
		|| try_copy       \
		|| try_open       \
		|| try_setup_path \
		|| list
}

