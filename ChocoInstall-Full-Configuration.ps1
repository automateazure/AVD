#Install Chocolatey
#Open Powershell as an administrator. Ensure that Get-ExecutionPolicy is not restricted.
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))


#Configure Source for ChocolateY
choco sources add --name=ITOPs-WVD-Patching --source=https://pkgs.dev.azure.com/EnsembleHealth/EHIF-ITOps/_packaging/ITOps-WVD-Patching/nuget/v2 --user=brian.brito@ensemblehp.com --password=REPLACE_WITH_PERSONAL_ACCESS_TOKEN


#Remove Chocolatey Community Repository 
choco source remove -n chocolatey


#Run Initial Chocolatey App Install Script
Set-Location -Path "C:\Users\Ehpadmin\Desktop"
   .\EHP-Chocolatey-AppInstall.ps1


#Check for outdated chocolatey Packages
choco outdated


#Upgrade all available Chocolatey Packages
choco upgrade all -y