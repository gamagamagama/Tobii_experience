# ============================================================
# Tobii Eye Tracking Portal - Diagnostics and Registration
# ============================================================

$ErrorActionPreference = "Continue"

Write-Host "`n=== 1. Start Microsoft Store Licensing Service ===" -ForegroundColor Cyan
try {
    Start-Service -Name ClipSVC -ErrorAction Stop
    Write-Host "ClipSVC started successfully." -ForegroundColor Green
}
catch {
    Write-Warning "Could not start ClipSVC: $($_.Exception.Message)"
}

Write-Host "`n=== 2. Tobii packages registered for all users ===" -ForegroundColor Cyan
Get-AppxPackage -AllUsers |
    Where-Object { $_.Name -like '*Tobii*' } |
    Format-List Name, Version, PackageFullName, PackageFamilyName,
                InstallLocation, Status, PackageUserInformation

Write-Host "`n=== 3. Tobii packages registered for current user ===" -ForegroundColor Cyan
Get-AppxPackage |
    Where-Object { $_.Name -like '*Tobii*' } |
    Format-List Name, Version, PackageFullName, PackageFamilyName,
                InstallLocation, Status

Write-Host "`n=== 4. Current Windows account ===" -ForegroundColor Cyan
whoami
whoami /user

Write-Host "`n=== 5. Detect Tobii hardware and device status ===" -ForegroundColor Cyan

$tobiiDevices = Get-PnpDevice -ErrorAction SilentlyContinue |
    Where-Object {
        $_.FriendlyName -match 'Tobii|EyeChip' -or
        $_.InstanceId -match 'Tobii|EyeChip'
    }

if ($tobiiDevices) {
    $tobiiDevices |
        Sort-Object -Property @{Expression='Present'; Descending=$true}, Class, FriendlyName |
        Format-Table Status, Class, FriendlyName, Present, InstanceId -AutoSize -Wrap

    $presentDevices = @($tobiiDevices | Where-Object { $_.Present -eq $true })
    $problemDevices = @($presentDevices | Where-Object { $_.Status -ne 'OK' })

    Write-Host "`nTobii hardware summary:" -ForegroundColor Cyan
    Write-Host "Tobii devices found: $($tobiiDevices.Count)"
    Write-Host "Currently present: $($presentDevices.Count)"
    Write-Host "Present devices with non-OK status: $($problemDevices.Count)"

    if ($presentDevices.Count -gt 0 -and $problemDevices.Count -eq 0) {
        Write-Host "Windows detects the present Tobii devices, and they report OK status." -ForegroundColor Green
    }
    elseif ($problemDevices.Count -gt 0) {
        Write-Warning "One or more present Tobii devices report a non-OK status."
    }
    else {
        Write-Warning "No currently present Tobii devices were detected."
    }
}
else {
    Write-Warning "No Tobii devices were found by Get-PnpDevice."
}

Write-Host "`n=== 6. Tobii driver packages in Driver Store ===" -ForegroundColor Cyan

$tobiiDrivers = Get-WindowsDriver -Online -All -ErrorAction SilentlyContinue |
    Where-Object { $_.ProviderName -match 'Tobii' }

if ($tobiiDrivers) {
    $tobiiDrivers |
        Format-Table Driver, OriginalFileName, ProviderName,
                     ClassName, Date, Version -AutoSize -Wrap

    Write-Host "Tobii driver packages found: $($tobiiDrivers.Count)" -ForegroundColor Green
}
else {
    Write-Warning "No Tobii driver packages were returned. Run this script as Administrator."
}

Write-Host "`n=== 7. Attempt to register Tobii Eye Tracking Portal ===" -ForegroundColor Cyan

$packages = Get-AppxPackage -AllUsers -Name TobiiAB.TobiiEyeTrackingPortal

if ($packages) {
    foreach ($package in $packages) {
        $manifest = Join-Path $package.InstallLocation "AppxManifest.xml"

        if (Test-Path $manifest) {
            try {
                Add-AppxPackage -DisableDevelopmentMode -Register $manifest -ErrorAction Stop
                Write-Host "Registration command completed for: $($package.PackageFullName)" -ForegroundColor Green
            }
            catch {
                Write-Warning "Registration failed: $($_.Exception.Message)"
            }
        }
        else {
            Write-Warning "Manifest not found: $manifest"
        }
    }
}
else {
    Write-Warning "Tobii Eye Tracking Portal package was not found for any user."
}

Write-Host "`n=== 8. Final current-user Tobii package check ===" -ForegroundColor Cyan
Get-AppxPackage |
    Where-Object { $_.Name -like '*Tobii*' } |
    Format-List Name, Version, PackageFullName, PackageFamilyName, Status

Write-Host "`n=== Diagnostics finished ===" -ForegroundColor Green
