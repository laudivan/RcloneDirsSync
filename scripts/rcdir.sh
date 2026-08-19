#!/usr/bin/env bash
#∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆#
#                   __  __            __        __                           #
#                  |__)/   | _  _  _ |  \. _ _ (_    _  _                    #
#                  | \ \__ |(_)| )(- |__/|| _) __)\/| )(_                    #
#                  by ~{l4u}                      /                          #
# •••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••••• #
# BSD 3-Clause License                                                       #
#                                                                            #
# Copyright (c) 2026, Laudivan Freire de Almeida                             #
#                                                                            #
# Redistribution and use in source and binary forms, with or without         #
# modification, are permitted provided that the following conditions are met:#
# 1. Redistributions of source code must retain the above copyright notice,  #
#    this list of conditions and the following disclaimer.                   #
#                                                                            #
# 2. Redistributions in binary form must reproduce the above copyright       #
#    notice, this list of conditions and the following disclaimer in the     # 
#    documentation and/or other materials provided with the distribution.    #
#                                                                            #
# 3. Neither the name of the copyright holder nor the names of its           #
#    contributors may be used to endorse or promote products derived from    #
#    this software without specific prior written permission.                #
#                                                                            #
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS    #
# IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,  #
# THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR     #
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR          #
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,      #
# EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,        #
# PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;#
# OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,   #
# WHETHER IN CONTRACT, STRICT LIABILITY,                                     #
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE  #
# USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.   #
#∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆∆#

declare -r _APP_="$(basename "$0")"
declare -r _APP_DIR_="$(cd "$(dirname "$(realpath "$0")")/../" && pwd)"
declare -r _CONF_DIR_="${HOME}/.config/rclonedirsync"

declare -r DEBUG_MODE=0

declare -r -a _ARGS_=("${@}")
declare -r _ARGS_COUNT_=${#_ARGS_[@]}

declare -A _SYNC_LIST_=()
declare -r _DELIM_=';'
declare -i _SYNC_LIST_SIZE_=0

declare -r WARN_SYNCID_ALREADY_EXIST=101
declare -r WARN_SYNC_PAIR_ALREADY_EXIST=102
declare -r ERRO_SYNCID_DOESNT_EXIST=103
declare -r ERR_RCLONE_FATAL_ERROR=7
declare -r OK_SYNC_PAIR_ADDED=201
declare -r OK_SYNC_PAIR_REMOVED=202
declare -r OK_SYNC_PAIR_SYNCED=203
declare -r OK_SYNC_ALL_DIRS_SYNCED=204
declare -r INFO_SYNC_LIST_IS_EMPTY=205

declare -a _MESSAGES_=(
    [$WARN_SYNCID_ALREADY_EXIST]="[WARN] SyncId already exists."
    [$WARN_SYNC_PAIR_ALREADY_EXIST]="[WARN] Sync pair already exists."
    [$ERRO_SYNCID_DOESNT_EXIST]="[ERRO] SyncId doesn't exist."
    [$ERR_RCLONE_FATAL_ERROR]="[ERRO] Rclone Fatal Error"
    [$OK_SYNC_PAIR_ADDED]="[INFO] Sync pair successfully added!"
    [$OK_SYNC_PAIR_REMOVED]="[INFO] Sync pair successfully removed!"
    [$OK_SYNC_PAIR_SYNCED]="[INFO] Dir successfully synced!"
    [$OK_SYNC_ALL_DIRS_SYNCED]="[INFO] Dirs successfully synced!"
    [$INFO_SYNC_LIST_IS_EMPTY]="[INFO] Sync list is empty!"
)

main ()
{
    local -i __err__=0

    showHeader

    init

    [ ${_ARGS_COUNT_} == 0 ] && showHelp && exit 0

    declare -u COMMAND="${_ARGS_[0]}"

    case "${COMMAND}" in
        LIST)
            listAllSyncDirs
            __err__=$?
        ;;
        ADD)
            addDirToSyncList "${_ARGS_[1]}" "${_ARGS_[2]}" "${_ARGS_[3]}"
            __err__=$?
        ;;
        RM)
            rmDirFromSyncList "${_ARGS_[1]}"
            __err__=$?
        ;;
        SYNC)
            case "${_ARGS_COUNT_}" in
                1)
                    syncDirs
                    __err__=$?
                    ;;
                2)
                    syncDir "${_ARGS_[1]}"
                    __err__=$?
                    
                    ;;
            esac
        ;;
        ADD_CRON)
            addToCron ${_ARGS_[1]} ${_ARGS_[2]} 
        ;;
        HELP)
            showHelp ${_ARGS_[1]}
            
        ;;
        *)
            showHelp
        ;;
    esac

    printf "\n${_MESSAGES_[$__err__]}\n"

    return $__err__
}

