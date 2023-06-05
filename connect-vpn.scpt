on run argv
	set senha to item 2 of argv
	set code to item 3 of argv
	
	tell application "System Events" to tell process "GlobalProtect"
		-- clicar no ícone do GlobalProtect na barra de menus e em "Connect"
		click menu bar item 1 of menu bar 2
		if exists button "Connect" of window 1 then
			-- inicia a conexão
			click button "Connect" of window 1
			click menu bar item 1 of menu bar 2
			delay 12
			
			-- Insere a senha
			keystroke "" & senha
			keystroke return
			delay 3
			-- Insere o código MFA
			keystroke "" & code
			keystroke return
			delay 2
			keystroke return
			
			-- testa a conexão
			set viaVarejoCorpFound to false
			set dnsOutput to do shell script "scutil --dns"
			if dnsOutput contains "via.varejo.corp" then
				log "Conectado com sucesso!"
			else
				log "A conexão falhou."
				
			end if
		end if
	end tell
end run
