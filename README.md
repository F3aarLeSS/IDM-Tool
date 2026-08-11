# IDM Tool

<p align="center">
  <strong>Windows Utility for IDM Trial & Activation Management</strong><br>
  Lightweight PowerShell & CMD tool for managing IDM trial-related registry data.
</p>

<p align="center">

![Windows](https://img.shields.io/badge/Windows-7%2B-0078D6?style=for-the-badge\&logo=windows\&logoColor=white)
![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?style=for-the-badge\&logo=powershell\&logoColor=white)
![License](https://img.shields.io/github/license/NavajyotiBayan/IDM-Tool?style=for-the-badge)

</p>

---

## ✨ Features

* 🔒 **Freeze Trial** — Lock IDM trial-related registry data
* ♻️ **Reset Activation & Trial** — Remove managed IDM trial/activation data
* ⬇️ **Download IDM** — Open the official IDM download page
* 💾 **Registry Backup** — Backup before registry modifications
* 🖥️ **Auto Architecture Detection** — Supports x86 & x64 Windows
* ⚡ **Lightweight** — No installation required

---

## 🚀 Quick Start

### PowerShell IEX — Recommended

Open **PowerShell as Administrator** and run:

```powershell
iex (irm https://raw.githubusercontent.com/NavajyotiBayan/IDM-Tool/main/IDM_Tool.ps1)
```

### Download / Clone

```bash
git clone https://github.com/NavajyotiBayan/IDM-Tool.git
cd IDM-Tool
```

Run as Administrator:

```powershell
.\IDM_Tool.ps1
```

or:

```cmd
IDM_Tool.cmd
```

---

## 🖥️ Menu

```text
╔══════════════════════════════════════╗
║              IDM TOOL                ║
╠══════════════════════════════════════╣
║  [1]  Freeze Trial                   ║
║  [2]  Reset Activation & Trial       ║
║  [3]  Download IDM                   ║
║  [0]  Exit                           ║
╚══════════════════════════════════════╝
```

---

## 📋 Requirements

* Windows 7/8/8.1/10/11 or compatible Server
* PowerShell 5.1+
* Administrator privileges
* Internet connection where required

---

## 💾 Registry Backups

Backups are created before registry modifications.

```text
%SystemRoot%\Temp\
```

The tool automatically detects the Windows architecture and uses the appropriate registry paths.

---

## 🛠️ Troubleshooting

**Administrator error**
→ Run PowerShell/CMD as Administrator.

**IDM not found**
→ Install IDM first or use `[3] Download IDM`.

**Freeze not working**
→ Ensure IDM is installed correctly and the required network connection is available.

**Activation/serial message**
→ Try `[2] Reset Activation & Trial`, then restart IDM.

---

## 📁 Files

| File              | Description               |
| ----------------- | ------------------------- |
| `IDM_Tool.ps1`    | PowerShell implementation |
| `IDM_Tool.cmd`    | CMD version               |
| `CHANGELOG.md`    | Version history           |
| `CONTRIBUTING.md` | Contribution guidelines   |
| `SECURITY.md`     | Security policy           |

---

## ⚠️ Disclaimer

This project is provided **as-is** for educational and system-administration purposes.

Modifying IDM trial or activation data may conflict with the software publisher's license or terms. Users are responsible for complying with applicable software licenses and terms.

**Always maintain a registry backup before making changes.**

---

## 📜 License

MIT License — see [`LICENSE`](LICENSE).

## 🤝 Contributing

Contributions and improvements are welcome. See [`CONTRIBUTING.md`](CONTRIBUTING.md).

---

<p align="center">
  <strong>⭐ Star the repository if you find it useful.</strong>
</p>
