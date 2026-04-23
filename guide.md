How to restore arch setup in seconds?

    1. packages download: use existing bash functions
        - Update current pckgs list: update_pckgs() 
        - Automated reinstall: install_pckgs() 

    2. GNU stow symlink: https://youtu.be/06x3ZhwrrwA
        - dotfiles folder becomes the "Source of Truth"—the actual place where the real bytes are stored on your disk. 
        - The original locations (like ~/.config or your home directory) just contain "pointers" that tell the system where to go to find the data.
        - move only manually configured files into dotfiles, NOT all  
    
    3. Don't forget to make all shell scripts executable
        - run make_scripts_executable.sh 

    4. Don't forget to make a backup for s extensions
    
    - for things that configure the base os, make bash scripts for it!!

Troubleshooting notes:

    1. Telegram app menu launcher does nothing
        - Symptom:
            - Telegram does not open from app menu
            - Running `Telegram` shows:
              `/usr/lib/libgcc_s.so.1: version 'GCC_13.0.0' not found`
        - Cause:
            - `libgcc_s.so.1` comes from `libgcc`, not `gcc-libs`
        - Fix:
            - `sudo pacman -Syu`
            - `sudo pacman -S libgcc highway telegram-desktop`
        - Then test:
            - `Telegram -h`
        - Reboot is recommended after a full system upgrade
