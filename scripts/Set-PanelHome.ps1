<#
.SYNOPSIS
Makes Companion the Home app and disables the Tuya launcher and app.

.DESCRIPTION
Tuya features may stop working. Waits before finishing so the change can be saved.
Reboot afterwards to verify it. Restore-Tuya.ps1 reverses it.

.EXAMPLE
.\Set-PanelHome.ps1 -PanelIp 192.168.x.y
#>
param([Parameter(Mandatory)][string]$PanelIp)

$target = "${PanelIp}:5555"
$alias = 'io.homeassistant.companion.android.minimal/io.homeassistant.companion.android.launch.LauncherAlias'

adb connect $target | Out-Null
adb -s $target shell 'su 0 pm disable-user --user 0 com.tuya.iotgateway.launcher'
adb -s $target shell 'su 0 pm disable-user --user 0 com.smartpad.fourinchneeu.smart'
adb -s $target shell "su 0 pm enable $alias"
adb -s $target shell "su 0 cmd package set-home-activity $alias"

# An immediate reboot lost disable-user changes on the tested unit.
Write-Host 'Waiting 30 seconds so Android can save the change...'
Start-Sleep -Seconds 30
adb -s $target shell 'su 0 sync'
adb -s $target shell 'pm list packages -d'
Write-Host 'Done. Reboot the panel when ready, and check that Wi-Fi and ADB return.'
