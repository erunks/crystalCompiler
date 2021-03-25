#!/bin/bash
[ ! -d "../build" ] && mkdir "../build"
crystal build "../src/main.cr" --error-trace --progress --release -o "../build/main"
