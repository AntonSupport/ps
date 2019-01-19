
$kdFile = "$HOME\Documents\kd_list2.csv"

Function Add-Password {
    # TODO
    # Переместить в класс
    # Изменить измерение ID используя measure-object -max

    $doc = Import-Csv -Path $kdFile -Encoding UTF8
    [Int]$newID = [int](($doc | Select-Object id -Last 1).id) + 1

    # Date
    $newDate = (Get-Date).ToShortDateString()
    # Modified
    $modifiedDate = ''
    # Whose
    [String]$whose = 'My'
    # Name
    [String]$name = '' # Name of Site
    # Website
    [String]$Website = ''
    # Login
    [String]$login = ''
    # Pass
    [String]$pass = ''
    # Email
    [String]$email = 'qwsx@mail.ru'
    # Question
    [String]$question = ''
    # Answer
    [String]$answer = ''
    # Addition information
    [String]$info = ''

    $doc | Select-Object -Last 10
    $newDate
}

Add-Password