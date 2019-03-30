<#
.SYNOPSIS
    How to create Updated OSMedia
.DESCRIPTION
    How to install and run OSBuilder to create monthly media for 2016 and 2019
.NOTES
    Andy Friar
    OSBuilder is now end of life use OSDBuilder
    Run each line manually. No F5
#>

#region Prevent F5
throw "Do not run this with F5"
#endregion

# Powershell needs to be run as Administrators
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (!( $isAdmin )) {
    Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    exit
}

#Assign Variables
$OSBuilderPath = "D:\OSDBuilder"

#Install OSBuilder and OSDeploy
Uninstall-Module -Name OSDBuilder -AllVersions -Force
Uninstall-Module -Name OSDeploy -AllVersions -Force
Install-Module -Name OSDBuilder -Force
Install-Module -Name OSDeploy -Force
Import-Module -Name OSDBuilder -Force
Import-module -Name OSDeploy -Force

#Change default path
Get-OSDBuilder -SetPath $OSBuilderPath

# Double click Media to map it to a drive letter
Import-OSMedia
# select which media you want to use

#Update Media - takes along time
Update-OSMedia -Download -Execute

#Need Windows ADK installed to be able to create ISO
Invoke-WebRequest -UseBasicParsing -Uri https://go.microsoft.com/fwlink/?linkid=2026036 -OutFile "$env:USERPROFILE\Downloads\adksetup.exe"
Start-Process -Wait -FilePath $env:USERPROFILE\Downloads\adksetup.exe -ArgumentList "/quiet /features OptionId.DeploymentTools"

#Create ISO
New-OSBMediaISO

#Create USB with split wim
#Make sure there is a fat32 formatted USB in the computer somewhere (it will ask you to choose)
$ISO = "D:\OSDBuilder\OSMedia\Windows Server 2016 Datacenter Desktop Experience x64 1607 14393.2848\ISO\Server 10.0.14393.2848.iso"
Copy-IsoToUsb -SplitWim -ISOFile $ISO

#Create VHDX
New-OSDBuilderVHD -OSDriveLabel System -VHDSizeGB 60