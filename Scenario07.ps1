# Purple Team Simulation - Registry Modification (Low Priv Context)
Write-Output "=== Purple Team Registry Simulation Started ==="
# -------------------------------
# HKCU (User-level modification)
# -------------------------------
$hkcuPath = "HKCU:\Software\PurpleTeamSim"
# Create key if not exists
if (-not (Test-Path $hkcuPath)) {
    New-Item -Path $hkcuPath -Force | Out-Null
    Write-Output "[HKCU] Created key: $hkcuPath"
} else {
    Write-Output "[HKCU] Key already exists: $hkcuPath"
}
# Add or modify values
New-ItemProperty -Path $hkcuPath -Name "SimulationFlag" -Value "True" -PropertyType String -Force | Out-Null
New-ItemProperty -Path $hkcuPath -Name "ExecutionTime" -Value (Get-Date).ToString() -PropertyType String -Force | Out-Null
Write-Output "[HKCU] Values written successfully"
# -------------------------------
# HKLM (Attempt - may fail)
# -------------------------------
$hklmPath = "HKLM:\Software\PurpleTeamSim"
try {
    if (-not (Test-Path $hklmPath)) {
        New-Item -Path $hklmPath -Force | Out-Null
        Write-Output "[HKLM] Created key (unexpected if low priv): $hklmPath"
    }
    New-ItemProperty -Path $hklmPath -Name "SimulationFue" -PropertyType String -Force | Out-Null
    Write-Output "[HKLM] Value written successfully"
}
catch {
    Write-Output "[HKLM] Modification failed (expected for low-priv user): $($_.Exception.Message)"
}
# -------------------------------
# Optional: Persistence-like behavior (HKCU Run Key)
# -------------------------------
$runKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
New-ItemProperty -Path $runKey `
    -Name "PurpleTeamSim" `
    -Value "powershell.exe -WindowStyle Hidden -Command `"Write-Output 'Simulated Persistence'`"" `
    -PropertyType String -Force | Out-Null
Write-Output "[HKCU] Persistence-style Run key added"
Write-Output "=== Simulation Completed ==="
