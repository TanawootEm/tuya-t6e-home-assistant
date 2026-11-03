<#
.SYNOPSIS
Pushes a shell script to the panel and runs it as root.

.DESCRIPTION
Use this instead of long "adb shell" one-liners. Windows PowerShell 5.1 strips inner
double quotes, so a pattern like "a|reboot" can run the real reboot command.

.EXAMPLE
.\Invoke-PanelScript.ps1 -PanelIp 192.168.x.y -ScriptPath .\image-system.sh
#>
param(
    [Parameter(Mandatory)][string]$PanelIp,
    [Parameter(Mandatory)][string]$ScriptPath,
    [string]$ScriptArgs = ''
)

$target = "${PanelIp}:5555"
$remote = '/data/local/tmp/panel-script.sh'
$temp = [IO.Path]::GetTempFileName()

try {
    # Android's shell needs LF line endings.
    $text = [IO.File]::ReadAllText((Resolve-Path $ScriptPath)) -replace "`r`n", "`n"
    [IO.File]::WriteAllText($temp, $text, (New-Object Text.UTF8Encoding($false)))

    adb connect $target | Out-Null
    adb -s $target push $temp $remote | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Could not push the script to the panel.' }

    adb -s $target shell "su 0 sh $remote $ScriptArgs 2>&1"
    $code = $LASTEXITCODE
    adb -s $target shell "rm -f $remote" | Out-Null
    exit $code
}
finally {
    Remove-Item $temp -ErrorAction SilentlyContinue
}
