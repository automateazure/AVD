<#
    .AUTHOR
    Brian Brito
    
    .SYNOPSIS
    Executes a scriptblock in parallel against all VMs in the specified resource group using InvokeAzVMRunCommand
    
    .DESCRIPTION
    Patch Office 365 & 3rd Party Apps
    
#>

    # Start powershell logging
$SaveVerbosePreference = $VerbosePreference
$VerbosePreference = 'continue'
$VMTime = Get-Date
$LogTime = $VMTime.ToUniversalTime()
mkdir "C:\Windows\temp\AzAutomation\EHP-ITOPS-AUTOMATION\Runbooks\WVDImagePatching" -Force
Start-Transcript -Path "C:\Windows\temp\AzAutomation\EHP-ITOPS-AUTOMATION\Runbooks\WVDImagePatching\ps_log.txt" -Append
Write-Host "################# New Script Run #################"
Write-host "Current time (UTC-0): $LogTime"
        
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

#Install WinGet
#Based on this gist: https://gist.github.com/crutkas/6c2096eae387e544bd05cde246f23901

#WebClient
$dc = New-Object net.webclient
$dc.UseDefaultCredentials = $true
$dc.Headers.Add("user-agent", "Inter Explorer")
$dc.Headers.Add("X-FORMS_BASED_AUTH_ACCEPTED", "f")

#temp folder
$InstallerFolder = $(Join-Path $env:ProgramData CustomScripts)
if (!(Test-Path $InstallerFolder))
{
New-Item -Path $InstallerFolder -ItemType Directory -Force -Confirm:$false
}
	#Check Winget Install
	Write-Host "Checking if Winget is installed" -ForegroundColor Yellow
	$TestWinget = Get-AppxProvisionedPackage -Online | Where-Object {$_.DisplayName -eq "Microsoft.DesktopAppInstaller"}
	If ([Version]$TestWinGet. Version -gt "2022.506.16.0") 
	{
		Write-Host "WinGet is Installed" -ForegroundColor Green
	}Else 
		{
		#Download WinGet MSIXBundle
		Write-Host "Not installed. Downloading WinGet..." 
		$WinGetURL = "https://aka.ms/getwinget"
		$dc.DownloadFile($WinGetURL, "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
		
		#Install WinGet MSIXBundle 
		Try 	{
			Write-Host "Installing MSIXBundle for App Installer..." 
			Add-AppxProvisionedPackage -Online -PackagePath "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -SkipLicense 
			Write-Host "Installed MSIXBundle for App Installer" -ForegroundColor Green
			}
		Catch {
			Write-Host "Failed to install MSIXBundle for App Installer..." -ForegroundColor Red
			} 
	
		#Remove WinGet MSIXBundle 
		#Remove-Item -Path "$InstallerFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle" -Force -ErrorAction Continue
		}

#Configure WinGet
Write-Output "Configuring WinGet Settings..."


#winget config path from: https://github.com/microsoft/winget-cli/blob/master/doc/Settings.md#file-location
#For documentation on these settings, see: https://aka.ms/winget-settings
$settingsPath = "$env:LOCALAPPDATA\Packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe\LocalState\settings.json";
$settingsJson = 
@"
   {   
        "logging": {
            "level": "verbose"   
        },
        
        "visual": {
            "progressBar": "accent"
        },

        "source": {
            "autoUpdateIntervalInMinutes": 3
        },

        "installBehavior": {
            "preferences": {
                "scope": "machine"
            }
        },
    }
"@;
$settingsJson | Out-File $settingsPath -Encoding utf8
Start-Sleep -s 1.5
Write-Output "Finished."

#Application Patching Process Begins
#Based on this gist: https://gist.github.com/alkampfergit/2f662c07df0ca379c8e8e65e588c687b

class Software {
    [string]$Name
    [string]$Id
    [string]$Version
    [string]$AvailableVersion
}

# Change directory to the Microsoft.DesktopAppInstaller msixbundle
$ResolveWingetPath = Resolve-Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe\winget.exe"
    if ($ResolveWingetPath){
           $WingetPath = $ResolveWingetPath[-1].Path
    }

$Wingetpath = Split-Path -Path $WingetPath -Parent
Set-Location $wingetpath


# Create $upgradeResult variable that references "winget upgrade" to list available software updates
$upgradeResult = .\winget.exe upgrade --accept-source-agreements | Out-String

$lines = $upgradeResult.Split([Environment]::NewLine)


# Find the line that starts with Name, it contains the header
$fl = 0
while (-not $lines[$fl].StartsWith("Name"))
{
    $fl++
}

# Line $i has the header, we can find char where we find ID and Version
$idStart = $lines[$fl].IndexOf("Id")
$versionStart = $lines[$fl].IndexOf("Version")
$availableStart = $lines[$fl].IndexOf("Available")
$sourceStart = $lines[$fl].IndexOf("Source")

# Now cycle in real package and split accordingly
$upgradeList = @()
For ($i = $fl + 1; $i -le $lines.Length; $i++) 
{
    $line = $lines[$i]
    if ($line.Length -gt ($availableStart + 1) -and -not $line.StartsWith('-'))
    {
        $name = $line.Substring(0, $idStart).TrimEnd()
        $id = $line.Substring($idStart, $versionStart - $idStart).TrimEnd()
        $version = $line.Substring($versionStart, $availableStart - $versionStart).TrimEnd()
        $available = $line.Substring($availableStart, $sourceStart - $availableStart).TrimEnd()
        $software = [Software]::new()
        $software.Name = $name;
        $software.Id = $id;
        $software.Version = $version
        $software.AvailableVersion = $available;

        $upgradeList += $software
    }

}

# List available software updates
$upgradeList | Format-Table

# List of packages to skip
$toSkip = @(
'VMware.HorizonClient',
'RProject.Rtools',
'RStudio.RStudio.OpenSource',
'RStudio.RStudio.Professional',
'Microsoft.WindowsVirtualDesktopBootloader',
'Microsoft.VC++2013Redist-x64',
"Microsoft.VC++2013Redist-x86",
"Microsoft.VC++2015-2019Redist-x64",
"Microsoft.VC++2015-2019Redist-x86",
'Microsoft.VisualStudio.2017.BuildTools',
'Microsoft.VisualStudio.2019.BuildTools'
'Microsoft.VisualStudio.2019.Professional',
'Microsoft.VisualStudio.2019.Enterprise',
'Microsoft.VisualStudio.2022.Enterprise',
'Microsoft.VisualStudio.2022.Professional',
'Microsoft.VisualStudio.2017.Professional',
'Microsoft.Office',
"Microsoft.Teams")

# WinGet upgrades available packages not mentioned in $toSkip variable
foreach ($package in $upgradeList) 
{
    if (-not ($toSkip -contains $package.Id)) 
    {
        Write-Host "Going to upgrade package $($package.id)"
        & .\winget.exe upgrade --exact --silent --accept-source-agreements --accept-package-agreements $package.id
    }
    else 
    {    
        Write-Host "Skipped upgrade to package $($package.id)"
    }
}
    
Get-AppxPackage -AllUsers *Microsoft.Winget.Source* | Remove-AppxPackage -AllUsers 


# End Logging
Stop-Transcript
$VerbosePreference=$SaveVerbosePreference