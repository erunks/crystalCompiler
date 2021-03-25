#!/bin/bash
PARENT_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
COMPILE_SCRIPT="./compile.sh"

cd "$PARENT_PATH"
. "$COMPILE_SCRIPT"
cd "../build"
cp "../src/language.txt" "./language.txt"
./main $1
