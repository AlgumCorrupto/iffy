#!/bin/bash

cd $(dirname "$0")


. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
mix run --no-halt
