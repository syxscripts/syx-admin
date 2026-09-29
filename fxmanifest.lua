fx_version 'cerulean'
game 'gta5'

author 'Syntax Scripts'
description 'License-based admin list + panel, exports IsAdmin/IsSuperAdmin for other resources'
version '1.0.0'

dependency 'syx-ui'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}

shared_scripts {
    'config.lua',
}

client_scripts {
    'client.lua',
}

server_scripts {
    'storage.lua',
    'server.lua',
}
