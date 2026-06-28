#
#

function getRcloneConf {
    declare -a RcloneConfigList
    
    while read -r _Line_
    do
        RcloneConfigList+=("${_Line_:1:-1}")
    done < "$(rclone config show | egrep '^\[.+\}$')"
}

function syncDirByIndex
{
    local Idx=$1
    local SyncId=${SyncList[$Idx, $1]}
    local LocalDir=${SyncList[$Idx, $2]}
    local RemoteDir=${SyncList[$Idx, $3]}

    # TODO: Check first time
    # TODO: Error threatment
    #

    rclone bisync "$LocalDir" "$RemoteDir" \
        --verbose \
        --filters-file $_CONF_DIR_/filter.txt # --resync --resync-mode newer
}

