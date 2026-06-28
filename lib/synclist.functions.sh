#
#

local _LIST_DELEMITER_=';'
local -i _SYNC_LIST_SIZE_=0
local -A _SYNC_LIST_

function loadSyncList
{
    declare -g -A SyncList
    declare -g -i SyncListSize=0
    
    while read -r _LINE_; do
        
        SyncId="$(echo $_LINE_ | cut -f 1 -d '=' | xargs)"
        LocalDir="$(echo $_LINE_ | cut -f 2 -d '=' | xargs)"
        RemoteDir="$(echo $_LINE_ | cut -f 3 -d '=' | xargs)"

        _SYNC_LIST_[$_SYNC_LIST_SIZE_,1]=$SyncId
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,2]=$LocalDir
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,3]=$RemoteDir

        let _SYNC_LIST_SIZE_++

    done < $_CONF_DIR_/sync.list
}

function saveSyncList
{
    [ $_SYNC_LIST_SIZE_ == 0 ] && addDir2SyncList 

    [ ! -f "$_CONF_DIR_/sync.list" ] && \
        touch "$_CONF_DIR_/sync.list"
}

function syncDirs
{
    for ((Idx=1; Idx < _SYNC_LIST_SIZE_; Idx++))
    # Idx must start as 1 to ignore the file head
    do
        syncDirByIndex $Idx
    done
}

function syncDirByIndex {
    local Idx=$1

    local SyncId=${_SYNC_LIST_[$Idx,1]}
    local LocalDir=${_SYNC_LIST_[$Idx,2]}
    local RemoteDir=${_SYNC_LIST_[$Idx,3]}
    local FirstTimeSync=${_SYNC_LIST_[$Idx,4]}

    local ReSync=''
    [ "${FirstTimeSync}" == "yes" ] && ReSync='First'

    [ $(sync "$ReSync") == 7 ] && sync 'Err'

    return $?
}

function syncDir {
    local SyncId=$1

    local -i SyncIndex=$(getDirSyncIndex "${SyncId}")


    [ $SyncIndex > 0 ] && \
        syncDirByIndex $SyncIndex && \
        return 0

    return 1
}

function addDirs2SyncList
{
    local SyncId=$1
    local LocalDir=$2
    local RemoteDir=$3

}

function getDirSyncIndex
{
    local SyncId=$1

    for ((Idx=1; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        [ ${_SYNC_LIST_[$Idx,1]} == $SyncID ] && return $Idx
    done

    return 0
}
