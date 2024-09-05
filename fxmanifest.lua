fx_version 'adamant'
game 'gta5'
lua54 'yes'

client_scripts {
	'client.lua',
}

server_scripts {
	'server.lua',
}


shared_scripts {
	'@ox_lib/init.lua',
	'config.lua'
}

dependencies {
	"ox_lib",
	"qb-core",
	"ars_ambulancejob",
	"ox_inventory"
}
