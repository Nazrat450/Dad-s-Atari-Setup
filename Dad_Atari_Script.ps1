Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === Configuration Management ===
$configFile = Join-Path $PSScriptRoot "atari_config.txt"

function Load-Configuration {
    if (Test-Path $configFile) {
        $config = Get-Content $configFile | ConvertFrom-Json
        return $config
    }
    return $null
}

function Save-Configuration {
    param($atariFolder, $emuHawkPath)
    
    $config = @{
        AtariFolder = $atariFolder
        EmuHawkPath = $emuHawkPath
    }
    
    $config | ConvertTo-Json | Out-File $configFile -Encoding UTF8
}

function Prompt-ForConfiguration {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Atari Setup - First Time Configuration"
    $form.Size = New-Object System.Drawing.Size(600, 300)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false

    # Atari Folder Label and TextBox
    $atariLabel = New-Object System.Windows.Forms.Label
    $atariLabel.Location = New-Object System.Drawing.Point(20, 20)
    $atariLabel.Size = New-Object System.Drawing.Size(150, 20)
    $atariLabel.Text = "Atari ROMs Folder:"
    $form.Controls.Add($atariLabel)

    $atariTextBox = New-Object System.Windows.Forms.TextBox
    $atariTextBox.Location = New-Object System.Drawing.Point(20, 45)
    $atariTextBox.Size = New-Object System.Drawing.Size(400, 25)
    $atariTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($atariTextBox)

    $atariBrowseBtn = New-Object System.Windows.Forms.Button
    $atariBrowseBtn.Location = New-Object System.Drawing.Point(430, 45)
    $atariBrowseBtn.Size = New-Object System.Drawing.Size(100, 25)
    $atariBrowseBtn.Text = "Browse"
    $atariBrowseBtn.Add_Click({
        try {
            $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
            $folderBrowser.Description = "Select Atari ROMs Folder"
            $folderBrowser.SelectedPath = [Environment]::GetFolderPath("MyDocuments")
            $result = $folderBrowser.ShowDialog()
            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                $atariTextBox.Text = $folderBrowser.SelectedPath
            }
            $folderBrowser.Dispose()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error selecting folder: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $form.Controls.Add($atariBrowseBtn)

    # Emulator Label and TextBox
    $emuLabel = New-Object System.Windows.Forms.Label
    $emuLabel.Location = New-Object System.Drawing.Point(20, 80)
    $emuLabel.Size = New-Object System.Drawing.Size(150, 20)
    $emuLabel.Text = "Emulator Path:"
    $form.Controls.Add($emuLabel)

    $emuTextBox = New-Object System.Windows.Forms.TextBox
    $emuTextBox.Location = New-Object System.Drawing.Point(20, 105)
    $emuTextBox.Size = New-Object System.Drawing.Size(400, 25)
    $emuTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $form.Controls.Add($emuTextBox)

    $emuBrowseBtn = New-Object System.Windows.Forms.Button
    $emuBrowseBtn.Location = New-Object System.Drawing.Point(430, 105)
    $emuBrowseBtn.Size = New-Object System.Drawing.Size(100, 25)
    $emuBrowseBtn.Text = "Browse"
    $emuBrowseBtn.Add_Click({
        try {
            $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $fileBrowser.Filter = "Executable Files (*.exe)|*.exe|All Files (*.*)|*.*"
            $fileBrowser.Title = "Select Emulator Executable"
            $fileBrowser.InitialDirectory = [Environment]::GetFolderPath("ProgramFiles")
            $result = $fileBrowser.ShowDialog()
            if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
                $emuTextBox.Text = $fileBrowser.FileName
            }
            $fileBrowser.Dispose()
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("Error selecting file: $($_.Exception.Message)", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    $form.Controls.Add($emuBrowseBtn)

    # Instructions
    $instructionsLabel = New-Object System.Windows.Forms.Label
    $instructionsLabel.Location = New-Object System.Drawing.Point(20, 140)
    $instructionsLabel.Size = New-Object System.Drawing.Size(540, 60)
    $instructionsLabel.Text = "Please select the folder containing your Atari ROMs and the path to your emulator executable. These settings will be saved for future use."
    $instructionsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $form.Controls.Add($instructionsLabel)

    # OK Button
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point(200, 220)
    $okButton.Size = New-Object System.Drawing.Size(100, 30)
    $okButton.Text = "OK"
    $okButton.DialogResult = "OK"
    $form.Controls.Add($okButton)

    # Cancel Button
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point(320, 220)
    $cancelButton.Size = New-Object System.Drawing.Size(100, 30)
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = "Cancel"
    $form.Controls.Add($cancelButton)

    $result = $form.ShowDialog()
    
    if ($result -eq "OK") {
        return @{
            AtariFolder = $atariTextBox.Text
            EmuHawkPath = $emuTextBox.Text
        }
    }
    return $null
}

# === Load or Prompt for Configuration ===
$config = Load-Configuration

if (-not $config) {
    $config = Prompt-ForConfiguration
    if (-not $config) {
        [System.Windows.Forms.MessageBox]::Show("Configuration cancelled. Exiting.", "Setup Cancelled", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        exit
    }
    
    # Validate paths
    if (-not (Test-Path $config.AtariFolder)) {
        [System.Windows.Forms.MessageBox]::Show("Atari folder path is invalid: $($config.AtariFolder)", "Invalid Path", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
    
    if (-not (Test-Path $config.EmuHawkPath)) {
        [System.Windows.Forms.MessageBox]::Show("Emulator path is invalid: $($config.EmuHawkPath)", "Invalid Path", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        exit
    }
    
    Save-Configuration -atariFolder $config.AtariFolder -emuHawkPath $config.EmuHawkPath
}

# === Configuration ===
$atariFolder = $config.AtariFolder
$emuHawkPath = $config.EmuHawkPath

# === Main Form ===
$form = New-Object System.Windows.Forms.Form
$form.Text = "Atari Game Launcher"

# === Increased width to fit side label ===
$form.Size = New-Object System.Drawing.Size(750, 550)
$form.StartPosition = "CenterScreen"
$form.Topmost = $true

# === Search TextBox ===
$searchBox = New-Object System.Windows.Forms.TextBox
$searchBox.Location = New-Object System.Drawing.Point(10, 10)
$searchBox.Size = New-Object System.Drawing.Size(360, 30)
$searchBox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$form.Controls.Add($searchBox)

# === ListBox for Games ===
$listBox = New-Object System.Windows.Forms.ListBox
$listBox.Location = New-Object System.Drawing.Point(10, 50)
$listBox.Size = New-Object System.Drawing.Size(360, 430)
$listBox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$form.Controls.Add($listBox)

# === Load Game Folders ===
if (Test-Path $atariFolder) {
    $gameFolders = Get-ChildItem -Path $atariFolder -Directory
    $originalList = $gameFolders.Name
    $listBox.Items.AddRange($originalList)
} else {
    [System.Windows.Forms.MessageBox]::Show("Atari folder not found: $atariFolder`nPlease run the script again to reconfigure.", "Path Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    exit
}

# === Filter List When Typing ===
$searchBox.Add_TextChanged({
    $listBox.Items.Clear()
    $filtered = $originalList | Where-Object { $_ -like "*$($searchBox.Text)*" }
    $listBox.Items.AddRange($filtered)
})

# === Double-Click to Launch Game ===
$listBox.Add_DoubleClick({
    $selectedGame = $listBox.SelectedItem
    if (-not $selectedGame) { return }

    if (-not (Test-Path $emuHawkPath)) {
        [System.Windows.Forms.MessageBox]::Show("Emulator not found at $emuHawkPath.`nPlease run the script again to reconfigure.", "Emulator Not Found", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $gamePath = Join-Path $atariFolder $selectedGame
    $rom = Get-ChildItem -Path $gamePath -Include *.a26, *.bin, *.rom -Recurse -File | Select-Object -First 1

    if (-not $rom) {
        [System.Windows.Forms.MessageBox]::Show("No ROM file found in '$selectedGame'.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Launch Emulator in windowed mode with the ROM
    Start-Process -FilePath $emuHawkPath `
        -ArgumentList "`"$($rom.FullName)`"" `
        -WorkingDirectory (Split-Path $emuHawkPath)

    # Close the launcher
    $form.Close()
})

# === Controls Label ===
$controlsLabel = New-Object System.Windows.Forms.Label
$controlsLabel.Location = New-Object System.Drawing.Point(390, 50)
$controlsLabel.Size = New-Object System.Drawing.Size(330, 430)
$controlsLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$controlsLabel.Text = @"
Keyboard Controls

Up = Up Arrow
Down = Down Arrow
Left = Left Arrow
Right = Right Arrow

Action/Fire = Space Bar
Select = Enter Button
Restart = Shift (Left)

Some games like Asteroids require you to press 'Restart' to begin.

Controller Controls Coming Soon
"@
$controlsLabel.AutoSize = $false
$controlsLabel.BorderStyle = 'FixedSingle'
$controlsLabel.TextAlign = 'TopLeft'
$form.Controls.Add($controlsLabel)

# === Launch GUI ===
$form.Add_Shown({ $form.Activate() })
[void]$form.ShowDialog()
