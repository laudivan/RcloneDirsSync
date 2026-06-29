#!/usr/bin/env bash
# ========================================================================== #
#            __  __            __        __                                  #
#           |__)/   | _  _  _ |  \. _ _ (_    _  _                           #
#           | \ \__ |(_)| )(- |__/|| _) __)\/| )(_                           #
#                                          /                                 #
#                                                                            #
# SCRIPT NAME: reclonedirsync.sh                                             #
# DESCRIPTION:                                                               #
# AUTHOR:      ~{l4u} <laudivan@gmail.com>                                   #
# DATE:        2026-06-25                                                    #
# ========================================================================== #

_APP_=$(basename "${BASH_SOURCE[0]}")

_APP_DIR_=$(cd "$(dirname "$(realpath "${BASH_SOURCE[0]}")")/../" && pwd)

source "$_APP_DIR_/lib/base.functions.sh"
source "$_APP_DIR_/lib/synclist.functions.sh"
source "$_APP_DIR_/lib/rclone.functions.sh"

init

showHeader

[ $# == 0 ] && showHelp && exit 0

case "$1" in
    list)
        listAllSyncDirs
    ;;
    add)
        addDirToSyncList $2 $3 $4
    ;;
    rm)
        rmDirFromSyncList $2
    ;;
    sync)
        syncDir $2
    ;;
    *)
        showHelp
    ;;
esac

# TODO: Threat aguments

exit 0
