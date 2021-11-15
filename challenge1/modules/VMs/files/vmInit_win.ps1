Set-ExecutionPolicy Bypass -Scope Process -Force;

# =========================
# PARAMETERS
# =========================

Param(
    [Parameter(Mandatory=$True)]
    [String] $devopsToken,
    [Parameter(Mandatory=$True)]
    [String] $agentPool
)

# =========================
# FUNCTIONS
# =========================

Function Add-PathVariable {
    param (
        [string]$addPath
    )
    if (Test-Path $addPath){
        $regexAddPath = [regex]::Escape($addPath)
        $arrPath = $env:Path -split ';' | Where-Object {$_ -notMatch "^$regexAddPath\\?"}
        $env:Path = ($arrPath + $addPath) -join ';'
    } else {
        Throw "'$addPath' is not a valid path."
    }
}
Disable-ieESC

# =========================
# INSTALL CHOCOLATEY
# =========================

Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'));

# =========================
# INSTALL STANDARD SOFTWARE
# =========================

choco install notepadplusplus -y
choco install googlechrome -y
choco install openssh --params "/SSHServerFeature" -y

# =========================
# INSTALL DEVOPS SOFTWARE
# =========================

choco install git -y
choco install terraform -y
choco install nodejs -y
choco install vscode -y
choco install kubernetes-helm -y
choco install ssms -y
choco install microsoftazurestorageexplorer -y
choco install azure-cli -y
choco install kubernetes-cli -y
choco install vscode-kubernetes-tools -y

Add-PathVariable('C:\ProgramData\chocolatey\lib\kubernetes-cli\tools\kubernetes\client\bin')

If(-not(Get-InstalledModule DockerMsftProvider -ErrorAction silentlycontinue))
{
    Install-PackageProvider -Name 'nuget' -Force
    Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted
    Install-Module DockerMsftProvider -Confirm:$False -Force
}

# =========================
# INSTALL AZURE PACKAGES
# =========================

Install-Module AzureRM -AllowClobber
Install-Module -Name Az

#Download AzCopy
Invoke-WebRequest -Uri "https://aka.ms/downloadazcopy-v10-windows" -OutFile AzCopy.zip -UseBasicParsing

#Curl.exe option (Windows 10 Spring 2018 Update (or later))
curl.exe -L -o AzCopy.zip https://aka.ms/downloadazcopy-v10-windows

#Expand Archive
Expand-Archive ./AzCopy.zip ./AzCopy -Force

#Move AzCopy to the destination you want to store it
Get-ChildItem ./AzCopy/*/azcopy.exe | Move-Item -Destination "C:\Program Files (x86)\Microsoft SDKs\Azure\Azcopy\AzCopy.exe"

#Add your AzCopy path to the Windows environment PATH
$userenv = [System.Environment]::GetEnvironmentVariable("Path", "User")
[System.Environment]::SetEnvironmentVariable("PATH", $userenv + ";C:\Program Files (x86)\Microsoft SDKs\Azure\Azcopy", "User")

# =========================
# INSTALL KUBERNETES DASHBOARD
# =========================

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml

# =========================
# INSTALL DEVOPS SERVICES
# =========================

choco install azure-pipelines-agent --params "'/Directory:c:\azAgent1 /Token:$devopsToken /Pool:$agentPool /Url:https://aldinternational.visualstudio.com/'" -y
choco install azure-pipelines-agent --params "'/Directory:c:\azAgent2 /Token:$devopsToken /Pool:$agentPool /Url:https://aldinternational.visualstudio.com/'" -y
Install-Package -Name docker -ProviderName DockerMsftProvider -Force

# =========================
# TURN OFF IE ENHANCED SECURITY
# =========================

{
    $AdminKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}”
    Set-ItemProperty -Path $AdminKey -Name “IsInstalled” -Value 0
    $UserKey = “HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}”
    Set-ItemProperty -Path $UserKey -Name “IsInstalled” -Value 0
    Stop-Process -Name Explorer
    Write-Host “IE Enhanced Security Configuration (ESC) has been disabled.” -ForegroundColor Green
}

# =========================
# RESTART VM
# =========================

Write-Host “Restarting Virtual Machine” -ForegroundColor Red
Restart-Computer -Force