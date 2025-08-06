#!/bin/bash

INPUT_FILE="apps.txt"

while IFS= read -r line; do
    echo "Processing app: $line"
    $1 "$line"
done < "$INPUT_FILE"