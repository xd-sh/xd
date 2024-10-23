#!/usr/bin/env bash

SCRIPT_PATH="${BASH_SOURCE[0]:-${(%):-%x}}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

source "$SCRIPT_DIR/ruby.sh"

set -o pipefail

fun1() {
    cat
}

fun2() {
    # Przykładowy warunek, który kończy działanie potoku
    if true; then
        echo "Błąd: Nie można przetworzyć 'dupa'" >&2
        return 1  # Zwraca niezerowy kod wyjścia, co przerywa potok
    fi
    cat
}

fun3() {
    echo "fun3 wykonane"
}

echo "dupa" | fun1 | fun2 | fun3