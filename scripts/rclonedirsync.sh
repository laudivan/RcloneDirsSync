#!/bin/bash

_APP_=$(basename "${BASH_SOURCE[0]}")

_APP_DIR_="$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../" && pwd)"

source "$_APP_DIR_/lib/base.functions.sh"

init

showHeader

showHelp

# TODO: Threat aguments

exit 0
