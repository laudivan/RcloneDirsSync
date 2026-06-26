#
#

function init 
{
    declare -g -a RcloneConfigList
    declare -g _CONF_DIR_="${HOME}/.config/rclonedirsync"

    while read -r _Line_
    do
        RcloneConfigList+=("${_Line_:1:-1}")
    done < "$(rclone config show | egrep '^\[.+\}$')"

    echo ${#RcloneConfigList[*]}

    [ ! -d "${_CONF_DIR_}" ] && mkdir -p "${_CONF_DIR_}"
}

function showHeader {
    return
}

function showHelp {
    return
}
