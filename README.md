# IDM Tool

A Windows batch script to manage Internet Download Manager (IDM) trial period. Freeze your 30-day trial forever or reset it for a fresh start.

## Features

- **Freeze Trial** - Lock the 30-day trial period permanently so it never expires
- **Reset Activation & Trial** - Clear all data for a fresh 30-day trial
- **Download IDM** - Open the official IDM download page

## How It Works

IDM stores trial and activation data in Windows registry keys. This script:

1. Identifies IDM-specific CLSID registry keys
2. Locks (freeze) or deletes (reset) those keys
3. IDM cannot track trial expiration when keys are locked

## Requirements

- Windows 7/8/8.1/10/11 (or Server equivalent)
- PowerShell (pre-installed on Windows 8+)
- Internet connection (for Freeze option)
- Administrator privileges

## Usage

1. Download `IDM_Tool.cmd`
2. Right-click the file
3. Select **Run as administrator**
4. Choose an option from the menu

## Important Notes

- **Freeze Trial**: Requires internet to trigger test downloads that create registry keys. IDM updates can be installed directly after freezing.
- **Reset**: Gives you a fresh 30-day trial. Run this if IDM shows fake serial key errors or activation nag screens.
- **Backups**: Registry backups are saved to `%SystemRoot%\Temp\` before any changes.

## Menu Options

```
[1] Freeze Trial        - Lock 30-day trial forever
[2] Reset Activation    - Get fresh 30-day trial
[3] Download IDM        - Open official download page
[0] Exit
```

## Architecture Support

The script automatically detects your system architecture (x86/x64) and uses the correct registry paths.

## Troubleshooting

- **"Run as Administrator" error**: Right-click the script and select "Run as administrator"
- **IDM not found**: Use option [3] to download IDM first
- **Freeze not working**: Ensure you have internet connection, then try again
- **Fake serial error**: Run Reset (option [2]), then Freeze (option [1]) again

## Disclaimer

This script is for educational purposes. Use at your own risk. Always backup your registry before making changes.

## License

MIT License - See [LICENSE](LICENSE) for details.
