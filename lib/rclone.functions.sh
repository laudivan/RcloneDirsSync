#
#

function getRcloneConf {
    declare -a RcloneConfigList
    
    while read -r _Line_
    do
        RcloneConfigList+=("${_Line_:1:-1}")
    done < "$(rclone config show | egrep '^\[.+\}$')"
}

function sync
{
    local LocalDir=${SyncList[$Idx, $1]}
    local RemoteDir=${SyncList[$Idx, $2]}
    # param ReSync
    #       None: Normal Sync
    #       First: First time syncing 
    #       Err: resync for error 
    local ReSync=$3

    case "$ReSync" in
        'First')
            ReSyncOpt='--resync --resync-mode path2'
            ;;
        'Err')
            ReSyncOpt='--resync --resync-mode newer' 
            ;;
        *)
            ReSyncOpt=''
            ;;
    esac

    rclone bisync "$LocalDir" "$RemoteDir" \
        --verbose \
        --filters-file $_CONF_DIR_/filter.txt \
        $ReSyncOpt

    local -i _err_code_=$?

    return $_err_code_
}

