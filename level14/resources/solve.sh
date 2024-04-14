#!/bin/bash

# Check if exactly one input argument is given
if [ $# -ne 1 ]; then
  echo "Usage: $0 <input>"
  exit 1
fi

# Validate the input: it must be a non-negative number less than 15
if [ $1 -lt 0 ] || [ $1 -ge 15 ]; then
  echo "Error: Input must be a non-negative number less than 15."
  exit 1
fi

# Calculate the level based on the input
input=$1
level=$((input * 36 + 685))

# Adjustments for specific inputs
if [ $input -eq 13 ]; then
  level=$((level - 3))
elif [ $input -eq 14 ]; then
  level=$((level - 6))
fi

# GDB commands to execute
commands="b main
r
jump *main+$level
continue
"

# Execute the commands in GDB, directing GDB's stdin from the here-document
gdb -ex "set pagination off" -q getflag << EOF | awk '/\(gdb\) Continuing at/ { getline; print }'
$commands
EOF