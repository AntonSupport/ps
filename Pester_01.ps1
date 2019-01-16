


# Изучение Pester на MVA
# https://mva.microsoft.com/en-us/training-courses/testing-powershell-with-pester-17650?l=3saNgN9vD_8011787177
# Testing PowerShell with Pester

# Describe - Основная группа
Describe 'MVA tests' {
    it '$true should be true' {
        $true | Should be $true
    }
    
    # Context - подгруппа (Не обязательно)
    Context 'Арифметические операции' {
        it 'Broken test' {
            1 + 1 | Should be 3
        }

        it '2x2 Always 4' {
            2 * 2 | Should be 4
        }
    }

    Context 'Тестирование строк' {
        it 'Поиск в тексте' {
            "Привет" | Should belike "*п*" # Проходит проверку!!!
        }

        it 'Точное совпадение' {
            "Hello" | Should not match "h" # Проходит проверку!!! Match - Можно считать как начинается с
        }
    }

    Context 'AAA Approach' {
        
        $stringToTest = 'Test String'

        it 'Should be like' {
            $stringToTest | Should belike 'test*'
        }
    }
}

Describe 'TestDrive Demo' {
    
    BeforeAll {
        Add-Content -Path TestDrive:\testfile.txt -Value "Test File"
    }

    AfterAll {
        Write-Host (Get-Content -Path TestDrive:\testfile.txt)
    }

    it 'TestDrive exist' {
        "TestDrive:\" | Should exist
    }

    it 'The file we just created should be in TEstDrive' {
        'TestDrive:\testfile.txt' | Should exist
    }
}

