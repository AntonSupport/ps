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