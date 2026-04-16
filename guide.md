How to restore arch setup?
    1. packages download:
        - fn to generate pkglist from all providers and add/update it to dotfiles
        - Package Manifest + Git Clone (Automated reinstall) from pkglist

    2. GNU stow symlink: https://youtu.be/06x3ZhwrrwA
        - dotfiles folder becomes the "Source of Truth"—the actual place where the real bytes are stored on your disk. 
        - The original locations (like ~/.config or your home directory) just contain "pointers" that tell the system where to go to find the data.
        - move only manually configured files into dotfiles, NOT all  


- for things that configure the base os, make bash scripts for it!!
