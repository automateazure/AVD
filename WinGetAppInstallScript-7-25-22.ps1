#Install New apps
Write-Output "Installing Applications..."
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
        #check if the app is already installed
        $listApp = winget list --exact -q --accept-source-agreements $app.id
        if (![String]::Join("", $listApp).Contains($app.id)) {
            Write-host "Installing: " $app.id
                winget install --exact --silent --accept-source-agreements --accept-package-agreements --id $app.id
            }
        else {
            Write-host "Skipping Install of " $app.id
        }
    }
    Write-Output "Task completed"