#!/usr/bin/env bash

set -o pipefail

SCRIPT_PATH="${BASH_SOURCE[0]:-${(%):-%x}}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

source "$SCRIPT_DIR/ruby.sh"

path1="$1"

path1_exists_pipe() {
	cat | if_tar_path "untar" | if_archive_path
}

if_exist() {
	read in
	if is_empty "$in"; then error "null pipe"; echo ""; return 1; fi

	local run="$1"

	local path="$in"

	if does_exist "$path"; then
		error "if_exist fulfilled"
		$run "$path"
		echo ""
		return 0
	fi
	
	error "if_exist unfulfilled"
	echo "$in"
}

if_dupa() {
	read in
	if is_empty "$in"; then error "null pipe"; echo ""; return 1; fi

	local run="$1"

	local path="$in"

	if are_the_same "$path" "dupa"; then
		error "if_dupa fulfilled"
		$run "$path"
		echo ""
		return 1
	fi

	error "if_dupa unfulfilled"
	echo "$in"
}

else_edit_file() {
	read in
	if is_empty "$in"; then error "null pipe"; echo ""; return 1; fi

	local path="$in"

	error "else_edit_file fulfilled"
}

echo "$path1" | if_exist "path1_exists_pipe" | if_archive_path "compress_pipe" | else_edit_file