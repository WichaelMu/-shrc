#!/usr/bin/zsh

sudo apt install pipx -y
py -m pip install --user pipx
pipx ensurepath
pipx install pyright
pipx install boto3 --include-deps
pipx install pyfunctional
