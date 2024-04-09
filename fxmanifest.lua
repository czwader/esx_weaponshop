fx_version 'adamant'

game 'gta5'

description 'Adds a way for players to buy weapons'
lua54 'yes'
version '1.0'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

server_scripts {
	'server/main.lua'
}

client_scripts {
	'client/warmenu.lua',
	'client/main.lua'
}
