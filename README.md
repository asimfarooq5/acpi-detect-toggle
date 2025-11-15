# acpi-detect-toggle

A small utility for Linux laptops (especially Razer Blade models) to disable or enable AC adapter detection.

## 🔧 Why

Some laptops rapidly toggle power state (`AC connected/disconnected`) due to ACPI firmware quirks.
The BIOS already handles charging, so disabling OS-level detection stops flickering and kernel spam.

## ⚙️ Installation
```bash
git clone git@github.com:asimfarooq5/acpi-detect-toggle.git
cd acpi-detect-toggle
chmod +x install.sh
./install.sh

