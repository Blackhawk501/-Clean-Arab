<#
.SYNOPSIS
    Clean Arab Optimizer - Full GUI in PowerShell
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()

# التحقق من صلاحيات المسؤول
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.Forms.MessageBox]::Show("Please run this script as Administrator (Right-Click -> Run with PowerShell)!", "Admin Required", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    exit
}

# النافذة الرئيسية (Main Form)
$form = New-Object System.Windows.Forms.Form
$form.Text = "Clean Arab Optimizer - GUI Edition"
$form.Size = New-Object System.Drawing.Size(850, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$form.ForeColor = [System.Drawing.Color]::White

# التبويبات (TabControl)
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Dock = "Fill"

# ==========================================
# التبويب الأول: برامج وتعاريف (Apps & Drivers)
# ==========================================
$tabApps = New-Object System.Windows.Forms.TabPage
$tabApps.Text = "Apps & Drivers"
$tabApps.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$listBoxApps = New-Object System.Windows.Forms.ListBox
$listBoxApps.Location = New-Object System.Drawing.Point(20, 20)
$listBoxApps.Size = New-Object System.Drawing.Size(400, 450)
$listBoxApps.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$listBoxApps.ForeColor = [System.Drawing.Color]::White
$listBoxApps.Font = New-Object System.Drawing.Font("Segoe UI", 12)

$apps = @(
    "Discord.Discord", "Google.Chrome", "Mozilla.Firefox", 
    "VideoLAN.VLC", "Valve.Steam", "Spotify.Spotify", 
    "7zip.7zip", "RARLab.WinRAR", "EpicGames.EpicGamesLauncher",
    "Nvidia.GeForceExperience", "Nvidia.Broadcast", "ElectronicArts.EADesktop"
)
foreach ($app in $apps) { [void]$listBoxApps.Items.Add($app) }

$btnInstallApp = New-Object System.Windows.Forms.Button
$btnInstallApp.Text = "Install Selected App"
$btnInstallApp.Location = New-Object System.Drawing.Point(450, 20)
$btnInstallApp.Size = New-Object System.Drawing.Size(300, 50)
$btnInstallApp.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnInstallApp.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnInstallApp.Add_Click({
    if ($listBoxApps.SelectedItem) {
        $selectedApp = $listBoxApps.SelectedItem
        [System.Windows.Forms.MessageBox]::Show("Starting installation for $selectedApp. Please wait...", "Info")
        Start-Process "winget" -ArgumentList "install --id $selectedApp -e --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
        [System.Windows.Forms.MessageBox]::Show("$selectedApp Installed Successfully!", "Success")
    }
})

$btnUpdateApp = New-Object System.Windows.Forms.Button
$btnUpdateApp.Text = "Update Selected App"
$btnUpdateApp.Location = New-Object System.Drawing.Point(450, 90)
$btnUpdateApp.Size = New-Object System.Drawing.Size(300, 50)
$btnUpdateApp.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnUpdateApp.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnUpdateApp.Add_Click({
    if ($listBoxApps.SelectedItem) {
        $selectedApp = $listBoxApps.SelectedItem
        [System.Windows.Forms.MessageBox]::Show("Starting update for $selectedApp. Please wait...", "Info")
        Start-Process "winget" -ArgumentList "upgrade --id $selectedApp -e --accept-package-agreements --accept-source-agreements" -Wait -NoNewWindow
        [System.Windows.Forms.MessageBox]::Show("$selectedApp Updated Successfully!", "Success")
    }
})

$labelAppsInfo = New-Object System.Windows.Forms.Label
$labelAppsInfo.Text = "Select an app from the list on the left.`nPowered by Windows Package Manager (Winget)."
$labelAppsInfo.Location = New-Object System.Drawing.Point(450, 160)
$labelAppsInfo.Size = New-Object System.Drawing.Size(350, 50)
$labelAppsInfo.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$labelAppsInfo.ForeColor = [System.Drawing.Color]::LightGray

$tabApps.Controls.Add($listBoxApps)
$tabApps.Controls.Add($btnInstallApp)
$tabApps.Controls.Add($btnUpdateApp)
$tabApps.Controls.Add($labelAppsInfo)

# ==========================================
# التبويب الثاني: تحسينات النظام (System Tweaks)
# ==========================================
$tabTweaks = New-Object System.Windows.Forms.TabPage
$tabTweaks.Text = "System Tweaks & Boost"
$tabTweaks.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$btnRemoveEdge = New-Object System.Windows.Forms.Button
$btnRemoveEdge.Text = "Uninstall Microsoft Edge (Force)"
$btnRemoveEdge.Location = New-Object System.Drawing.Point(50, 30)
$btnRemoveEdge.Size = New-Object System.Drawing.Size(350, 60)
$btnRemoveEdge.BackColor = [System.Drawing.Color]::DarkRed
$btnRemoveEdge.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnRemoveEdge.Add_Click({
    $msg = [System.Windows.Forms.MessageBox]::Show("This will force remove Microsoft Edge from its roots. Are you sure?", "Warning", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
    if ($msg -eq 'Yes') {
        Stop-Process -Name msedge -Force -ErrorAction SilentlyContinue
        Get-AppxPackage *MicrosoftEdge* -AllUsers | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue
        New-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\EdgeUpdate" -Name "DoNotUpdateToEdgeWithChromium" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show("Microsoft Edge has been successfully removed.", "Done")
    }
})

$btnOptimizeCPU = New-Object System.Windows.Forms.Button
$btnOptimizeCPU.Text = "Optimize CPU (High Performance)"
$btnOptimizeCPU.Location = New-Object System.Drawing.Point(50, 110)
$btnOptimizeCPU.Size = New-Object System.Drawing.Size(350, 60)
$btnOptimizeCPU.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnOptimizeCPU.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnOptimizeCPU.Add_Click({
    powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61
    $bgPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
    if (!(Test-Path $bgPath)) { New-Item -Path $bgPath -Force | Out-Null }
    Set-ItemProperty -Path $bgPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("CPU Optimized! High Performance plan activated and Background Apps disabled.", "Done")
})

$btnBoostPing = New-Object System.Windows.Forms.Button
$btnBoostPing.Text = "Boost Network & Reduce Ping"
$btnBoostPing.Location = New-Object System.Drawing.Point(50, 190)
$btnBoostPing.Size = New-Object System.Drawing.Size(350, 60)
$btnBoostPing.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnBoostPing.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnBoostPing.Add_Click({
    ipconfig /flushdns | Out-Null
    netsh winsock reset | Out-Null
    netsh int tcp set global autotuninglevel=normal | Out-Null
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
    if (Test-Path $registryPath) {
        Set-ItemProperty -Path $registryPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -ErrorAction SilentlyContinue
        Set-ItemProperty -Path $registryPath -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
    }
    $tcpPath = "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters"
    if (!(Test-Path $tcpPath)) { New-Item -Path $tcpPath -Force | Out-Null }
    Set-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    [System.Windows.Forms.MessageBox]::Show("Network optimized to suck maximum internet speed! Restart PC to apply.", "Done")
})

$btnCleanTemp = New-Object System.Windows.Forms.Button
$btnCleanTemp.Text = "Clean Temporary Files (Disk Space)"
$btnCleanTemp.Location = New-Object System.Drawing.Point(50, 270)
$btnCleanTemp.Size = New-Object System.Drawing.Size(350, 60)
$btnCleanTemp.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnCleanTemp.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnCleanTemp.Add_Click({
    $tempPaths = @("$env:TEMP\*", "$env:windir\Temp\*", "$env:windir\Prefetch\*")
    foreach ($path in $tempPaths) { Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue }
    [System.Windows.Forms.MessageBox]::Show("Temporary and junk files have been deleted.", "Done")
})

$tabTweaks.Controls.Add($btnRemoveEdge)
$tabTweaks.Controls.Add($btnOptimizeCPU)
$tabTweaks.Controls.Add($btnBoostPing)
$tabTweaks.Controls.Add($btnCleanTemp)

# ==========================================
# التبويب الثالث: برامج بدء التشغيل (Startup Manager)
# ==========================================
$tabStartup = New-Object System.Windows.Forms.TabPage
$tabStartup.Text = "Startup Apps Manager"
$tabStartup.BackColor = [System.Drawing.Color]::FromArgb(45, 45, 48)

$listStartup = New-Object System.Windows.Forms.ListView
$listStartup.Location = New-Object System.Drawing.Point(20, 20)
$listStartup.Size = New-Object System.Drawing.Size(780, 400)
$listStartup.View = [System.Windows.Forms.View]::Details
$listStartup.FullRowSelect = $true
$listStartup.GridLines = $true
$listStartup.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
$listStartup.ForeColor = [System.Drawing.Color]::White
$listStartup.Font = New-Object System.Drawing.Font("Segoe UI", 10)

$listStartup.Columns.Add("App Name", 250) | Out-Null
$listStartup.Columns.Add("Registry", 80) | Out-Null
$listStartup.Columns.Add("Command", 400) | Out-Null

function Load-Startup {
    $listStartup.Items.Clear()
    $paths = @(
        @{ Hive="HKCU"; Path="Software\Microsoft\Windows\CurrentVersion\Run" },
        @{ Hive="HKLM"; Path="SOFTWARE\Microsoft\Windows\CurrentVersion\Run" }
    )
    foreach ($p in $paths) {
        $regPath = $p.Hive + ":\" + $p.Path
        if (Test-Path $regPath) {
            $keys = Get-ItemProperty -Path $regPath -ErrorAction SilentlyContinue
            if ($keys) {
                foreach ($prop in $keys.psobject.properties) {
                    if ($prop.Name -notin @("PSPath","PSParentPath","PSChildName","PSDrive","PSProvider")) {
                        $item = New-Object System.Windows.Forms.ListViewItem($prop.Name)
                        $item.SubItems.Add($p.Hive) | Out-Null
                        $item.SubItems.Add($prop.Value.ToString()) | Out-Null
                        $listStartup.Items.Add($item) | Out-Null
                    }
                }
            }
        }
    }
}
Load-Startup

$btnDisableStartup = New-Object System.Windows.Forms.Button
$btnDisableStartup.Text = "Disable / Remove Selected App from Startup"
$btnDisableStartup.Location = New-Object System.Drawing.Point(20, 440)
$btnDisableStartup.Size = New-Object System.Drawing.Size(400, 50)
$btnDisableStartup.BackColor = [System.Drawing.Color]::DarkRed
$btnDisableStartup.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnDisableStartup.Add_Click({
    if ($listStartup.SelectedItems.Count -gt 0) {
        $selected = $listStartup.SelectedItems[0]
        $name = $selected.Text
        $hive = $selected.SubItems[1].Text
        $regPath = if ($hive -eq "HKCU") { "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" } else { "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" }
        Remove-ItemProperty -Path $regPath -Name $name -Force -ErrorAction SilentlyContinue
        [System.Windows.Forms.MessageBox]::Show("$name removed from startup registry successfully.", "Done")
        Load-Startup
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please select an app first.", "Warning")
    }
})

$btnRefreshStartup = New-Object System.Windows.Forms.Button
$btnRefreshStartup.Text = "Refresh List"
$btnRefreshStartup.Location = New-Object System.Drawing.Point(440, 440)
$btnRefreshStartup.Size = New-Object System.Drawing.Size(150, 50)
$btnRefreshStartup.BackColor = [System.Drawing.Color]::FromArgb(63, 63, 70)
$btnRefreshStartup.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
$btnRefreshStartup.Add_Click({ Load-Startup })

$tabStartup.Controls.Add($listStartup)
$tabStartup.Controls.Add($btnDisableStartup)
$tabStartup.Controls.Add($btnRefreshStartup)

# إضافة التبويبات للنافذة
$tabControl.Controls.Add($tabApps)
$tabControl.Controls.Add($tabTweaks)
$tabControl.Controls.Add($tabStartup)
$form.Controls.Add($tabControl)

# عرض الواجهة
$form.ShowDialog() | Out-Null
