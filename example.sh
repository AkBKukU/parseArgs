#!/bin/bash

source "$(pwd)/parseArgs.sh"

# Flags
addParameter "v" "verbose" "verboseMode" "0" "0" "Set verbose output"
addParameter "i" "input" "input" "0" "1" "Input to change"

# Actions
addParameter "n" "no-numbers" "removeNumbers" "1" "0" "Remove numbers from input"
addParameter "c" "change" "changeInput" "4" "2" "Change the input. Takes two parameters, a string to find, and a string to replace."


removeNumbers()
{
	if [[ "$verboseMode" == "1" ]]
	then
		echo "Removing all numbers"
	fi

	input="$(echo "$input" | sed 's/[0-9]//g')"
}

changeInput()
{
	if [[ "$verboseMode" == "1" ]]
	then
		echo "Replacing \"$1\" with \"$2\""
	fi

	input="$(echo "$input" | sed "s/$1/$2/g")"
}

argParse "$@"

echo "$input"
