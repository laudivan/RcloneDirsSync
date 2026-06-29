#
#

declare -A _SYNC_LIST_=()
declare _LIST_DELIMITER_=';'
declare -i _SYNC_LIST_SIZE_=0

function loadSyncList {
    while read -r _LINE_; do
       
        SyncId="$(echo $_LINE_ | cut -f 1 -d ${_LIST_DELIMITER_} | xargs)"
        LocalDir="$(echo $_LINE_ | cut -f 2 -d ${_LIST_DELIMITER_} | xargs)"
        RemoteDir="$(echo $_LINE_ | cut -f 3 -d ${_LIST_DELIMITER_} | xargs)"
        FirstTime="$(echo $_LINE_ | cut -f 4 -d ${_LIST_DELIMITER_} | xargs)"

        _SYNC_LIST_[$_SYNC_LIST_SIZE_,1]=$SyncId
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,2]=$LocalDir
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,3]=$RemoteDir
        _SYNC_LIST_[$_SYNC_LIST_SIZE_,4]=$FirstTime

        let _SYNC_LIST_SIZE_++

    done < $_CONF_DIR_/sync.list
}

function saveSyncList {
    > "$_CONF_DIR_/sync.list"

    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        echo "${_SYNC_LIST_[$Idx,1]}${_LIST_DELIMITER_}${_SYNC_LIST_[$Idx,2]}${_LIST_DELIMITER_}${_SYNC_LIST_[$Idx,3]}${_LIST_DELIMITER_}${_SYNC_LIST_[$Idx,4]}" >> "$_CONF_DIR_/sync.list"
    done
}

function syncDirs {
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
    if [ "${FirstTimeSync}" == "yes" ]; then 
        ReSync='First'
    fi

    sync $ReSync

    if [ $? == 7 ]; then
        sync 'Err'
    fi

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

function addDirs2SyncList {
    local SyncId=$1
    local LocalDir=$2
    local RemoteDir=$3
    local FirstTimeSync=$4

    _SYNC_LIST_[${_SYNC_LIST_SIZE},1]="${SyncId}"
    _SYNC_LIST_[${_SYNC_LIST_SIZE},2]="${LocalDir}"
    _SYNC_LIST_[${_SYNC_LIST_SIZE},3]="${RemoteDir}"
    _SYNC_LIST_[${_SYNC_LIST_SIZE},4]="${FirstTimeSync}"

    let _SYNC_LIST_SIZE_++
}

function getDirSyncIndex {
    local SyncId=$1

    for ((Idx=1; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        [ ${_SYNC_LIST_[$Idx,1]} == $SyncID ] && return $Idx
    done

    return 0
}

function createSyncListFile {
    echo 'SyncId;LocalDir;RemoteDir;FirstSync' > "$_CONF_DIR_/sync.list"
}

function listAllSyncDirs {
    loadSyncList
    for ((Idx=0; Idx < _SYNC_LIST_SIZE_; Idx++))
    do
        printf "%-8s | %-25s | %-25s | %10s\n" "${_SYNC_LIST_[$Idx,1]}" "${_SYNC_LIST_[$Idx,2]}" "${_SYNC_LIST_[$Idx,3]}" "${_SYNC_LIST_[$Idx,4]}"
    done
}