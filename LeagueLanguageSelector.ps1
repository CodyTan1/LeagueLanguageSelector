# Load required assemblies
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName WindowsBase

# Define global variables
$global:ClientPath = "C:\Riot Games\League of Legends\LeagueClient.exe"

# Function to delete existing desktop shortcut
function Remove-DesktopShortcut {
    $shortcutPath = "$env:USERPROFILE\Desktop\LeagueClient.lnk"
    if (Test-Path $shortcutPath) {
        try {
            Remove-Item -Path $shortcutPath -ErrorAction Stop
            Write-Host "Desktop shortcut deleted successfully" -ForegroundColor Green
        } catch {
            Write-Host "An error occurred while deleting the desktop shortcut: $_" -ForegroundColor Red
        }
    }
}

# Function to check if LeagueClient.exe exists in the default path
function Test-LeagueClientExists {
    param (
        [string]$clientPath
    )
    if (Test-Path $global:ClientPath) {
        Write-Host "LeagueClient.exe found in default path" -ForegroundColor Green
        $clientPathTextBox.Text = $clientPath
        $exeStatusText.Text = "LeagueClient.exe found!"
        $exeStatusText.Foreground = "Green"
        return $true
    } else {
        Write-Host "LeagueClient.exe not found in default path" -ForegroundColor Red
        $exeStatusText.Text = "LeagueClient.exe not found."
        $exeStatusText.Foreground = "Red"
        return $false
    }
}

# Function to create a new desktop shortcut
function Create-DesktopShortcut {
    param(
        [string]$clientPath,
        [string]$languageCode
    )
    try {
        Remove-DesktopShortcut  # Remove existing shortcut before creating a new one
        $shortcutFile = "$env:USERPROFILE\Desktop\LeagueClient.lnk"
        $targetPath = $clientPath
        $additionalArgument = "--locale=$languageCode"

        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutFile)
        $shortcut.TargetPath = $targetPath
        $shortcut.Arguments = $additionalArgument
        $shortcut.Save()

        Write-Host "Shortcut created at: $shortcutFile" -ForegroundColor Green
    } catch {
        Write-Host "An error occurred while creating the shortcut: $_" -ForegroundColor Red
    }
}

# Function to handle the submit action
function Handle-Submit {
    param (
        [string]$customPath
    )
    if (-not [string]::IsNullOrWhiteSpace($customPath)) {
        if (Test-Path $customPath) {
            $global:ClientPath = $customPath  # Update global variable
            Test-LeagueClientExists -clientPath $customPath
        } else {
            $exeStatusText.Text = "Invalid custom path: $customPath"
            $exeStatusText.Foreground = "Red"
        }
    } else {
        $exeStatusText.Text = "Custom path is empty"
        $exeStatusText.Foreground = "Red"
    }
}

# Function to handle language selection
function Select-Language {
    param (
        [string]$languageCode
    )
    Write-Host "You selected language code: $languageCode" -ForegroundColor Green
    Create-DesktopShortcut -clientPath $global:ClientPath -languageCode $languageCode
}

# Create the GUI window
$window = New-Object Windows.Window
$window.Title = "Client Language Selector"
$window.Width = 500
$window.Height = 900
$window.ResizeMode = "NoResize"
$window.WindowStartupLocation = "CenterScreen"

# Create a grid to organize elements
$grid = New-Object Windows.Controls.Grid

# Define row and column definitions
1..22 | ForEach-Object {
    $rowDef = New-Object Windows.Controls.RowDefinition
    $rowDef.Height = New-Object Windows.GridLength(40)
    $grid.RowDefinitions.Add($rowDef)
}

# Create title text block
$titleText = New-Object Windows.Controls.TextBlock
$titleText.Text = "Client Language Selector"
$titleText.FontSize = 20
$titleText.Foreground = "Black"
$titleText.Effect = New-Object Windows.Media.DropShadowEffect
$titleText.Effect.Color = "Black"
$titleText.Effect.Direction = 315
$titleText.Effect.ShadowDepth = 2
$titleText.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, 2)
$grid.Children.Add($titleText)

