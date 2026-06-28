#
#

function init {
    declare _CONF_DIR_="${HOME}/.config/rclonedirsync"

    [ ! -d "${_CONF_DIR_}" ] && mkdir -p "${_CONF_DIR_}"

    [ ! -f "${_CONF_DIR_}/filter.txt" ] && \
        cp "${_APP_DIR_}/doc/filter.txt.template" "${_CONF_DIR_}/filter.txt"

    [ ! -f "${_CONF_DIR_}/sync.list" ] && touch "${_CONF_DIR_}/sync.list"

}

function showHeader {
    cat "${_APP_DIR_}/assets/head.1.txt"
}

function showHelp {
    cat "${_APP_DIR_}/assets/help.home.txt" 
}
