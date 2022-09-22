#Assign Packages to Install/Upgrade
$Packages = 'googlechrome',`
            'vscode',`
            'firefox',`
            'corretto8jdk',`
            'jabber',`
            'citrix-receiver',`
            'putty',`
            '7zip',`
            'notepadplusplus',`
            'git',`
            'powershell',`
            'azure-cli',`
            'vmware-horizon-client',`
            'docker-desktop',''

#Install Packages
ForEach ($PackageName in $Packages)
{choco upgrade $PackageName -y}