Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# === Configuration ===
$atariFolder = "C:\Atari"
$emuHawkPath = "C:\Stella-7.0c\Stella.exe"

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
$gameFolders = Get-ChildItem -Path $atariFolder -Directory
$originalList = $gameFolders.Name
$listBox.Items.AddRange($originalList)

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
        [System.Windows.Forms.MessageBox]::Show("EmuHawk not found at $emuHawkPath.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    $gamePath = Join-Path $atariFolder $selectedGame
    $rom = Get-ChildItem -Path $gamePath -Include *.a26, *.bin, *.rom -Recurse -File | Select-Object -First 1

    if (-not $rom) {
        [System.Windows.Forms.MessageBox]::Show("No ROM file found in '$selectedGame'.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        return
    }

    # Launch EmuHawk in windowed mode with the ROM
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
