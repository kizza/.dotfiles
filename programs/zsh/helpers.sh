BLACK=$(tput setaf 0)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
GREENBG=$(tput setab 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)
CHEVRON="\u2023"
TICK="\xE2\x9C\x94"
CROSS="\xE2\x9C\x96"

function heading {
  echo "\n${GREEN}${CHEVRON}${RESET} $1" && echo "${GREEN}---------------------------------${RESET}"
}

function finished {
  echo "" && donetick
}

function donebox {
  echo "${BLACK}${GREENBG} ${1:-Done} ${RESET}"
}

function donetick {
  echo "${GREEN}${TICK} ${1:-Done}${RESET}"
}

function donearrow {
  echo "${GREEN}${TICK} ${1:-Done}${RESET}"
}

function exitcode {
  scratch=$(mktemp /tmp/scratch.XXXXX)
  trap "rm -f $scratch" EXIT

  eval $1 &> "$scratch"

  if [ $? -eq 0 ]
  then
    echo "${GREEN}${TICK} Success${RESET}"
  else
    echo "${RED}${CROSS} Failure${RESET}" 2>&1
    echo $(cat $scratch)
  fi
}
