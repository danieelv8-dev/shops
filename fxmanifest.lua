shared_script '@ElectronAC/src/include/shared.lua'
fx_version 'cerulean'
game 'gta5'
name 'Project Nashville — Sklepy'
version '1.1.2'
shared_scripts { '@ox_lib/init.lua', 'config.lua' }
client_script 'client.lua'
server_script 'server.lua'
ui_page 'ui/index.html'
files { 'ui/index.html', 'ui/style.css', 'ui/app.js' }
dependencies { '/onesync', 'es_extended', 'ox_lib', 'ox_inventory', 'ox_target' }
