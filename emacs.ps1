# Локальные переменные для emacs
# ALTERNATE_EDITOR = notepad.exe
# EMACS_SERVER_FILE = C:\emacs\emacs-26.1-x86_64\bin\emacs.exe --daemon

# Запускаем emacs сервер
Start-Process C:\emacs\emacs-26.1-x86_64\bin\emacs.exe --bg-daemon=emacsc
Start-Job { Start-Process C:\emacs\emacs-26.1-x86_64\bin\emacs.exe --daemon } -Name "emacs-client"

Start-Process C:\emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -ArgumentList -nw
Start-Process C:\emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -ArgumentList -nw

C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -nw -n
C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -c -n -a