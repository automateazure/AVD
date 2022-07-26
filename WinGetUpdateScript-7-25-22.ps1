#Upgrading Existing Applications
Write-Output "Checking for Updates..."
$apps = @(
    @{id = "Google.Chrome" },
    @{id = "Mozilla.FireFox" },   
    @{id = "Amazon.Corretto.8" }, 
    @{id = "Cisco.Jabber" },
    @{id = "Microsoft.Edge" },
    @{id = "Microsoft.EdgeWebView2Runtime" },
    @{id = "Microsoft.VisualStudioCode" },
    @{id = "Notepad++.Notepad++" },
    @{id = "Citrix.Workspace" },
    @{id = "Microsoft.PowerBI" },
    @{id = "Git.Git" },
    @{id = "Adobe.Acrobat.Reader.64-bit" }
    );
    Foreach ($app in $apps) {
            Write-host "Upgrading: " $app.id
                winget upgrade --exact --silent --accept-source-agreements --accept-package-agreements --id $app.id
            }
            Write-host "Task completed"