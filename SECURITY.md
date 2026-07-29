# Security Policy

## Reporting Vulnerabilities

If you discover a security vulnerability, please report it responsibly:

- **Do NOT** open a public GitHub issue
- Email: [Your email here]
- Describe the vulnerability
- Include steps to reproduce

## Security Considerations

This script requires administrator privileges to modify Windows registry keys. Please:

1. **Run only from trusted sources** - Download only from official GitHub releases
2. **Review the code** - The script is open source; review it before running
3. **Backup your registry** - The script creates backups, but verify they exist
4. **Use in isolated environments** - Consider testing in a VM first

## What This Script Does

- Modifies Windows registry keys (with backups)
- Terminates IDM process
- Uses PowerShell for registry operations

## Safe Practices

- Always run from a trusted source
- Verify the script matches the official repository
- Check registry backups before and after running
- Use Windows System Restore as an additional backup
