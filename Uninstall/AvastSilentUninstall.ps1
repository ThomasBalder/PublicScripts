$stats_file = "C:\Program Files\Avast software\Avast Business\setup\Stats.ini"
(Get-Content $stats_file) | ForEach-Object { $_ -replace "\[Common\]", "[Common]`nSilentUninstallEnabled=1" } | Set-Content $stats_file

Start-Process -filepath "C:\Program Files\Avast software\Avast Business\setup\instup.exe" -argumentlist "/instop:uninstall /silent /wait"
#pause