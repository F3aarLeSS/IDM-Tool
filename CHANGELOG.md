# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [1.0.0] - 2026

### Added
- Freeze Trial feature - lock 30-day trial forever
- Reset Activation & Trial feature - fresh 30-day trial
- Download IDM option - open official download page
- Automatic architecture detection (x86/x64)
- Registry backup before any changes
- Clean terminal UI with box-drawing characters
- PowerShell CLSID scanner for key detection
- Admin privilege check
- Error handling for common issues

### Technical
- Batch script with embedded PowerShell
- Registry operations for IDM trial management
- CLSID key locking via permission manipulation
- Test download triggering for registry key creation
