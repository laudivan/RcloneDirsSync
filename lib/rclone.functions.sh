#
#

function getRcloneConf {
    declare -a RcloneConfigList
    
    while read -r _Line_
    do
        RcloneConfigList+=("${_Line_:1:-1}")
    done < "$(rclone config show | egrep '^\[.+\}$')"
}

