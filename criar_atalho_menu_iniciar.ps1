
$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Gerenciador do WhatsApp.lnk")
$Shortcut.TargetPath = "$PSScriptRoot\GerenciarWhatsApp.exe"
$Shortcut.IconLocation = "$PSScriptRoot\GerenciarWhatsApp.exe"
$Shortcut.Save()
