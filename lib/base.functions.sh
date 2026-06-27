#
#

function init {
    declare _CONF_DIR_="${HOME}/.config/rclonedirsync"

    [ ! -d "${_CONF_DIR_}" ] && mkdir -p "${_CONF_DIR_}"
}

function showHeader {
    echo '''
           __  __            __        __       
          |__)/   | _  _  _ |  \. _ _ (_    _  _
          | \ \__ |(_)| )(- |__/|| _) __)\/| )(_
                                         /'''
}

function showHelp {
    echo """
-+-----------------------------------------------------+-
           Use: ${_APP_} [command] [arguments]
-+-----------------------------------------------------+-

COMMANDS
--------
 list : list the pairs of local and remote directories
        added to sync.

 add  : add a pair of local and remote directories to
        that will be synced.
        
        ${_APP_} add id "/local/dir" "id:/remote/folder"

 rm   : remove a pair of local and remote directories to
        the sync list.
        
        ${_APP_} rm id

 sync : sync all saved pairs or a specific pair if its
        id is passed.

        ${_APP_} sync

        ${_APP_} sync sync1

"""

}
