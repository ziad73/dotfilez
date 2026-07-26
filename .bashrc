# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Enable bash-completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


alias ls='ls -F'

# Open searched file(s) with nvim
# alias vfzf='nvim $(fzf -m --preview="bat --color=always {}")' # click tab to select multiple files at once

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=10000
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
xterm-color | *-256color) color_prompt=yes ;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm* | rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*) ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    # alias ls='ls --color=never'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
    fi
fi

########################################################
# Function to show git branch
parse_git_branch() {
    # simple way
    # git branch 2>/dev/null | sed -n '/\* /s///p'

    # more robust way
    local branch git_dir head git_marker dir

    branch="$(git symbolic-ref --quiet --short HEAD 2>/dev/null)" && {
        printf '%s' "$branch"
        return 0
    }

    branch="$(git rev-parse --quiet --short HEAD 2>/dev/null)" && {
        printf '%s' "$branch"
        return 0
    }

    dir="$PWD"
    while [ "$dir" != "/" ]; do
        if [ -d "$dir/.git" ] || [ -f "$dir/.git" ]; then
            git_marker="$dir/.git"
            break
        fi
        dir="${dir%/*}"
        [ -n "$dir" ] || dir="/"
    done

    [ -n "${git_marker:-}" ] || return 1

    if [ -d "$git_marker" ]; then
        git_dir="$git_marker"
    else
        read -r head < "$git_marker" || return 1
        case "$head" in
            gitdir:\ *)
                git_dir="${head#gitdir: }"
                case "$git_dir" in
                    /*) ;;
                    *) git_dir="$(cd "$(dirname "$git_marker")" && cd "$git_dir" 2>/dev/null && pwd)" ;;
                esac
                ;;
            *)
                return 1
                ;;
        esac
    fi

    [ -r "$git_dir/HEAD" ] || return 1
    read -r head < "$git_dir/HEAD" || return 1

    case "$head" in
        ref:\ refs/heads/*)
            printf '%s' "${head#ref: refs/heads/}"
            ;;
        ref:\ *)
            printf '%s' "${head#ref: }"
            ;;
        *)
            printf '%.12s' "$head"
            ;;
    esac
}

# Function to show exit code (if nonzero)
show_exit_code() {
    local code=$?
    if [ $code -ne 0 ]; then
        echo -e "\[\033[31m\]$code\[\033[0m\]" # red color
    fi
}

# Main prompt (left side)
PS1='\W$(branch=$(parse_git_branch); 
     if [ -n "$branch" ]; then 
        echo " on \[\033[1;32m\]$branch\[\033[0m\]"; 
     else 
        echo "/"
     fi
     )\n\[\033[1;32m\]❯\[\033[0m\] ' # green color

# Set right-aligned prompt section
PROMPT_COMMAND='EXIT_CODE=$?; 
                BRANCH=$(parse_git_branch);
                STATUS=$( [ $EXIT_CODE -ne 0 ] && printf "\033[31m$EXIT_CODE\033[0m" );

                printf "\033[s\033[999C\033[%dD%s\033[u" $((${#STATUS}+1)) "$STATUS"'
##############################################################

alias v="vim"

# Git refuses to operate in a repository owned by a different user
# this is a security protection
# it prevents malicious repos from abusing Git config/hooks in directories you don’t actually own
# So “trust rule” is just:
# an allowlist entry in your global Git config
# specifically the safe.directory setting

# use trustrepo only when Git complains about dubious ownership
trustrepo() {
    local repo_root
    repo_root="$(git rev-parse --show-toplevel 2>/dev/null)" || repo_root="$PWD"
    git config --global --add safe.directory "$repo_root"
    echo "Trusted Git repo: $repo_root"
}

# atbash cipher
atbash() {
    echo "$*" | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' 'ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba'
}

export GOPATH="$HOME/go"

path_prepend() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1${PATH:+:$PATH}" ;;
    esac
}

path_append() {
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="${PATH:+$PATH:}$1" ;;
    esac
}

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/.local/share/nvim/mason/bin"
path_prepend "/usr/local/go/bin"
path_append "$GOPATH/bin"
path_append "/opt/nvim"
path_append "/usr/local/bin"
export PATH

# alias name for path directory
alias lcl="cd /mnt/localdisk/"

alias git-graph='git log --graph --decorate --oneline --all --abbrev-commit --color'
function lazygit() {
    git add -A
    git commit -a -m "$1"
    # git push # equivalent to: git push origin <current-branch-name> [iff branch already upstreamed]
}

# function lazyclone() {
#     git clone git@github.com:$1 "$2"
# }

compile() {
    file="$1"
    ext="${file##*.}"
    name="${file%.*}"

    case "$ext" in
    cpp)
        g++ "$file" -g -o "$name"
        ;;
    c)
        gcc "$file" -g -o "$name"
        ;;
    java)
        javac "$file"
        ;;
    py)
        echo "Python does not require compilation."
        ;;
    go)
        go build -o "$name" "$file"
        ;;
    *)
        echo "Unsupported file type: $ext"
        ;;
    esac
}

run() {
    file="$1"
    ext="${file##*.}"
    name="${file%.*}"

    case "$ext" in
    cpp)
        g++ "$file" -o "$name" && ./"$name"
        ;;
    c)
        gcc "$file" -o "$name" && ./"$name"
        # gcc "$file" -o "$name" # & ./"$name" just compile
        ;;
    java)
        javac "$file" && java "$name"
        ;;
    py)
        python3 "$file"
        ;;
    go)
        go run "$file"
        ;;
    *)
        echo "Unsupported file type: $ext"
        ;;
    esac
}

open() {
    file="$1"
    ext="${file##*.}"
    ext="${ext,,}" # lowercase

    if [ ! -f "$1" ]; then
        echo "File not found!"
        return 1
    fi
    case "$ext" in
    pdf | xopp)
        # evince "$file" &>/dev/null &
        xournalpp "$file" &>/dev/null &
        ;;
    txt | md | log | cfg)
        mousepad "$file" &>/dev/null &
        ;;
    mp4 | mkv | avi | mov | flv | wmv | webm)
        vlc "$file" &>/dev/null &
        ;;
    mp3 | wav | ogg | flac)
        vlc "$file" &>/dev/null &
        ;;
    jpg | jpeg | png | gif | bmp)
        ristretto "$file" &>/dev/null &
        ;;
    *)
        xdg-open "$file" &>/dev/null &
        ;;
    esac
}

alias v="vim"

# Auto start tmux
if command -v tmux &>/dev/null && [ -z "$TMUX" ]; then
    tmux attach -t default || tmux new -s default
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion

# --- PostgreSQL Shortcuts ---
pg() {
    case "$1" in
    start)
        sudo systemctl start postgresql
        echo "PostgreSQL started."
        ;;
    stop)
        sudo systemctl stop postgresql
        echo "PostgreSQL stopped."
        ;;
    restart)
        sudo systemctl restart postgresql
        echo "PostgreSQL restarted."
        ;;
    status)
        systemctl status postgresql
        ;;
    enable)
        sudo systemctl enable postgresql
        echo "PostgreSQL autostart enabled."
        ;;
    disable)
        sudo systemctl disable postgresql
        echo "PostgreSQL autostart disabled."
        ;;
    *)
        echo "Usage: pg {start|stop|restart|status|enable|disable}"
        ;;
    esac
}
pghelp ()
{
    cat <<EOF
PostgreSQL psql Cheat Sheet:
---------------------------------------------------------
db_name=> query
psql            : Enter active mode
\l              : List all databases.
\c db_name      : Connect to a different database.
\c - username   : Switch user (same DB),
\c db_name username : Switch user and DB
\dt             : List all tables in the current database.
\d <table>	    : Describe table detailed structure (columns and types).
\d              : List all tables in current db
\df             : List all functions (you should see your get_all_persons here).
\du             : List all users (roles).
\?              : Help with all backslash commands.
\q              : Quit/Exit the psql shell.
psql -U username: Start psql as user
for more visit: https://quickref.me/postgres.html#postgresql-commands
---------------------------------------------------------

Common SQL Operations:

-- Create a new user
CREATE USER my_user WITH PASSWORD 'mypassword'; # 1234

-- Create a database
CREATE DATABASE my_db OWNER my_user;

-- Grant permissions
GRANT ALL PRIVILEGES ON DATABASE my_db TO my_user;


Note: Remember to use semicolons (;) at the end of SQL queries!
EOF

}
# --- End PostgreSQL Shortcuts ---

# copy file into clipboard clip image.png
# works well for img
# text files copy its content
# else ignored
clip() {
    if [[ ! -f "$1" ]]; then
        echo "File not found: $1"
        return 1
    fi

    # Detect MIME type (portable)
    mime=$(file --mime-type -b "$1")

    # Copy to clipboard with correct type
    xclip -selection clipboard -t "$mime" -i "$1"

    echo "Copied '$1' to clipboard as $mime"
}
update_pckgs() {
    local DOTFILES_PATH="$HOME/dotfiles/pckgs.sh"

    # Create the directory if it doesn't exist
    mkdir -p "$(dirname "$DOTFILES_PATH")"

    {
        echo "#!/bin/bash"
        echo "# Generated on: $(date)"
        echo ""

        # 1. Native Pacman Packages (Explicitly installed)
        echo "export PACMAN_PKGS=("
        pacman -Qqen | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 2. AUR Packages (via pacman -Qm or yay)
        echo "export AUR_PKGS=("
        pacman -Qqem | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 3. NPM Global Packages
        echo "export NPM_PKGS=("
        npm ls -g --depth=0 2>/dev/null | tail -n +2 | sed 's/.* //' | sed 's/@[0-9].*//' | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 4. Pip User Packages
        echo "export PIP_PKGS=("
        pip3 list --user --format=freeze 2>/dev/null | sed 's/=.*//' | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 5. Cargo Installed Tools
        echo "export CARGO_PKGS=("
        cargo install --list 2>/dev/null | awk '{print $1}' | sort -u | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 6. Go Installed Binaries
        echo "export GO_PKGS=("
        ls "$GOPATH/bin" 2>/dev/null | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 7. Dotnet Global Tools
        echo "export DOTNET_TOOLS=("
        dotnet tool list -g 2>/dev/null | tail -n +3 | awk '{print $1}' | sed 's/^/  "/' | sed 's/$/"/'
        echo ")"
        echo ""

        # 8. VS Code Extensions
        if command -v code &> /dev/null; then
            echo "export VSCODE_EXTENSIONS=("
            code --list-extensions 2>/dev/null | sed 's/^/  "/' | sed 's/$/"/'
            echo ")"
            echo ""
        fi

        # 9. Flatpaks
        if command -v flatpak &> /dev/null; then
            echo "export FLATPAK_PKGS=("
            flatpak list --app --columns=application | sed 's/^/  "/' | sed 's/$/"/'
            echo ")"
        fi
    } > "$DOTFILES_PATH"

    chmod +x "$DOTFILES_PATH"
    echo "Successfully updated $DOTFILES_PATH"
}