init () 
{
    [ ! -d "${_CONF_DIR_}" ] && mkdir -p "${_CONF_DIR_}"

    [ ! -f "${_CONF_DIR_}/filter.txt" ] && \
        cat << EOF > "${_CONF_DIR_}/filter.txt"
# Start line with '-' to exclude and '+' to include
- *.tmp
- *.bak
- /ignored-folder/**
- .DS_Store
- .localized
# Include everything else
+ *
EOF

    [ ! -f "${_CONF_DIR_}/sync.list" ] && \
        touch "${_CONF_DIR_}/sync.list"

    loadSyncList
}

showHeader ()
{
    printf "\n%s\n%s\n%s\n%s\n" \
        ' __  __            __        __ ' \
        '|__)/   | _  _  _ |  \. _ _ (_    _  _ ' \
        '| \ \__ |(_)| )(- |__/|| _) __)\/| )(_ ' \
        'by ~{l4u}'
}

showHelp ()
{
    local -r -l _COMMAND_=$1

    local header=''
    local description=''
    local subheader=''
    local content=''
    local examples=''
    
    case "${_COMMAND_^^}" in
        LIST)
            header="LIST"
            description="List all sync pairs."
            subheader=""
            content="This command list all saved sync pairs, their id, paths and first sync state."
            examples="\$ ${_APP_} LIST"
        ;;
        ADD)
            header="ADD"
            description="Add a new sync pair."
            subheader=""
            content="This command add a new sync pair of paths identified by a sync_id. You can add both local and remote paths."
            examples="\$ ${_APP_} ADD sync2 /local/path/ cloud:/remote/path/"
        ;;
        RM)
            header="RM"
            description="Remove a sync pair."
            subheader=""
            content="This command removes a sync pair of paths identified by a sync_id."
            examples="\$ ${_APP_} RM SyncID2"
        ;;
        SYNC)
            header="SYNC"
            description="Sync all pairs or a specific pair"
            subheader=""
            content="This command synchronizes all pairs or a specific pair if its id is passed"
            examples="\$ ${_APP_} SYNC\n\n\$ ${_APP_} SYNC sync2"
        ;;
        ADD_CRON)
            header="ADD CRON"
            description="Add a new sync pair to cron"
            subheader=""
            content="Adds a cron job to sync the directories at a specific interval using crontab syntax. If no sync_id is provided, all sync pairs will be added to cron and if no interval is provided, the default interval (daily at 00:00) will be used. You can pass the interval using crontab syntax (ie. \"0 0 * * *\" for daily at 00:00) or using a more human-readable format (daily, hourly, weekly, monthly)."
            examples="\$ ${_APP_} ADD_CRON sync2 0 */2 * * *"
        ;;
        *)
            header=""
            description="This app helps you manage your rclone sync operations. It allows you to add, remove, and sync pairs of directories, and also allows you to add a cron job to sync the directories at a specific interval."
            subheader="COMMANDS: HELP | LIST | ADD | RM | SYNC | ADD_CRON"
            content="Use HELP and a command name for more information."
            examples="\$ ${_APP_} HELP LIST"
        ;;
    esac

    printf '\n%s\n' "$header"
    printf "%-60s\n" | tr ' ' '-'
    printf '%s\n' "$description" | fmt -w 60
    printf '\n%s\n' "$subheader"
    printf '%s\n' "$content" | fmt -w 50
    printf '\nExample:\n%b\n' "$examples"
}

