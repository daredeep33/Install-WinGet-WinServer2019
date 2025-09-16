# Install-Winget PowerShell Script

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)  ![License](https://img.shields.io/badge/License-MIT-yellow.svg)

A robust and reliable PowerShell script to install the Windows Package Manager (`winget`) on systems where it is not available by default, such as Windows Server 2019/2022 and earlier versions of Windows 10.

This script automates the entire process, from fetching the latest version to handling dependencies, ensuring a seamless and error-free installation.

## Why Use This Script?

Manually installing `winget` can be a multi-step process that involves finding the correct files and dependencies. Older scripts often use outdated, hardcoded links or rely on fragile third-party services that break over time.

This script solves these problems by providing:

-   ✅ **Always Up-to-Date**: Automatically queries the official GitHub API to download the **latest** version of `winget` and its dependencies. No more outdated links.
-   ✅ **Self-Contained and Reliable**: Uses only built-in PowerShell commands and communicates directly with the official Microsoft GitHub repository.
-   ✅ **Robust Error Handling**: Includes checks for common issues, such as pre-existing dependencies or a lack of administrator privileges.
-   ✅ **Idempotent**: The script can be run multiple times on the same system without causing errors. If `winget` is already installed, it will notify you and exit gracefully.
-   ✅ **Automatic Cleanup**: Creates a temporary folder for downloads and removes it upon completion.
-   ✅ **Administrator Check**: Halts execution immediately if not run in an elevated PowerShell session.

## Prerequisites

-   **Operating System**: Windows Server 2019, Windows Server 2022, Windows 10 (v1809+), or Windows 11.
-   **PowerShell**: Version 5.1 or later.
-   **Execution Policy**: The ability to run local scripts.
-   **Internet Connection**: Required to download files from the GitHub API.

## Usage

You can run this script in two primary ways: remotely (recommended for ease of use) or locally.

---

### Method 1: Quick Remote Execution (Recommended)

This is the fastest way to install `winget`. It downloads and runs the script in a single command without saving the file locally.

1.  Open **PowerShell as an Administrator**.
2.  Copy and run the following command. This command temporarily bypasses the execution policy for the current session, downloads the script, and executes it.

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://github.com/daredeep33/Install-WinGet-WinServer2019/blob/main/InstallWinget_WINSERV2019.ps1'))
```

---

### Method 2: Local Execution

Use this method if you prefer to download the script first before running it.

1.  **Download the Script**: Download the `Install-Winget.ps1` file from this repository.
2.  **Unblock the File**: Right-click the downloaded file, go to **Properties**, and check the **Unblock** box at the bottom. This is a security feature in Windows.
    Alternatively, you can unblock it via PowerShell:
    ```powershell
    Unblock-File -Path "C:\path\to\Install-Winget.ps1"
    ```
3.  **Run the Script**:
    -   Open **PowerShell as an Administrator**.
    -   Navigate to the directory where you saved the file.
        ```powershell
        cd "C:\path\to"
        ```
    -   Execute the script.
        ```powershell
        .\Install-Winget.ps1
        ```

## Troubleshooting

The most common issue when running PowerShell scripts is the **Execution Policy**. The remote execution command (`Method 1`) is designed to handle this automatically for the current session.

If you encounter an error running the script locally that says "script execution is disabled on this system," you may need to set your execution policy. You can do this by running the following command in an administrative PowerShell window:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
```Then, confirm the change by typing `Y` and pressing Enter.
