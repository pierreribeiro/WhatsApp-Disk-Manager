Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()

$form = New-Object System.Windows.Forms.Form
$form.Text = "Gerenciar Dados do WhatsApp"
$form.Size = New-Object System.Drawing.Size(400, 200)
$form.StartPosition = "CenterScreen"

$moveButton = New-Object System.Windows.Forms.Button
$moveButton.Text = "Mover dados para outro disco"
$moveButton.Size = New-Object System.Drawing.Size(340, 30)
$moveButton.Location = New-Object System.Drawing.Point(30, 20)
$moveButton.Add_Click({
        Move-And-Link "$env:USERPROFILE\AppData\Roaming\WhatsApp" "D:\WhatsAppData"
        Move-And-Link "$env:USERPROFILE\AppData\Local\Packagesř9275A.WhatsAppDesktop_cv1g1gvanyjgm" "D:\WhatsAppCache"
        [System.Windows.Forms.MessageBox]::Show("✅ Dados movidos com sucesso!", "Concluído")
    })

$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Text = "Restaurar dados para o disco C"
$restoreButton.Size = New-Object System.Drawing.Size(340, 30)
$restoreButton.Location = New-Object System.Drawing.Point(30, 60)
$restoreButton.Add_Click({
        Restore-Link "$env:USERPROFILE\AppData\Roaming\WhatsApp" "D:\WhatsAppData"
        Restore-Link "$env:USERPROFILE\AppData\Local\Packagesř9275A.WhatsAppDesktop_cv1g1gvanyjgm" "D:\WhatsAppCache"
        [System.Windows.Forms.MessageBox]::Show("✅ Dados restaurados com sucesso!", "Concluído")
    })

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Sair"
$exitButton.Size = New-Object System.Drawing.Size(340, 30)
$exitButton.Location = New-Object System.Drawing.Point(30, 100)
$exitButton.Add_Click({ $form.Close() })

$form.Controls.Add($moveButton)
$form.Controls.Add($restoreButton)
$form.Controls.Add($exitButton)

function Move-And-Link($src, $dst) {
    Stop-Process -Name "WhatsApp" -Force -ErrorAction SilentlyContinue
    if (!(Test-Path $src)) { return }
    if (!(Test-Path $dst)) { New-Item -ItemType Directory -Path $dst | Out-Null }
    robocopy $src $dst /E /MOVE | Out-Null
    Remove-Item -Path $src -Recurse -Force -ErrorAction SilentlyContinue
    cmd /c mklink /D "$src" "$dst" | Out-Null
}

function Restore-Link($link, $origin) {
    Stop-Process -Name "WhatsApp" -Force -ErrorAction SilentlyContinue
    if (Test-Path $link) {
        $isSymlink = cmd /c "dir $link" | Select-String "SYMLINKD"
        if ($isSymlink) { Remove-Item -Path $link -Force } else { return }
    }
    New-Item -ItemType Directory -Path $link -ErrorAction SilentlyContinue | Out-Null
    if (Test-Path $origin) {
        robocopy $origin $link /E /MOVE | Out-Null
        Remove-Item -Path $origin -Recurse -Force -ErrorAction SilentlyContinue
    }
}

[void]$form.ShowDialog()
