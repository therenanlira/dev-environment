-- testa a conexão
set vpnConnection to false
set dnsOutput to do shell script "scutil --dns"
if dnsOutput contains "via.varejo.corp" then
	set vpnConnection to true
else
	set vpnConnection to false
end if

-- conecta a vpn
if vpnConnection is false then
	tell application "System Events" to tell process "GlobalProtect"
		click menu bar item 1 of menu bar 2
		if exists button "Connect" of window 1 then
			click button "Connect" of window 1
			delay 15
		end if
		-- testa a conexão
		click menu bar item 1 of menu bar 2
		set viaVarejoCorpFound to false
		set dnsOutput to do shell script "scutil --dns"
		if dnsOutput contains "via.varejo.corp" then
			log "Conectado com sucesso!"
		else
			log "A conexão falhou."
		end if
	end tell
end if