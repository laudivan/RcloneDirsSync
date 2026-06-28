#
#

function loadSyncList
{
    declare -g -A SyncList
    decalre -g -i SyncListSize=0

    [ ! -f "$_CONF_DIR_/sync.list" ] && touch "$_CONF_DIR_/sync.list"
    
    while read -r _LINE_; do
        
        SyncId="$(echo $_LINE_ | cut -f 1 -d '=' | xargs)"
        LocalDir="$(echo $_LINE_ | cut -f 2 -d '=' | xargs)"
        RemoteDir="$(echo $_LINE_ | cut -f 3 -d '=' | xargs)"

        SyncList[$SyncListSize,1]=$SyncId
        SyncList[$SyncListSize,2]=$LocalDir
        SyncList[$SyncListSyze,3]=$RemoteDir

        let SyncListSize++
    done < $_CONF_DIR_/sync.list
}

function syncDirs
{
    for ((i=0; i < SyncListSize; i++))
    do
        syncDirByIndex $i
    done
}

function syncDir {
    local SyncId=$1

    for ((i=0; i < SyncListSize; i++))
    do
        if [ $i == $SyncId ]; then
           syncDirByIndex $i

           break;
        fi
    done

    #TODO: find index and pass to syncDirByIndex
}

function addDirs2Sync
{
    local LocalDir=$1
    local RemoteDir=$2

}

function checkDirs2Sync
{
    local LocalDir=$1
    local RemoteDir=$2

}


