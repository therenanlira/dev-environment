tell application "System Events" to tell process "GlobalProtect"
	-- clicar no ícone do GlobalProtect na barra de menus e clica em "Connect"
	click menu bar item 1 of menu bar 2
	click button "Connect" of window 1
	click menu bar item 1 of menu bar 2
	delay 15
	
	-- testa a conexão
	set viaVarejoCorpFound to false
	set dnsOutput to do shell script "scutil --dns"
	if dnsOutput contains "via.varejo.corp" then
		log "Conectado com sucesso!"
	else
		log "A conexão falhou."
		
	end if
end tell