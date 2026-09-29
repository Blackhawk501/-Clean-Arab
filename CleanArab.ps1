# ==========================================
# أداة "كلين عرب" لتحسين الشبكة وتخفيف الجهاز
# ==========================================

# التحقق من صلاحيات المسؤول
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Warning "تحذير: يرجى تشغيل البرنامج كمسؤول (Run as Administrator) ليعمل بشكل صحيح."
    Pause
    exit
}

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "       Clean Arab Optimizer       " -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# 1. إنشاء نقطة استعادة للنظام
Write-Host "[1/5] جاري إنشاء نقطة استعادة للنظام باسم 'كلين عرب' احتياطياً..." -ForegroundColor Yellow
Enable-ComputerRestore -Drive "C:\" -ErrorAction SilentlyContinue
Checkpoint-Computer -Description "كلين عرب" -RestorePointType "MODIFY_SETTINGS" -ErrorAction SilentlyContinue
Write-Host "-> تم إنشاء نقطة الاستعادة بنجاح!" -ForegroundColor Green
Write-Host ""

# 2. تخفيف المعالج وتفعيل الأداء العالي
Write-Host "[2/5] جاري تخفيف الضغط عن المعالج وتفعيل وضع الأداء العالي (High Performance)..." -ForegroundColor Yellow
# تفعيل وضع الأداء العالي
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c | Out-Null
# تفعيل Ultimate Performance (إن وجد)
powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null
$UltimatePlan = powercfg -l | Select-String "Ultimate Performance" | ForEach-Object { $_.Line.Split(' ')[3] }
if ($UltimatePlan) { powercfg -setactive $UltimatePlan | Out-Null }

# إيقاف تطبيقات الخلفية لتخفيف استهلاك المعالج
$bgPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications"
if (!(Test-Path $bgPath)) { New-Item -Path $bgPath -Force | Out-Null }
Set-ItemProperty -Path $bgPath -Name "GlobalUserDisabled" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# تعطيل ميزة توفير الطاقة لمنافذ USB لتقليل تأخير الماوس والكيبورد
$usbPath = "HKLM:\System\CurrentControlSet\Services\USB"
if (!(Test-Path $usbPath)) { New-Item -Path $usbPath -Force | Out-Null }
Set-ItemProperty -Path $usbPath -Name "DisableSelectiveSuspend" -Value 1 -Type DWord -ErrorAction SilentlyContinue

# 3. تنظيف الجهاز
Write-Host "[3/5] جاري تنظيف الجهاز وتخفيف النظام من الملفات المؤقتة..." -ForegroundColor Yellow
$tempPaths = @(
    "$env:TEMP\*",
    "$env:windir\Temp\*",
    "$env:windir\Prefetch\*",
    "$env:windir\SoftwareDistribution\Download\*"
)
foreach ($path in $tempPaths) {
    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
}

# 4. تحسين الشبكة والبنق
Write-Host "[4/5] جاري تحسين اتصال الإنترنت وتقليل البنق..." -ForegroundColor Yellow
ipconfig /flushdns | Out-Null
ipconfig /registerdns | Out-Null
netsh winsock reset | Out-Null
netsh int ip reset | Out-Null
netsh int tcp set global autotuninglevel=normal | Out-Null
netsh int tcp set global chimney=disabled | Out-Null
netsh int tcp set global dca=enabled | Out-Null
netsh int tcp set global netdma=enabled | Out-Null

$registryPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile"
if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $registryPath -Name "SystemResponsiveness" -Value 0 -Type DWord -ErrorAction SilentlyContinue
}

$tcpPath = "HKLM:\SOFTWARE\Microsoft\MSMQ\Parameters"
if (!(Test-Path $tcpPath)) { New-Item -Path $tcpPath -Force | Out-Null }
Set-ItemProperty -Path $tcpPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue

$interfacesPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $interfacesPath | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -ErrorAction SilentlyContinue
}

# 5. إيقاف خدمات الويندوز الثقيلة
Write-Host "[5/5] جاري إيقاف بعض خدمات الويندوز الثقيلة غير الضرورية (مثل تتبع الأخطاء والبحث)..." -ForegroundColor Yellow
Stop-Service -Name "DiagTrack" -Force -ErrorAction SilentlyContinue
Set-Service -Name "DiagTrack" -StartupType Disabled -ErrorAction SilentlyContinue
Stop-Service -Name "WSearch" -Force -ErrorAction SilentlyContinue # Windows Search (heavy on CPU/Disk)
Set-Service -Name "WSearch" -StartupType Disabled -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "تم الانتهاء بنجاح! جهازك الآن أخف وأسرع." -ForegroundColor Green
Write-Host "يرجى إعادة تشغيل الكمبيوتر لتطبيق جميع التغييرات." -ForegroundColor Yellow
Write-Host "==================================" -ForegroundColor Cyan
Pause
