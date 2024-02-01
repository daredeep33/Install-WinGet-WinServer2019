# Define variables
$WinGetFolder = "C:\WinGet"
$VCLibsUri = "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx"
$MicrosoftUIXamlUri = "https://www.nuget.org/api/v2/package/Microsoft.UI.Xaml/2.7.3"
$WinGetUri = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# Function to install AppX package
function Install-AppxPackage {
    param (
        [string]$PackagePath
    )
    Add-AppxPackage -Path $PackagePath
}

# Create WinGet Folder
New-Item -Path $WinGetFolder -ItemType Directory -ErrorAction SilentlyContinue

# Install VCLibs
Invoke-WebRequest -Uri $VCLibsUri -OutFile "$WinGetFolder\Microsoft.VCLibs.x64.14.00.Desktop.appx"
Install-AppxPackage -PackagePath "$WinGetFolder\Microsoft.VCLibs.x64.14.00.Desktop.appx"

# Install Microsoft.UI.Xaml from NuGet
Invoke-WebRequest -Uri $MicrosoftUIXamlUri -OutFile "$WinGetFolder\Microsoft.UI.Xaml.2.7.3.zip"
Expand-Archive -Path "$WinGetFolder\Microsoft.UI.Xaml.2.7.3.zip" -DestinationPath "$WinGetFolder\Microsoft.UI.Xaml.2.7.3"
Install-AppxPackage -PackagePath "$WinGetFolder\Microsoft.UI.Xaml.2.7.3\tools\AppX\x64\Release\Microsoft.UI.Xaml.2.7.appx"

# Install latest WinGet from GitHub
Invoke-WebRequest -Uri $WinGetUri -OutFile "$WinGetFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
Install-AppxPackage -PackagePath "$WinGetFolder\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"

# Fix Permissions
Take-Ownership -Path "C:\Program Files\WindowsApps" -Recurse
Grant-Permission -Path "C:\Program Files\WindowsApps" -Permission Administrators:F -Recurse

# Add Environment Path
$WingetPath = Get-ChildItem -Path "C:\Program Files\WindowsApps\Microsoft.DesktopAppInstaller_*_x64__8wekyb3d8bbwe" | Select-Object -Last 1 -ExpandProperty FullName
$env:PATH += ";$WingetPath"
[System.Environment]::SetEnvironmentVariable('PATH', "$env:PATH", [System.EnvironmentVariableTarget]::Machine)
