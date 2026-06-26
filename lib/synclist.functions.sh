#
#

function getSyncList
{
    declare -g -A SyncList
    decalre -g -i SyncListSize=0

    [ ! -f "$_CONF_DIR_/sync.list" ] && touch "$_CONF_DIR_/sync.list"
    
    while read -r _LINE_; do
        LocalDir="$(echo $_LINE_ | cut -f 1 -d '=' | xargs)"
        RemoteDir="$(echo $_LINE_ | cut -f 2 -d '=' | xargs)"

        SyncList[$SyncListSize,0]=$LocalDir
        SyncList[$SyncListSyze,1]=$RemoteDir

        let SyncListSize++
    done < $_CONF_DIR_/sync.list
}

function syncDirs
{
    for ((i=0; i < SyncListSize; i++))
    do
        syncDir ${SyncList[$i,0]} ${SyncList[$i,1]}
    done
}

function syncDir
{
    local LocalDir=$1
    local RemoteDir=$2

    # TODO: Check first time
    # TODO: Error threatment
    #
    # rclone bisync "$LocalDir" "$RemoteDir" --verbose --filters-file $_CONF_DIR_/filter.txt --resync --resync-mode newer
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


