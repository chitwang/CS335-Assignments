#!/bin/bash

if [ "$#" -eq 1 ]; then
    input_file="$1"
    flex prob2.l
    g++ lex.yy.c -o lexer -ll
    ./lexer < "$input_file"
else
    echo "Usage: $0 input_file"
fi
