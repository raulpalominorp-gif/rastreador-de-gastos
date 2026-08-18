# auto-push.ps1
# Vigila esta carpeta y, cada vez que detecta cambios guardados,
# hace automaticamente git add + commit + push a GitHub (rama main).
#
# Uso:
#   Doble clic (si PowerShell esta configurado para ejecutar .ps1), o desde una terminal:
#     powershell -ExecutionPolicy Bypass -File .\auto-push.ps1
#
# Para detenerlo: cierra la ventana o pulsa Ctrl+C.

$ErrorActionPreference = "Stop"
Set-Location -Path $PSScriptRoot

$intervalSeconds = 5

Write-Host "Vigilando cambios en '$PSScriptRoot'..."
Write-Host "Cada guardado se subira automaticamente a GitHub (rama main)."
Write-Host "Pulsa Ctrl+C para detener.`n"

while ($true) {
    try {
        $status = git status --porcelain

        if ($status) {
            git add -A

            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            git commit -m "Auto-guardado: $timestamp" | Out-Null

            git push origin main 2>&1 | Out-Null

            if ($LASTEXITCODE -eq 0) {
                Write-Host "[$timestamp] Cambios subidos a GitHub."
            } else {
                Write-Host "[$timestamp] ADVERTENCIA: el push fallo. Revisa tu conexion o permisos." -ForegroundColor Yellow
            }
        }
    }
    catch {
        Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    }

    Start-Sleep -Seconds $intervalSeconds
}
