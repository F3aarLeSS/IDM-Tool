# Push to GitHub - Step by Step

Follow these steps exactly to push your code to GitHub.

---

## Step 1: Install Git (if not installed)

Download and install Git from: https://git-scm.com/download/win

During installation, keep all default settings.

---

## Step 2: Create GitHub Repository

1. Go to https://github.com
2. Click the **+** icon (top right) → **New repository**
3. Fill in:
   - **Repository name**: `IDM-Tool`
   - **Description**: `Windows batch script to manage IDM trial period`
   - **Public** (recommended)
   - **Do NOT** check "Add a README file" (we already have one)
4. Click **Create repository**
5. **Copy the repository URL** (you'll need it in Step 4)

---

## Step 3: Open Command Prompt

1. Press `Windows + R`
2. Type `cmd` and press Enter
3. Navigate to your project folder:

```cmd
cd "C:\Users\navaj\AppData\Local\Claude-3p\local-agent-mode-sessions\c4a594e7\00000000\local_994aeea1-6d35-4f69-8193-a3c9d03e942a\outputs\IDM-Tool"
```

---

## Step 4: Initialize Git and Push

Copy and paste these commands **one by one**:

```cmd
git init
```

```cmd
git add .
```

```cmd
git commit -m "Initial release - IDM Tool v1.0"
```

```cmd
git branch -M main
```

```cmd
git remote add origin https://github.com/F3aarLeSS/IDM-Tool.git
```

**Replace `F3aarLeSS` with your actual GitHub username!**

```cmd
git push -u origin main
```

---

## Step 5: Authenticate (if prompted)

If Git asks for credentials:

1. **Option A (Recommended)**: Use GitHub CLI
   - Download from: https://cli.github.com/
   - Run: `gh auth login`

2. **Option B**: Use Personal Access Token
   - Go to GitHub → Settings → Developer settings → Personal access tokens
   - Generate new token (classic)
   - Select `repo` scope
   - Copy the token
   - Use token as password when prompted

---

## Step 6: Verify

1. Go to your GitHub repository: `https://github.com/F3aarLeSS/IDM-Tool`
2. You should see all your files:
   - `IDM_Tool.cmd`
   - `README.md`
   - `LICENSE`
   - `.gitignore`
   - `CONTRIBUTING.md`
   - `SECURITY.md`
   - `CHANGELOG.md`
   - `docs/` folder

---

## Quick Copy-Paste Version

If you want to copy-paste everything at once (replace `F3aarLeSS`):

```cmd
cd "C:\Users\navaj\AppData\Local\Claude-3p\local-agent-mode-sessions\c4a594e7\00000000\local_994aeea1-6d35-4f69-8193-a3c9d03e942a\outputs\IDM-Tool"

git init && git add . && git commit -m "Initial release - IDM Tool v1.0" && git branch -M main && git remote add origin https://github.com/F3aarLeSS/IDM-Tool.git && git push -u origin main
```

---

## Troubleshooting

### "fatal: remote origin already exists"
```cmd
git remote remove origin
git remote add origin https://github.com/F3aarLeSS/IDM-Tool.git
```

### "error: failed to push some refs"
```cmd
git push -u origin main --force
```

### "Authentication failed"
- Use Personal Access Token instead of password
- Or install GitHub CLI: https://cli.github.com/

### Git not recognized
- Restart command prompt after installing Git
- Or restart your computer

---

## After Pushing

Your repository is now live! Share the link:
```
https://github.com/F3aarLeSS/IDM-Tool
```

To create a release:
1. Go to your repository
2. Click **Releases** → **Create a new release**
3. Tag: `v1.0`
4. Title: `IDM Tool v1.0`
5. Upload `IDM_Tool.cmd`
6. Publish release