# 

listAllSyncDirs ()
{
    local _SYNC_TABLE_FORMAT_='%-10s %-25s %-30s %3s'
    local _REMOTE_TABLE_FORMAT_='%-10s %-10s %.55s'
    local _TABLE_WIDTH_=80

    printf '\nREMOTE RCLONE LIST\n'
    printf "%-${_TABLE_WIDTH_}s\n" | tr ' ' '.'
    printf "${_REMOTE_TABLE_FORMAT_}\n" 'Id' 'Type' 'Token'
    printf "%-${_TABLE_WIDTH_}s\n" | tr ' ' '.'
    
    while IFS= read -r _REMOTE_
    do
        Conf=$(rclone config show "${_REMOTE_}")
        Id=${_REMOTE_%?}
        Type=$(echo "$Conf" | grep "^type" | cut -f 2 -d '=' | xargs)
        Token=$(echo "$Conf" | grep "^token" | cut -f 2 -d '=' | xargs)

        printf "${_REMOTE_TABLE_FORMAT_}...\n" $Id $Type ${Token:14}
    done <<< "$(rclone listremotes)"
    
    printf '\n\nSYNC LIST\n'

    loadSyncList

    [ $_SYNC_LIST_SIZE_ == 0 ] && return $INFO_SYNC_LIST_IS_EMPTY

    printf "%-${_TABLE_WIDTH_}s\n" | tr ' ' '.'
    printf "${_SYNC_TABLE_FORMAT_}\n" 'SyncId' 'LocalDir' 'RemoteDir' '1st'
    printf "%-${_TABLE_WIDTH_}s\n" | tr ' ' '.'

    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        printf "${_SYNC_TABLE_FORMAT_}\n" \
            "${_SYNC_LIST_[$Idx,1]}" \
            "${_SYNC_LIST_[$Idx,2]}" \
            "${_SYNC_LIST_[$Idx,3]}" \
            "${_SYNC_LIST_[$Idx,4]}"
    done
}

checkSyncIdExist () 
{
    local SyncId=$1

    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        [ "${_SYNC_LIST_[$Idx,1]}" == "$SyncId" ] && \
            return $WARN_SYNCID_ALREADY_EXIST
    done

    return 0
}

checkDirPairExist () 
{
    local LocalDir=$1
    local RemoteDir=$2
    
    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        [ "${_SYNC_LIST_[$Idx,2]}" == "${LocalDir}" ] && \
        [ "${_SYNC_LIST_[$Idx,3]}" == "${RemoteDir}" ] && \
            return $WARN_SYNC_PAIR_ALREADY_EXIST
    done

    return 0
}    

addDirToSyncList ()
{
    local SyncId=$1
    local LocalDir=$2
    local RemoteDir=$3
    
    checkSyncIdExist "$SyncId"
    __err__=$?
    [ $__err__ -eq $WARN_SYNCID_ALREADY_EXIST ] && \
        return $WARN_SYNCID_ALREADY_EXIST

    checkDirPairExist "$LocalDir" "$RemoteDir"
    __err__=$?
    [ $__err__ -eq $WARN_SYNC_PAIR_ALREADY_EXIST ] && \
    return $WARN_SYNC_PAIR_ALREADY_EXIST

    printf "%s${_DELIM_}%s${_DELIM_}%s${_DELIM_}yes\n" \
        "${SyncId}" \
        "${LocalDir}" \
        "${RemoteDir}" >> "${_CONF_DIR_}/sync.list"
    
    return $OK_SYNC_PAIR_ADDED
}