install_pckgs() {
    local DOTFILES_PATH="$HOME/dotfiles/pckgs.sh"

    # Check if the package list exists
    if [ ! -f "$DOTFILES_PATH" ]; then
        echo "Error: $DOTFILES_PATH not found. Run your update function first."
        return 1
    fi

    # Source the variables
    source "$DOTFILES_PATH"

    # 1. Install Native Pacman Packages
    if [ ${#PACMAN_PKGS[@]} -gt 0 ]; then
        echo "--> Installing native packages..."
        sudo pacman -S --needed --noconfirm "${PACMAN_PKGS[@]}"
    fi

    # 2. Install AUR Packages
    if [ ${#AUR_PKGS[@]} -gt 0 ]; then
        local AUR_HELPER=""
        if command -v yay &> /dev/null; then
            AUR_HELPER="yay"
        elif command -v paru &> /dev/null; then
            AUR_HELPER="paru"
        fi

        if [ -n "$AUR_HELPER" ]; then
            echo "--> Installing AUR packages using $AUR_HELPER..."
            $AUR_HELPER -S --needed --noconfirm "${AUR_PKGS[@]}"
        else
            echo "Warning: No AUR helper (yay/paru) found. Skipping AUR packages."
        fi
    fi

    # 3. Install NPM Global Packages
    if [ ${#NPM_PKGS[@]} -gt 0 ] && command -v npm &> /dev/null; then
        echo "--> Installing NPM global packages..."
        npm install -g "${NPM_PKGS[@]}"
    fi

    # 4. Install Pip User Packages
    if [ ${#PIP_PKGS[@]} -gt 0 ] && command -v pip3 &> /dev/null; then
        echo "--> Installing pip user packages..."
        pip3 install --user "${PIP_PKGS[@]}"
    fi

    # 5. Install Cargo Tools
    if [ ${#CARGO_PKGS[@]} -gt 0 ] && command -v cargo &> /dev/null; then
        echo "--> Installing cargo tools..."
        cargo install "${CARGO_PKGS[@]}"
    fi

    # 6. Install Go Tools
    if [ ${#GO_PKGS[@]} -gt 0 ] && command -v go &> /dev/null; then
        echo "--> Installing Go tools..."
        for pkg in "${GO_PKGS[@]}"; do
            go install "$pkg"
        done
    fi

    # 7. Install Dotnet Global Tools
    if [ ${#DOTNET_TOOLS[@]} -gt 0 ] && command -v dotnet &> /dev/null; then
        echo "--> Installing dotnet global tools..."
        for tool in "${DOTNET_TOOLS[@]}"; do
            dotnet tool install -g "$tool"
        done
    fi

    # 8. Install VS Code Extensions
    if [ ${#VSCODE_EXTENSIONS[@]} -gt 0 ] && command -v code &> /dev/null; then
        echo "--> Installing VS Code extensions..."
        for ext in "${VSCODE_EXTENSIONS[@]}"; do
            code --install-extension "$ext" --force
        done
    fi

    # 9. Install Flatpaks
    if [ ${#FLATPAK_PKGS[@]} -gt 0 ] && command -v flatpak &> /dev/null; then
        echo "--> Installing Flatpaks..."
        flatpak install --or-update -y flathub "${FLATPAK_PKGS[@]}"
    fi

    echo "Installation process complete."
}

alias g-sheet='xdg-open https://geminicli.com/docs/cli/cli-reference/'


alias xstart='sudo /opt/lampp/lampp start'
alias xstop='sudo /opt/lampp/lampp stop'

export PATH="$PATH:$HOME/.dotnet/tools"



# Load Angular CLI autocompletion.
source <(ng completion script)
