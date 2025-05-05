Add-Type -AssemblyName System.Windows.Forms, Microsoft.VisualBasic
[System.Windows.Forms.Application]::EnableVisualStyles()

# Solicita ao usuário os caminhos de destino
$dataDst = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Informe o caminho de destino para os dados do WhatsApp (Roaming):",
    "Caminho de Dados do WhatsApp",
    "D:\\WhatsAppData"
)
if ([string]::IsNullOrWhiteSpace($dataDst)) { exit }

$cacheDst = [Microsoft.VisualBasic.Interaction]::InputBox(
    "Informe o caminho de destino para o cache do WhatsApp (Local Packages):",
    "Caminho de Cache do WhatsApp",
    "D:\\WhatsAppCache"
)
if ([string]::IsNullOrWhiteSpace($cacheDst)) { exit }

# Cria janela principal
$form = New-Object System.Windows.Forms.Form
$form.Text = "Gerenciar Dados do WhatsApp"
$form.Size = New-Object System.Drawing.Size(450, 230)
$form.StartPosition = "CenterScreen"

# Botões da interface
$moveButton = New-Object System.Windows.Forms.Button
$moveButton.Text = "Mover dados para o destino informado"
$moveButton.Size = New-Object System.Drawing.Size(380, 30)
$moveButton.Location = New-Object System.Drawing.Point(30, 20)
$moveButton.Add_Click({
        Move-And-Link "$env:USERPROFILE\AppData\Roaming\WhatsApp" $dataDst
        Move-And-Link "$env:USERPROFILE\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm" $cacheDst
        [System.Windows.Forms.MessageBox]::Show("✅ Dados movidos com sucesso!", "Concluído")
    })

$restoreButton = New-Object System.Windows.Forms.Button
$restoreButton.Text = "Restaurar dados para os locais originais"
$restoreButton.Size = New-Object System.Drawing.Size(380, 30)
$restoreButton.Location = New-Object System.Drawing.Point(30, 70)
$restoreButton.Add_Click({
        Restore-Link "$env:USERPROFILE\AppData\Roaming\WhatsApp" $dataDst
        Restore-Link "$env:USERPROFILE\AppData\Local\Packages\5319275A.WhatsAppDesktop_cv1g1gvanyjgm" $cacheDst
        [System.Windows.Forms.MessageBox]::Show("✅ Dados restaurados com sucesso!", "Concluído")
    })

$exitButton = New-Object System.Windows.Forms.Button
$exitButton.Text = "Sair"
$exitButton.Size = New-Object System.Drawing.Size(380, 30)
$exitButton.Location = New-Object System.Drawing.Point(30, 120)
$exitButton.Add_Click({ $form.Close() })

# Adiciona controles
$form.Controls.Add($moveButton)
$form.Controls.Add($restoreButton)
$form.Controls.Add($exitButton)

# Funções internas
function Move-And-Link($src, $dst) {
    Stop-Process -Name "WhatsApp" -Force -ErrorAction SilentlyContinue

    if (!(Test-Path $src)) { 
        [System.Windows.Forms.MessageBox]::Show("Fonte não encontrada: $src", "Erro")
        return
    }
    if (!(Test-Path $dst)) {
        New-Item -ItemType Directory -Path $dst | Out-Null
    }

    robocopy $src $dst /E /MOVE | Out-Null
    Remove-Item -Path $src -Recurse -Force -ErrorAction SilentlyContinue
    cmd /c mklink /D "$src" "$dst" | Out-Null
}

function Restore-Link($link, $origin) {
    Stop-Process -Name "WhatsApp" -Force -ErrorAction SilentlyContinue

    if (Test-Path $link) {
        $isSymlink = cmd /c "dir $link" | Select-String "SYMLINKD"
        if ($isSymlink) {
            Remove-Item -Path $link -Force
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("$link não é um link simbólico.", "Aviso")
            return
        }
    }
    New-Item -ItemType Directory -Path $link -ErrorAction SilentlyContinue | Out-Null

    if (Test-Path $origin) {
        robocopy $origin $link /E /MOVE | Out-Null
        Remove-Item -Path $origin -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        [System.Windows.Forms.MessageBox]::Show("Origem não encontrada: $origin", "Erro")
    }
}

[void]$form.ShowDialog()