rmDirFromSyncList ()
{
    local SyncId=$1
    
    if [ "$(grep "^$SyncId$_DELIM_" "${_CONF_DIR_}/sync.list")" != "" ]; then
        sed -i '' "/^$SyncId$_DELIM_/d" "${_CONF_DIR_}/sync.list"

        return $OK_SYNC_PAIR_REMOVED
    fi

    return $ERRO_SYNCID_DOESNT_EXIST
}

# SyncList

loadSyncList ()
{
    _SYNC_LIST_SIZE_=0
    _SYNC_LIST_=()

    while read -r _LINE_; do
        SyncId="$(echo $_LINE_ | cut -f 1 -d "${_DELIM_}" | xargs)"
        LocalDir="$(echo $_LINE_ | cut -f 2 -d "${_DELIM_}" | xargs)"
        RemoteDir="$(echo $_LINE_ | cut -f 3 -d "${_DELIM_}" | xargs)"
        FirstTime="$(echo $_LINE_ | cut -f 4 -d "${_DELIM_}" | xargs)"

        _SYNC_LIST_[$_SYNC_LIST_SIZE_,1]=$SyncId
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,2]=$LocalDir
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,3]=$RemoteDir
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,4]=$FirstTime

        let _SYNC_LIST_SIZE_++
    done < "${_CONF_DIR_}/sync.list"
}

saveSyncList () 
{
    > "${_CONF_DIR_}/sync.list"

    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        printf "%s${_DELIM_}%s${_DELIM_}%s${_DELIM_}%s\n" \
            "${_SYNC_LIST_[$Idx,1]}" \
            "${_SYNC_LIST_[$Idx,2]}" \
            "${_SYNC_LIST_[$Idx,3]}" \
            "${_SYNC_LIST_[$Idx,4]}" >> "$_CONF_DIR_/sync.list"
    done
}

syncDir ()
{
    local SyncId=$1

    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        [ ${_SYNC_LIST_[$Idx,1]} == $SyncId ] && \
            syncDirByIndex $Idx && \
            return 0
    done

    return $ERR_SYNCID_NOT_FOUND
}

syncDirs ()
{
    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        syncDirByIndex $Idx
    done
}

syncDirByIndex ()
{
    local Idx=$1
    local -i _sync_err_=0

    local LocalDir=${_SYNC_LIST_[$Idx,2]}
    local RemoteDir=${_SYNC_LIST_[$Idx,3]}
    local FirstTimeSync=${_SYNC_LIST_[$Idx,4]}

    sync "$LocalDir" "$RemoteDir" "$FirstTimeSync"

    [ $? == 7 ] && \
        sync "$LocalDir" "$RemoteDir" 'Err'

    _sync_err_=$?

    [ "${_SYNC_LIST_[$Idx,4]}" == "yes" ] && \
        _SYNC_LIST_[$Idx,4]="no" && \
        saveSyncList

    return $_sync_err_
}

# Rclone

function sync {
    local LocalDir="${1}"
    local RemoteDir="${2}"
    local FirstTimeSync="${3}"

    case "$FirstTimeSync" in
        'yes')
            ReSyncOpt='--resync'
            Msg='First_time_sync_'
            ;;
        'Err')
            ReSyncOpt='--resync --resync-mode newer'
            Msg='Recovering_from_error_' 
            ;;
        *)
            ReSyncOpt=''
            Msg='Normal_sync_mode_'
            ;;
    esac

    [ $DEBUG_MODE == 1 ] && ReSyncOpt+=' --verbose'

    printf '%-30s' "$Msg" | tr ' ' '╾' | tr '_' ' '
    printf ' (%s ⇔ %s)' "$LocalDir" "$RemoteDir"

    rclone bisync "$LocalDir" "$RemoteDir" \
        --filters-file $_CONF_DIR_/filter.txt \
        $ReSyncOpt
        # --conflict-resolve 'larger' \
        # --recover \
        # --drive-skip-gdocs \
        # --checksum \

    __err__=$?

    printf ' [✔]\n'

    return $__err__
}

main

exit $?
