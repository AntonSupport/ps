Get-Process | select Name -First 1 | Get-Member
Get-Process | select -ExpandProperty Name -First 1 | Get-Member
$(Get-Process | select -ExpandProperty Name -First 1) | Get-Member
$(Get-Process | select Name -First 1) | Get-Member

$x1 = $true
$x2 = $false

($null -notin @($x2, $x2, $x3))

(@($x1, $x2 -contains $true))
(Get-Service a*).Name | Get-Member
Get-Service a* | select Name | Get-Member


Get-Service m* | where Status -eq running | gm
(Get-Service m*).where( {$_.Status -eq "Running"})

