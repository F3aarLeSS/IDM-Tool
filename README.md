# IDM Tool

<p align="center">
  <strong>Windows Utility for IDM Trial & Activation Management</strong>
</p>

<p align="center">
  A lightweight PowerShell-based utility for managing Internet Download Manager trial and activation data on Windows.
</p>

<p align="center">

![Windows](https://img.shields.io/badge/Windows-7%2B-0078D6?style=for-the-badge\&logo=windows\&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge\&logo=powershell\&logoColor=white)
![Architecture](https://img.shields.io/badge/Architecture-x86%20%7C%20x64-6C63FF?style=for-the-badge)
![License](https://img.shields.io/github/license/NavajyotiBayan/IDM-Tool?style=for-the-badge)

</p>

---

## ✨ Overview

**IDM Tool** is a lightweight Windows utility designed to manage Internet Download Manager (IDM) trial and activation-related registry data.

It provides a simple menu-driven interface for performing common IDM maintenance operations without manually navigating through Windows Registry Editor.

> **Designed for Windows • Lightweight • No installation required**

---

## 🚀 Features

| Feature                        | Description                                       |
| ------------------------------ | ------------------------------------------------- |
| 🔒 **Freeze Trial**            | Lock IDM trial-related registry data              |
| ♻️ **Reset Activation**        | Remove IDM trial/activation-related data          |
| ⬇️ **Download IDM**            | Open the official IDM download page               |
| 💾 **Registry Backup**         | Creates backups before modifying registry data    |
| 🖥️ **Architecture Detection** | Automatically detects x86/x64 Windows             |
| ⚡ **Lightweight**              | Runs directly from PowerShell or CMD              |
| 🛡️ **Administrator Check**    | Detects whether elevated privileges are available |

---

## 🧩 How It Works

IDM stores information related to its trial and activation state in Windows Registry locations.

IDM Tool performs the following high-level operations:

```text
┌──────────────────────┐
│     Start IDM Tool   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Check Administrator  │
│     Privileges       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Detect Windows       │
│ Architecture         │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Detect IDM Registry  │
│       Data           │
└──────────┬───────────┘
           │
      ┌────┴─────┐
      ▼          ▼
   Freeze       Reset
      │          │
      ▼          ▼
   Lock Data   Remove Data
      │          │
      └────┬─────┘
           ▼
┌──────────────────────┐
│        Done          │
└──────────────────────┘
```

Before registry modifications, the tool creates a backup so the affected data can be restored if necessary.

---

## 🖥️ Menu

```text
╔══════════════════════════════════════╗
║              IDM TOOL                ║
╠══════════════════════════════════════╣
║                                      ║
║  [1]  Freeze Trial                   ║
║  [2]  Reset Activation & Trial       ║
║  [3]  Download IDM                   ║
║  [0]  Exit                           ║
║                                      ║
╚══════════════════════════════════════╝
```

---

## 📋 Requirements

### Operating System

* Windows 7
* Windows 8 / 8.1
* Windows 10
* Windows 11
* Compatible Windows Server editions

### Runtime

* PowerShell **5.1 or newer**
* Administrator privileges
* Internet connection where required by the selected operation

> PowerShell 5.1 is included with supported Windows installations.

---

## 📦 Installation

### Option 1 — PowerShell

Run the PowerShell script from an **Administrator PowerShell** session.

```powershell
.\IDM_Tool.ps1
```

### Option 2 — CMD

Run:

```cmd
IDM_Tool.cmd
```

Run the command shell as **Administrator** when required.

### Option 3 — Clone the Repository

```bash
git clone https://github.com/NavajyotiBayan/IDM-Tool.git
cd IDM-Tool
```

Then launch the desired version:

```powershell
.\IDM_Tool.ps1
```

or:

```cmd
IDM_Tool.cmd
```

---

## 🔧 Operations

### 🔒 Freeze Trial

Locks the relevant IDM registry data used by the tool.

Use this operation when you want to preserve the current IDM trial state.

### ♻️ Reset Activation & Trial

Removes the IDM-related registry data managed by the utility.

A registry backup is created before changes are made.

### ⬇️ Download IDM

Opens the official IDM download page so IDM can be downloaded directly from the publisher.

---

## 💾 Registry Backups

Registry backups are created before modifications.

Default backup location:

```text
%SystemRoot%\Temp\
```

This provides a safety layer before registry data is changed.

> **Important:** Do not manually delete registry data unless you understand exactly what is being modified.

---

## 🖥️ Architecture Support

IDM Tool automatically detects the Windows architecture and selects the appropriate registry paths.

```text
Windows
   │
   ├── x86  → 32-bit registry paths
   │
   └── x64  → 64-bit registry paths
```

No manual architecture configuration is required.

---

## 🛠️ Troubleshooting

### ❌ Administrator privileges required

Run PowerShell, CMD, or the script using **Run as administrator**.

### ❌ IDM is not detected

Install IDM first and then run the utility again.

### ❌ Freeze operation does not work

Make sure IDM is installed correctly and that the required network connection is available.

### ❌ IDM displays an activation or serial-related message

Use the **Reset Activation & Trial** operation and then restart IDM.

---

## 📁 Project Structure

```text
IDM-Tool/
│
├── IDM_Tool.ps1        # Main PowerShell implementation
├── IDM_Tool.cmd        # CMD launcher / alternative interface
│
├── docs/               # Project documentation
│
├── CHANGELOG.md        # Version history
├── CONTRIBUTING.md     # Contribution guidelines
├── SECURITY.md         # Security policy
├── LICENSE             # MIT License
└── README.md           # Project documentation
```

---

## 🧰 Technology

```text
PowerShell 5.1+
        │
        ├── Windows Registry
        ├── Windows Architecture Detection
        ├── Administrative Privileges
        └── IDM Integration
```

The project is intentionally lightweight and does not require a third-party runtime.

---

## 🔐 Security & Safety

This utility modifies Windows Registry data.

Before using it:

* Create a system restore point if appropriate.
* Keep registry backups.
* Run scripts only from a source you trust.
* Review the source code before executing downloaded scripts.
* Do not modify unrelated registry keys.

For security-related concerns, see `SECURITY.md`.

---

## ⚠️ Important Disclaimer

IDM Tool is provided **as-is** for educational and system-administration purposes.

Modifying application activation or trial-related data may conflict with the software publisher's license or terms of service. Users are responsible for complying with the applicable IDM license and terms.

The author is not responsible for data loss, system instability, application problems, or other consequences resulting from use of this software.

**Always maintain a backup before modifying the Windows Registry.**

---

## 📜 License

This project is released under the **MIT License**.

See [`LICENSE`](LICENSE) for the complete license text.

---

## 🤝 Contributing

Contributions, bug reports, documentation improvements, and suggestions are welcome.

Before contributing, please read:

* [`CONTRIBUTING.md`](CONTRIBUTING.md)
* [`SECURITY.md`](SECURITY.md)
* [`CHANGELOG.md`](CHANGELOG.md)

---

## ⭐ Support the Project

If this project is useful to you:

⭐ **Star the repository**

🐛 **Report bugs**

💡 **Suggest improvements**

🔧 **Contribute code**

---

<p align="center">

<strong>IDM Tool</strong><br>
Lightweight Windows Registry Utility

<br><br>

Made for Windows users who prefer simple, transparent tools.

</p>
