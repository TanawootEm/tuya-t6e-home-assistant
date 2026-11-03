<#
.SYNOPSIS
Restores the Tuya launcher and app, and removes Companion as Home.

.DESCRIPTION
Reverses Set-PanelHome.ps1 and reboots the panel. Not run on the tested unit.

.EXAMPLE
.\Restore-Tuya.ps1 -PanelIp 192.168.x.y
#>
param([Parameter(Mandatory)][string]$PanelIp)

$target = "${PanelIp}:5555"
$alias = 'io.homeassistant.companion.android.minimal/io.homeassistant.companion.android.launch.LauncherAlias'
$tuyaHome = 'com.tuya.iotgateway.launcher/com.tuya.smart.iotgateway.launcher.MainActivity'

adb connect $target | Out-Null
adb -s $target shell 'su 0 pm enable com.tuya.iotgateway.launcher'
adb -s $target shell 'su 0 pm enable com.smartpad.fourinchneeu.smart'
adb -s $target shell "su 0 pm disable $alias"
adb -s $target shell "su 0 cmd package set-home-activity $tuyaHome"

# Give Android time to save the change before the reboot.
Start-Sleep -Seconds 30
adb -s $target shell 'su 0 sync'
adb -s $target reboot
