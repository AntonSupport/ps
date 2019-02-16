# Создаем файл для тестов на рабочем столе
$dtcsv = "$HOME/Desktop/test.csv"

# (Get-ChildItem $dtcsv).Exists

class Person {
    [string]$name
    [int]$age
}

$p1 = [Person]::new()
$p1.name = "name1"
$p1.age = 12
# $p1 | Export-Csv -Path $dtcsv -Encoding utf8

$p2 = [Person]::new()
$p2.name = "name2"
$p2.age = 14

$p3 = [Person]::new()
$p3.name = "name3"
$p3.age = 15

$res = @( $p1, $p2, $p3 )
$res[0].GetType()
# $res | Export-Csv -Path $dtcsv -Encoding utf8

# [Person]$im = Import-Csv -Path $dtcsv -Encoding utf8
# $im | gm


Get-Password * | select email -Unique | where email -NotContains ''
Get-Password * | select login -Unique | where login -Like "*@*"

$emailSet = @(Get-Password * | select email -Unique | where email -NotContains '')
$loginSet = @(Get-Password * | select login -Unique | where login -Like "*@*")

[array]$p = $emailSet
$p += $loginSet
$p

