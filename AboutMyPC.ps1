<#
.SYNOPSIS
Основная информация о железе
.DESCRIPTION
Основная информация:
Название материнской платы
Название процессора
Название оперативки и основные свойства
Название жесткого диска и его основные свойства
Другая информация
.EXAMPLE
./AboutMyPC.ps1
#>


Write-Host "Материнская плата"
Get-WmiObject -Class Win32_BaseBoard | Format-Table

Write-Host "Процессор"
Get-WmiObject -Class CIM_Processor | Select-Object Name, Manufacturer, Caption, MaxClockSpeed, NumberOfCores, NumberOfLogicalProcessors

