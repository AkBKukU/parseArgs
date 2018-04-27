#!/bin/bash

argmap=(
	"h:help:argHelp:1:0:Display this help dialog"
)

# Parse arguments into values and functions
function argParse()
{
	args=()
	values=()
	cmds=()
	maxPriority=0
	
	# Set all flags to 0
	defaultFlags

	# Store all the passed arguments
	for arg in "$@"
	do 
		args+=("$arg")
	done
	
	# Go through all arguments
	for arg in "${args[@]}"
	do 
		# Command or value?
		if [[ "$arg" == -* ]]
		then
			parseCmd "$arg"
		else
			parseValue "$arg"
		fi
	done

	# Run all functions from the arguments
	argRun
}

# Parse a command
function parseCmd ()
{
	arg=$1

	# Save command without leading dash
	cmdarg="${arg:1}"
	
	# Single letter command or more?
	if [[ ${#cmdarg} > 1 ]]
	then
		# Long form command or multiple single letter?
		if [[ "$cmdarg" == -* ]]
		then
			# Send command to be parsed without leading dash
			argCmdBuild ${cmdarg:1}
		else
			# Send each single letter command
			for i in `seq 0 $(expr ${#cmdarg} - 1 )`
			do 
				argCmdBuild ${cmdarg:$i:1}
			done
		fi
	else
		# Send single letter command
		argCmdBuild $cmdarg
	fi
}

# Parse a value
function parseValue ()
{
	arg=$1
	# Did the last command accept a number of parameters?
	if [[ "$cmdArgCount" > "0" ]]
	then
		# Postpend it to the last command
		lastCmdKey=$(expr ${#cmds[@]} - 1)
		cmds[$lastCmdKey]="${cmds[$lastCmdKey]} \"$arg\""
		# Decrement remaining allowed parameters
		cmdArgCount=$(expr $cmdArgCount - 1)
	else
		# Add it to the default values
		values+=("$arg")
		cmdArgCount=0
	fi
}

# Build function calls from arg using argmap
function argCmdBuild ()
{
	parg=$1
	cmd=""
	cmdArgCount=0
	location=0

	# Is it the full word parameter?
	if [[ ${#parg} > 1 ]]
	then
		location=1
	fi
	
	# Disable globbing
	set -f
	
	# Check argmap entries for a match to the paramater
	for cmdline in "${argmap[@]}"
	do
		# Split the argmap line at the ':'
		cmdinfo=(${cmdline//:/ })

		# Is the parameter in this line?
		if [[ "$parg" != "${cmdinfo[$location]}" ]]
		then
			# Skip to next cmdline
			continue
		fi	
		
		# Limit to one arg for flags
		if [[ "${cmdinfo[3]}" > "9" ]]
		then 
			cmdinfo[3]=9
		fi

		# Check that the max priority is high enough
		# TODO Just set 9 as max priority and don't check
		if [[ "${cmdinfo[3]}" > "$maxPriority" ]]
		then 
			maxPriority=${cmdinfo[3]}
		fi

		cmds+=("${cmdinfo[3]}${cmdinfo[2]}")

		if [[ "${cmdinfo[4]}" > "0" ]]
		then
			cmdArgCount="${cmdinfo[4]}"
			
			# Limit to one arg for flags
			if [[ "${cmdinfo[3]}" == "0" &&  "${cmdinfo[4]}" > "1" ]]
			then 
				cmdArgCount=1
			fi
		fi
		break
	done

	# Renable globbing
	set +f
}

# Run call functions specified by parameters
function argRun ()
{
	# Go through each priority level	
	for i in `seq 0 $maxPriority`
	do 
		# Go through comands
		for cmd in "${cmds[@]}"
		do
			# Check if this is in the flag priority
			if [[ "${cmd:0:1}" == "0" && "$i" == "0" ]]
			then
				setFlagVar "${cmd:1}"
				continue
			fi

			# Check if this is the correct priority to run at
			if [[ "${cmd:0:1}" == "$i" ]]
			then
				eval ${cmd:1}
			fi
		done
	done
}

# Display help generated from the argmap
function argHelp ()
{	
	for cmdline in "${argmap[@]}"
	do
		# Split the argmap line at the ':'
		cmdinfo=(${cmdline//:/ })
	
		# Get positions of all ':' 
		breakpoints=($(grep -aob ':' <<< $cmdline | grep -oE '[0-9]+'))

		# Get all text after 5th ':' for description
		echo -e "\t-${cmdinfo[0]}\t--${cmdinfo[1]}\t\t${cmdline:$(expr ${breakpoints[4]} + 1 )}"
	done

	exit 0
}

# Set all flags to default value of 0
function defaultFlags ()
{	
	for cmdline in "${argmap[@]}"
	do
		# Split the argmap line at the ':'
		cmdinfo=(${cmdline//:/ })
	
		# Get positions of all ':' 
		breakpoints=($(grep -aob ':' <<< $cmdline | grep -oE '[0-9]+'))
		
		if [[ "${cmdinfo[3]}" == "0" ]]
		then 
			setFlagVar "${cmdinfo[2]} 0"
		fi
	done
}

# Set a flag variable's value
function setFlagVar()
{	
	# Test for spaces to determine if value set
	spaceTest="$(echo $1 | grep ' ')"

	# Finding a space means a value was passed
	if [[ -z "$spaceTest" ]]
	then
		# No value found, use "1"
		printf -v $1 "1"
		return 0
	fi

	# Get positions of all ' ' 
	breakpoints=($(grep -aob ' ' <<< $1 | grep -oE '[0-9]+'))
	# Get variable name
	name=${1:0:${breakpoints[0]}}
	
	# Get variable value
	value=${1:$(expr ${breakpoints[0]} + 1)}
	value=$(echo $(echo -e $value) | sed "s/\"$//g" | sed "s/^\"//g")
	printf -v $name "$value"
}

# Add a new parameter to the argmap
# 1: short name               "h"
# 2: long name                "help"
# 3: funtion name             "argHelp"
# 4: prioirty(lower first)    "0"
# 5: num arguments            "0"
# 6: description              "Display this help dialog"
function addParameter () 
{
	argmap+=("$1:$2:$3:$4:$5:$6")
}





