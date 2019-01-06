cd $HOME\Documents\WindowsPowerShell

Function set-emacs-mode ()
{
    Set-PSReadlineOption -EditMode Emacs
    Remove-PSReadlineKeyHandler -Chord "TAB"
    Set-PSReadlineKeyHandler -Chord "TAB" TabCompleteNext
}
(Get-Host).PrivateData.ErrorForegroundColor = "green"

set-alias vim "C:\Program Files (x86)\Vim\vim81\gvim.exe"
# set-alias emacs 'C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -nw -n'
set-alias emacs "C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -c -n -a C:\Emacs\emacs-26.1-x86_64\bin\runemacs.exe"
set-alias git "C:\Program Files\Git\bin\git.exe"
