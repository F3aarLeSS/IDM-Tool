# Installation

## Quick Start

1. Download `IDM_Tool.cmd` from the [Releases](https://github.com/yourusername/IDM-Tool/releases) page
2. Right-click the file
3. Select **Run as administrator**
4. Follow the on-screen menu

## Prerequisites

- **Windows OS**: 7, 8, 8.1, 10, or 11 (or Server equivalent)
- **PowerShell**: Pre-installed on Windows 8+
- **Internet Connection**: Required for the Freeze Trial option
- **IDM**: Internet Download Manager must be installed

## Detailed Steps

### Step 1: Download

Download the latest `IDM_Tool.cmd` from GitHub:

```bash
# Using Git
git clone https://github.com/yourusername/IDM-Tool.git

# Or download directly from releases page
```

### Step 2: Run as Administrator

**Important**: The script requires administrator privileges to modify Windows registry.

1. Locate `IDM_Tool.cmd`
2. Right-click on it
3. Select **Run as administrator**
4. Click **Yes** if User Account Control (UAC) prompts

### Step 3: Choose an Option

```
[1] Freeze Trial        - Lock 30-day trial forever
[2] Reset Activation    - Get fresh 30-day trial
[3] Download IDM        - Open official download page
[0] Exit
```

## After Installation

### Freeze Trial

1. Select option `[1]`
2. Confirm with `Y`
3. Wait for the process to complete
4. Your trial is now frozen permanently

### Reset Activation

1. Select option `[2]`
2. Confirm with `Y`
3. Wait for the process to complete
4. Restart IDM for a fresh 30-day trial

## Troubleshooting

### "Run as Administrator" Error

- Right-click the script file
- Select "Run as administrator"
- If UAC prompts, click "Yes"

### IDM Not Found

- Use option `[3]` to download IDM first
- Or install IDM manually from [official website](https://www.internetdownloadmanager.com)

### Internet Connection Required

- The Freeze Trial option requires internet
- Connect to the internet before running Freeze

## Uninstallation

To remove the script:

1. Delete `IDM_Tool.cmd`
2. Registry backups are in `%SystemRoot%\Temp\` (optional cleanup)

## Support

- Check [Troubleshooting](TROUBLESHOOTING.md)
- Open an issue on GitHub
