schtasks /create /sc minute /mo 30 /tn "UpdaterService" /tr "powershell.exe -File C:\PurpleLab\downloader.ps1"

