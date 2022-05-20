#!/bin/bash

# ---------------------------------------------------------------------
#
# This script finds all the files with a given name in a directory
# and does a diff against a reference file, and optionally removes
# the file and commits the change.
#

DATE=$(date +%Y-%m-%d)
BRANCH="tflint-update-$DATE"
FILENAME=".tflint.hcl"
REFERENCE_FILE="/path/to/reference/file"
PR_TITLE="title"
PR_BODY="body"

DIRS=$(find ~/Dev \
  -maxdepth 1 \
  -type d \
  -name "terraform-aws*" \
  -not -path '*/\.git/*' \
  -not -path '*/\.terragrunt-cache/*')

clear

for DIR in $DIRS; do
  echo "============================================================"
  echo "${DIR}"
  cd "${DIR}" || exit
  # Find all files in ~/Dev named .tflint.hcl
  FILES=$(find . \
    -not -path '*/\.git/*' \
    -not -path '*/\.terragrunt-cache/*' \
    -type f -name "${FILENAME}")

  # promt user to continue
  echo
  read -p "Continue? (y/n) " -n 1 -r
  echo    # (optional) move to a new line
  if [[ $REPLY =~ ^[Yy]$ ]]
  then
    git checkout main

    # print the current git branch
    echo
    echo "Current branch: $(git rev-parse --abbrev-ref HEAD)"
    echo

    # ask the user if they want to create a new branch
    echo
    read -p "Create new branch? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      # create a new branch
      git checkout -b "${BRANCH}"
    else
      git checkout "${BRANCH}"
    fi
    for FILE in $FILES; do
      echo
      echo "*******************************************"
      echo "File: $FILE"
      echo ""

      # print the diff between the file and the template
      diff -u <(cat $FILE) <(cat $REFERENCE_FILE)
      # ask the user if they want to remove the file
      read -p "Remove ${FILE}? (y/n) " -n 1 -r
      echo    # (optional) move to a new line
      if [[ $REPLY =~ ^[Yy]$ ]]
      then
        # remove the file
        git rm "${FILE}"
      fi
    done

    # ask the user if they want to commit the changes
    echo
    read -p "Commit changes? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      # commit the changes
      git commit -m "Remove tflint config"
    fi

    # ask the user if they want to push the changes
    echo
    read -p "Push changes? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      # push the changes
       git push --set-upstream origin $BRANCH
    fi

    # ask the user if they want to create a pull request
    echo
    read -p "Create pull request? (y/n) " -n 1 -r
    echo    # (optional) move to a new line
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
      # create a pull request
      gh pr create \
        --title "${PR_TITLE}" \
        --body "${PR_BODY}"
    fi

    git checkout main
  fi

done
