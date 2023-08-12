fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

shared_script '@ox_lib/init.lua'
shared_script 'config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    '@ox_core/imports/server.lua',
    'server/main.lua',
}

client_scripts {
    '@ox_core/imports/client.lua',
    'client/main.lua',
    'client/cuff.lua',
    'client/escort.lua',
    'client/spikes.lua',
    'client/evidence.lua',
    'client/alpr.lua',
}

files {
    'data/**.lua'
}

ox_libs {
    'table'
}

ox_property_data '/data/mission_row_police_station.lua'
