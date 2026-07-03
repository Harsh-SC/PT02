# Configuration
$RepoUrl = "https://github.com/harshmodi008/PurpleTeam"
$ClonePath = "C:\Repo"

# Password source
$PasswordUrl = "https://raw.githubusercontent.com/harshmodi008/PurpleTeam/refs/heads/main/password.txt"
$FallbackPassword = "SUNCOR-PurpleTeam-12#$"

# 7-Zip path
$SevenZip = "C:\Program Files\7-Zip\7z.exe"

# ------------------------------------------------------------------
# Get password from URL, or use fallback
# ------------------------------------------------------------------

try {
    Write-Host "Retrieving password from remote source..."
    $Password = (Invoke-WebRequest -Uri $PasswordUrl -UseBasicParsing -TimeoutSec 10).Content.Trim()

    if (:IsNullOrWhiteSpace($Password)) {
        throw "Password file is empty."
    }

    Write-Host "Password retrieved successfully."
}
catch {
    Write-Warning "Unable to retrieve password. Using fallback password."
    $Password = $FallbackPassword
}

# ------------------------------------------------------------------
# Clone repository
# ------------------------------------------------------------------

if (Test-Path $ClonePath) {
    Remove-Item $ClonePath -Recurse -Force
}

Write-Host "Cloning repository..."
git clone $RepoUrl $ClonePath

if ($LASTEXITCODE -ne 0) {
    throw "Git clone failed."
}

# ------------------------------------------------------------------
# Locate multipart archives
# Example:
#   archive.zip.001
#   archive.zip.002
#
# or
#
#   archive.01
#   archive.02
# ------------------------------------------------------------------

$ArchiveStarts = Get-ChildItem -Path $ClonePath -Recurse -File |
    Where-Object {
        $_.Name -match '\.(001|01)$'
    }

if (-not $ArchiveStarts) {
    Write-Warning "No multipart archive starting files found."
    return
}

# ------------------------------------------------------------------
# Extract archives
# ------------------------------------------------------------------

foreach ($Archive in $ArchiveStarts) {

    $OutputFolder = Join-Path $Archive.DirectoryName ($Archive.BaseName + "_Extracted")

    if (-not (Test-Path $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder | Out-Null
    }

    Write-Host "Extracting $($Archive.FullName)..."

    & $SevenZip x `
        "-p$Password" `
        "-o$OutputFolder" `
        "-y" `
        $Archive.FullName

    if ($LASTEXITCODE -eq 0) {
        Write-Host "Extraction successful: $OutputFolder"
    }
    else {
        Write-Warning "Extraction failed for $($Archive.Name)"
    }
}

Write-Host "Completed."
