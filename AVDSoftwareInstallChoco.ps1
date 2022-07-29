#Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#Assign Packages to Install
$Packages = 'googlechrome',`
            'vscode',`
            'git',`
            'corretto8jdk',`
            'jabber',`
            'citrix-receiver',`
            'putty',`
            '7zip',`
            'notepadplusplus',`
            'adobereader'
#Install Packages
ForEach ($PackageName in $Packages)
{choco install $PackageName -y}