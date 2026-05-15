## 1. The "Dependencies" List

Keep a list of these packages. You'll need to install them first on the new machine:

* **Recording:** `simplescreenrecorder`
* **Audio Engine:** `pipewire`, `pipewire-pulse`, `wireplumber`
* **The Filter:** `noise-suppression-for-voice`

---

## 2. The Configuration Files

You only need to back up **two** specific things to keep the "magic" alive:

### A. The Noise Filter (The "Discord" Sound)

Copy this file to your backup location:
`~/.config/pipewire/pipewire.conf.d/99-input-denoising.conf`

**To Restore:** Just place it in the same directory on the new system and restart PipeWire.

### B. The SSR Settings (The Performance/Encoder Setup)

SimpleScreenRecorder saves your profiles (presets, codecs, and audio sources) here:
`~/.config/simplescreenrecorder/settings.conf`

**To Restore:** Drop this file into `~/.config/simplescreenrecorder/` before you open the app for the first time. It will remember your "Ultrafast" preset and your "Noise Canceling Source" selection automatically.

---

## 3. Automation (The "Developer" Way)

Since you are likely already using a terminal-centric workflow in **i3**, you can create a simple shell script (`setup_recorder.sh`) to do this for you:

```bash
#!/bin/bash

# 1. Install packages
sudo pacman -S --needed simplescreenrecorder pipewire pipewire-pulse wireplumber noise-suppression-for-voice

# 2. Create directory for PipeWire config
mkdir -p ~/.config/pipewire/pipewire.conf.d

# 3. Download/Copy your config (Assumes you have it in your current dir)
cp 99-input-denoising.conf ~/.config/pipewire/pipewire.conf.d/

# 4. Restart services
systemctl --user restart pipewire pipewire-pulse wireplumber

echo "Setup complete. Open SimpleScreenRecorder and select 'Noise Canceling Source'."

```

