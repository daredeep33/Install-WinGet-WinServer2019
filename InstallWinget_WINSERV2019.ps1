<#
.SYNOPSIS
    Installs or updates the Windows Package Manager (winget) on Windows Server 2019/2022 or Windows 10/11.
.DESCRIPTION
    This script provides a reliable and automated method for installing the latest version of the winget CLI.
    It automatically fetches the latest release from the official Microsoft GitHub repository, downloads the
    necessary dependencies, and installs them.
    The script is idempotent, meaning it can be run multiple times without causing issues. It checks for an
    existing winget installation and checks if dependencies are already met.
.NOTES
    Author: Inspired by community scripts, improved for reliability.
    Version: 2.0
    Requirements: PowerShell 5.1 or higher. Must be run as Administrator.
#>

[CmdletBinding()]
param()

# --- PRE-FLIGHT CHECKS ---
Write-Host "Starting Winget installation script..." -ForegroundColor Cyan

# 1. Administrator Check
if (-NOT ([System.Security.Principal.WindowsPrincipal][System.Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run with Administrator privileges. Please re-launch PowerShell as an Administrator."
    # Pause to allow user to see the error in interactive sessions before the window closes.
    if ($Host.Name -eq "ConsoleHost") { Start-Sleep -Seconds 5 }
    return
}

# 2. Check if Winget is already installed
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "Winget is already installed. Exiting." -ForegroundColor Green
    $wingetVersion = winget --version
    Write-Host "Current version: $wingetVersion"
    # Pause for visibility
    if ($Host.Name -eq "ConsoleHost") { Start-Sleep -Seconds 3 }
    return
}

# --- SCRIPT CONFIGURATION ---
$tempDir = Join-Path $env:TEMP "Winget-Install-Temp"
# GitHub API URL for the latest winget-cli release
$apiUrl = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"

# --- MAIN EXECUTION BLOCK ---
# Wrap main logic in a try/finally block to ensure cleanup happens
try {
    # Create a temporary directory for downloads
    if (-NOT (Test-Path $tempDir)) {
        New-Item -Path $tempDir -ItemType Directory | Out-Null
    }

    Write-Host "Fetching latest release information from GitHub..."
    $latestRelease = Invoke-RestMethod -Uri $apiUrl -UseBasicParsing

    # Find the required file URLs from the release assets
    $wingetUrl = ($latestRelease.assets | Where-Object { $_.name -like '*.msixbundle' }).browser_download_url
    $vcLibsUrl = ($latestRelease.assets | Where-Object { $_.name -like '*VCLibs*.appx' -and $_.name -like '*x64*' }).browser_download_url

    if (-not $wingetUrl -or -not $vcLibsUrl) {
        Write-Error "Could not find required download URLs in the latest GitHub release. The API response may have changed."
        return
    }

    $wingetPath = Join-Path $tempDir "winget.msixbundle"
    $vcLibsPath = Join-Path $tempDir "vclibs.appx"

    # Download files
    Write-Host "Downloading Winget package: $($wingetUrl)"
    Invoke-WebRequest -Uri $wingetUrl -OutFile $wingetPath -UseBasicParsing
    Write-Host "Downloading VCLibs dependency: $($vcLibsUrl)"
    Invoke-WebRequest -Uri $vcLibsUrl -OutFile $vcLibsPath -UseBasicParsing
    
    Write-Host "Downloads complete. Starting installation..."

    # Install the dependency package first
    try {
        Write-Host "Installing dependency: VCLibs..."
        Add-AppxPackage -Path $vcLibsPath
        Write-Host "Dependency installed successfully." -ForegroundColor Green
    }
    catch {
        # This catches the common error where a higher version is already installed, which is not a failure condition.
        if ($_.Exception.HResult -eq 0x80073D06) {
            Write-Warning "VCLibs dependency is already installed with an equal or higher version. Continuing."
        }
        else {
            # Throw the original error if it's something else
            throw $_
        }
    }

    # Install the main Winget package
    try {
        Write-Host "Installing main Winget package..."
        Add-AppxPackage -Path $wingetPath
        Write-Host "Winget installed successfully!" -ForegroundColor Green
    }
    catch {
        Write-Error "Failed to install the main Winget package. Error: $($_.Exception.Message)"
        throw $_
    }

    # Verification
    Write-Host "Verifying installation..."
    $wingetVersionCheck = winget --version
    if ($wingetVersionCheck) {
        Write-Host "Verification successful. Winget version: $wingetVersionCheck" -ForegroundColor Green
    } else {
        Write-Error "Verification failed. Winget command is still not available. Manual installation may be required."
    }

}
catch {
    Write-Error "An unexpected error occurred during the script execution. Please check the output above for details."
}
finally {
    # Clean up the temporary directory
    if (Test-Path $tempDir) {
        Write-Host "Cleaning up temporary files..."
        Remove-Item -Path $tempDir -Recurse -Force
    }
}

if ($Host.Name -eq "ConsoleHost") {
    Write-Host "Script finished. The PowerShell window will close in 5 seconds."
    Start-Sleep -Seconds 5
}
