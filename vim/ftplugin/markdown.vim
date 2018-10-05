packadd vim-emoji
setlocal completefunc=emoji#complete

setlocal formatoptions-=a
setlocal linebreak textwidth=80
if !exists("b:did_ftplugin")
	setlocal statusline+=\ \|\ %{wordcount()['words']}\ words
	let b:did_ftplugin = 1
endif
setlocal spell
