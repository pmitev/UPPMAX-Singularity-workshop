#!/bin/bash
# asciinema rec --overwrite -c "./exec.sh" -t title  file.cast
# docker run --rm -v $PWD:/data asciinema/asciicast2gif -s 2 -S 1 file.cast file.gif

simType="randtype -t 4,20000 -m 0"
simTypeFast="randtype -t 18,200 -m 0"
PROMPT='$ \c'

prompt() {
  echo -en "\n${PROMPT}\033[0m"
}

display1() {
  echo -en "\033[32;1m$@\033[0m" |  randtype -t 4,20000 -m 4;
}

run_command() {
  echo -en "\033[35;1m$@\033[0m" |  randtype -t 4,20000 ; sleep 1; echo ""
  eval "$@"; echo -en "\n${PROMPT}"
}

prompt;
sleep 1
display1 "# Let's build this recipe"; prompt
run_command "cat Singularity.lolcow"


sleep 1
display1 "# Run the build"; prompt
run_command "sudo singularity build lolcow.sif Singularity.lolcow"

sleep 1
display1 "# And run the container"; prompt
run_command "./lolcow.sif"

prompt;
