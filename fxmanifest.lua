fx_version 'cerulean'
game 'gta5'

description 'QB PostOp Job'
version '1.0.0'

client_scripts {
    '@menuv/menuv.lua',
    'client/main.lua',
}

shared_script 'config.lua'

server_scripts {
    'server/main.lua',
} 

dependency 'menuv'

lua54 'yes'
