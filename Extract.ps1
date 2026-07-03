$Parts = Get-ChildItem "tool.zip.*" | Sort-Object Name

$OutputZip = "tool.zip"

$OutStream = [System.IO.File]::Create($OutputZip)

foreach ($Part in $Parts) {
    $Bytes = [System.IO.File]::ReadAllBytes($Part.FullName)
    $OutStream.Write($Bytes,0,$Bytes.Length)
}

$OutStream.Close()

Expand-Archive -Path $OutputZip -DestinationPath ".\Extracted"
