# parseArgs
The bash argument parsing library

This is designed with the thought of there being two different kinds of
arguments; flags, and actions. For example `script --help` would be an action
that displays the help message for the script. `script -v` would typically be a
flag that tells the program to run in verbose mode. With this library you can
add arguments with a single line.

## Including

Before you start adding arguments you need to `source` "parseArgs" into your
bash script `source "$(pwd)/parseArgs.sh"` Will do it if you will be running
your script from the same directory it's in.

Next after you declare and functions the arguments call you need to run
`argParse "$@"` so the parseArgs file can handle everything. See `example.sh`
for a complete demonstration.

## Usage

Let's see what a flag looks like:

```
addParameter "v" "verbose" "verboseMode" "0" "0" "Set verbose output"
```

Let me break down what that line does.

 1. `addParameter` : is a function of the library to add an argument
 2. `v` : is the shorthand name for the argument `script -v`
 3. `verbose` : is the long form name for the argument `script --verbose`
 4. `verboseMode` : will be the name of the variable for the flag `if [[ $verboseMode ]]`
 5. `0` : a "0" means this is a flag, so it gets set before running any actions
 6. `0` : means that this argument takes no additional parameters. It defauts to 0 if not set and 1 if set.
 7. `Set verbose output` : the message to be shown in the generated help menu

Next we'll do an action:

```
addParameter "c" "change" "changeInput" "4" "2" "Change the input"
```

Now here's what that line does. It's very similar to the last one

 1. `addParameter` : is a function of the library to add an argument
 2. `c` : is the shorthand name for the argument `script -c "old" "new"`
 3. `change` : is the long form name for the argument `script --change "old" "new"`
 4. `changeInput` : the name of a function you create to execute the action. More later
 5. `4` : sets the priority to 4, meaning any actions with a lower priority are tun first
 6. `2` : means that this argument takes two additional parameters.
 7. `Change the input` : the message to be shown in the generated help menu


## Example

Now let's look at an example script that uses these, `example.sh`. It's a simple
script to replace parts of a string. If we run the auto generated help we can
see how to use it
```
$ ./example.sh -h
        -h      --help          Display this help dialog
        -v      --verbose               Set verbose output
        -i      --input         Input to change
        -n      --no-numbers            Remove numbers from input
        -c      --change                Change the input. Takes two parameters, a string to find, and a string to replace.

```

Firstly, there are two minor issues here. The output is not well formated and
longer long form names mess up the spacing a bit. And it's currently the auto
help doesn't tell you how many parameters an argument takes. It's up to you to
put it in the help text.

Now we can see we have some basic arguments so let's try running a simple one.

```
$ ./example.sh -i "test123"
test123
```

We set the input flag with `-i "test123" and it automatically create the
variable for the script.

Next let's run the change input parameter as well:

```
$ ./example.sh -i "test123" -c "t1" "at"
texat23
```

We can see the `changeInput` function has been call which used `sed` to replace the
"t1" with "at". The library automatically calls functions you create if they are
one of the arguments.

Now let's add in verbose mode at the end:

```
$ ./example.sh -i "test123" -c "t1" "at" -v
Replacing "t1" with "at"
tesat23
```

The `$verboseMode` variable is automatically created and since it was added to
the command it is active and set to one. Since flags have a priority of 0 the
`$verboseMode` variable is set before `changeInput` is called.

Now let's add the final argument that removes numbers:

```
./example.sh -i "test123" -c "t1" "at" -vn
Removing all numbers
Replacing "t1" with "at"
test
```

We can see the output is now just "test" and that the "t1" to "at" change did
not happen. The no numbers argument has a lower priority than the change input
argument so after removing all the numbers there was no "t1" left in the input.

We can also see that the `n` argument was added directly after `-v` there is no
need to seperate them out. As a matter of fact the whole command could just be
`./example -vni "test" -c "t1" "at" and combine all the flags with the input
action right at the begining.
