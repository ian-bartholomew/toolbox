#!/usr/bin/env python3

import os
import subprocess
import sys

# Define ANSI color escape sequences
RED = '\033[31m'
GREEN = '\033[32m'
YELLOW = '\033[33m'
BOLD = '\033[1m'
RESET = '\033[0m'

# Get the parent folder from the command line arguments
parent_folder = sys.argv[1]

# Get the default branch for this Git repository
default_branch = subprocess.check_output(['git', 'symbolic-ref', '--short', 'refs/remotes/origin/HEAD']).decode('utf-8').strip().replace('origin/', '')

# Get a list of all child folders in the parent folder
child_folders = [f.path for f in os.scandir(parent_folder) if f.is_dir()]

# Loop through each child folder and check for Git branches
for folder in child_folders:
    os.chdir(folder)

    # Check if this folder is a Git repository
    try:
        subprocess.check_call(['git', 'rev-parse'])
    except subprocess.CalledProcessError:
        # Skip this folder if it's not a Git repository
        continue

    # Get the current Git branch for this folder
    current_branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).decode('utf-8').strip()

    # Check if there are any unstaged changes
    unstaged_changes = subprocess.check_output(['git', 'status', '--porcelain']).decode('utf-8').strip()

    # Check if this folder's current branch is different from the default branch
    different_branch = current_branch != default_branch

    # Check the number of commits ahead of the default branch
    commits_ahead = 0
    if different_branch:
        try:
            commits_ahead = int(subprocess.check_output(['git', 'rev-list', f'{default_branch}..{current_branch}', '--count']).decode('utf-8').strip())
        except subprocess.CalledProcessError:
            pass

    # Print the results for this folder
    print(f'{YELLOW}{BOLD}Folder:{RESET} {YELLOW}{folder}{RESET}')
    print(f'{GREEN}{BOLD}Current branch:{RESET} {GREEN}{current_branch}{RESET}')

    if unstaged_changes:
        print(f'Unstaged changes:\n{RED}{unstaged_changes}{RESET}')

    if different_branch:
        print(f'{BOLD}This folder is on a different branch than the default branch ({default_branch}).')
        print(f'Commits ahead of default branch: {RED}{commits_ahead}{RESET}')

    print('\n---\n')
