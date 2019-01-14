Set-Location $HOME\Documents\WindowsPowerShell

Function set-emacs-mode ()
{
    Set-PSReadlineOption -EditMode Emacs
    Remove-PSReadlineKeyHandler -Chord "TAB"
    Set-PSReadlineKeyHandler -Chord "TAB" TabCompleteNext
}
(Get-Host).PrivateData.ErrorForegroundColor = "green"


<#
.SYNOPSIS
Укладывает компьютер спать

.DESCRIPTION
По непонятным мне причинам, компьютер ложится спать только со второй попытке.
Функция иметирует мои действия, когда необходимо уложить компьютер спать.
Полсе запуска, компьютер должен войти в состояние сна в течении 10 сек.

.EXAMPLE
Sleep-Computer

В течении десяти секунд компьютер должен уснуть

#>
Function Sleep-Computer {
    PROCESS{
        for ($i=0; $i -le 1; $i++) {
            # 1. Define the power state you wish to set, from the
            #    System.Windows.Forms.PowerState enumeration.
            $PowerState = [System.Windows.Forms.PowerState]::Suspend;

            # 2. Choose whether or not to force the power state
            $Force = $true;

            # 3. Choose whether or not to disable wake capabilities
            $DisableWake = $false;

            # Set the power state
            [System.Windows.Forms.Application]::SetSuspendState($PowerState, $Force, $DisableWake);

            Start-Sleep 5

            $Pos = [System.Windows.Forms.Cursor]::Position
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X) + 1) , $Pos.Y)
            [System.Windows.Forms.Cursor]::Position = New-Object System.Drawing.Point((($Pos.X) - 1) , $Pos.Y)

            $myshell = New-Object -com "Wscript.Shell"
            $myshell.sendkeys(".")
        }
    }
}

# set-alias vim "C:\Program Files (x86)\Vim\vim81\gvim.exe"
# set-alias emacs 'C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -nw -n'
# set-alias emacs "C:\Emacs\emacs-26.1-x86_64\bin\emacsclientw.exe -c -n -a C:\Emacs\emacs-26.1-x86_64\bin\runemacs.exe"
# set-alias git "C:\Program Files\Git\bin\git.exe"
