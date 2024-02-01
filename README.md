# InstallWinget for Windows Server 2019

This PowerShell script automates the installation process for [WinGet](https://github.com/microsoft/winget-cli) and its dependencies on a Windows Server 2019 system.

## Usage

1. Clone or download this repository to your local machine.
2. Open PowerShell as an administrator.
3. Navigate to the directory where the script is located.
4. Run the script using the following command:

    ```powershell
    .\InstallWinget_WINSERV2019.ps1
    ```

## Script Overview

The script performs the following tasks:

- Creates the WinGet folder if it doesn't exist.
- Installs VCLibs, Microsoft.UI.Xaml, and the latest WinGet from GitHub.
- Fixes permissions for the WindowsApps folder.
- Adds the WinGet installation path to the system's PATH environment variable.

## Prerequisites

- PowerShell
- Administrator privileges are required to run the script.

## Notes

- This script is specifically designed for Windows Server 2019.
- Ensure that execution policy allows running PowerShell scripts. You can set it using:

    ```powershell
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
    ```

## License

This project is licensed under the MIT License.
