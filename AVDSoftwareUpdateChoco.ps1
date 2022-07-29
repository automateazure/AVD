#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Assign Packages to Upgrade
$Packages = 'googlechrome',`
            'vscode',`
            'firefox',`
            'corretto8jdk',`
            'jabber',`
            'microsoft-edge',`
            'citrix-receiver',`
            'powerbi',`
            'putty',`
            '7zip',`
            'notepadplusplus',`
            'onedrive',`
            'adobereader'

#Update Packages
ForEach ($PackageName in $Packages)
{choco upgrade $PackageName -y}