#!/bin/bash

# Script to list all the current git branches in all of
# the child folders for the given folder

# handy color vars for pretty prompts
GREEN="\033[0;32m"
WHITE="\033[1;37m"
COLOR_RESET="\033[0m"

for dir in $1/*/     # list directories in the form "/tmp/dirname/"
do
    cd $dir

    if [[ -d ".git" ]]
    then
      dir=${dir%*/}      # remove the trailing "/"
      branch=$(git rev-parse --abbrev-ref HEAD)
      echo -e "${WHITE}${dir##*/}: ${GREEN}${branch}${COLOR_RESET}"    # print everything after the final "/"
    fi
done