# Create text block for LeagueClient.exe status
$exeStatusText = New-Object Windows.Controls.TextBlock
$exeStatusText.Text = ""
$exeStatusText.FontSize = 14
$exeStatusText.SetValue([Windows.Controls.Grid]::RowProperty, 1)
$grid.Children.Add($exeStatusText)

# Create text field for custom path input
$customPathLabel = New-Object Windows.Controls.Label
$customPathLabel.Content = "Custom Path:"
$customPathLabel.Margin = "-5, 3, 0, 0"
$customPathLabel.FontSize = 16
$customPathLabel.SetValue([Windows.Controls.Grid]::RowProperty, 2)
$grid.Children.Add($customPathLabel)

$customPathTextBox = New-Object Windows.Controls.TextBox
$customPathTextBox.Width = 300
$customPathTextBox.Margin = "10"
$customPathTextBox.SetValue([Windows.Controls.Grid]::RowProperty, 2)
$customPathTextBox.SetValue([Windows.Controls.Grid]::ColumnProperty, 1)
$grid.Children.Add($customPathTextBox)

# Create submit button
$submitButton = New-Object Windows.Controls.Button
$submitButton.Content = "Submit"
$submitButton.Width = 100
$submitButton.Margin = "10"
$submitButton.SetValue([Windows.Controls.Grid]::RowProperty, 2)
$submitButton.HorizontalAlignment="Right"
$submitButton.Add_Click({
    Handle-Submit -customPath $customPathTextBox.Text
})
$grid.Children.Add($submitButton)

# Create text block for language selection
$langText = New-Object Windows.Controls.TextBlock
$langText.Text = "Select Language:"
$langText.FontSize = 16
$langText.SetValue([Windows.Controls.Grid]::RowProperty, 3)
$grid.Children.Add($langText)

# Create buttons for languages
$languages = @{
    "English"                   = "en_US"
    "Japanese"                  = "ja_JP"
    "Chinese (Simplified)"      = "zh_CN"
    "Taiwanese"                 = "zh_TW"
    "Korean"                    = "ko_KR"
    "Spanish (Spain)"           = "es_ES"
    "Spanish (Latin America)"   = "es_MX"
    "French"                    = "fr_FR"
    "German"                    = "de_DE"
    "Italian"                   = "it_IT"
    "Polish"                    = "pl_PL"
    "Romanian"                  = "ro_RO"
    "Greek"                     = "el_GR"
    "Portuguese"                = "pt_BR"
    "Hungarian"                 = "hu_HU"
    "Russian"                   = "ru_RU"
    "Turkish"                   = "tr_TR"
}

$index = 0
# Create buttons for languages
$languages.Keys | ForEach-Object {
    Write-Host "Index: $index"
    Write-Host $_
    $button = New-Object Windows.Controls.Button
    $button.Content = $_
    $button.Width = 200
    $button.Height = 30
    $button.Margin = "5"
    $button.SetValue([Windows.Controls.Grid]::RowProperty, 4 + $index)
    $button.SetValue([Windows.Controls.Grid]::ColumnSpanProperty, 2)
    $button.Add_Click({
        $languageName = $this.Content.ToString()
        if ($languageName -ne $null) {
            $languageCode = $languages[$languageName]
            if ($languageCode -ne $null) {
                Write-Host "Language selected: $languageName, Language code: $languageCode"
                Select-Language -languageCode $languageCode
            } else {
                Write-Host "Language code not found for language: $languageName"
            }
        } else {
            Write-Host "Language name not found for button"
        }
    })
    $grid.Children.Add($button)
    $index++
}

$clientPathTextBox = New-Object Windows.Controls.TextBox
$clientPathTextBox.Text = $global:ClientPath  # Initialize with global client path

# Add the grid to the window
$window.Content = $grid

# Check if LeagueClient.exe exists in the default path
Test-LeagueClientExists

# Show the window
$window.ShowDialog() | Out-Null
