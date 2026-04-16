# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Enable Git tab completion
# source ~/.git-completion.bash

alias ls='ls -F'

# Open searched file(s) with nvim
# alias vfzf='nvim $(fzf -m --preview="bat --color=always {}")' # click tab to select multiple files at once

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

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
    git branch 2>/dev/null | sed -n '/\* /s///p'
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

alias chat="chatbang"
alias v="nvim"

# atbash cipher
atbash() {
    echo "$*" | tr 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' 'ZYXWVUTSRQPONMLKJIHGFEDCBAzyxwvutsrqponmlkjihgfedcba'
}

export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# alias name for path directory
alias lcl="cd /mnt/localdisk/"

export PATH=$PATH:~/.local/bin

# bottom overrides ups
export PATH=/usr/local/go/bin:$PATH
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

export PATH="$PATH:/opt/nvim"

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

export PATH="$PATH:/usr/local/bin"
alias v="nvim"
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"

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
export PATH=/home/ziad/.local/bin:/home/ziad/.nvm/versions/node/v24.11.1/bin:/home/ziad/.local/share/nvim/mason/bin:/usr/local/go/bin:/home/ziad/.local/share/nvim/mason/bin:/usr/local/go/bin:/usr/local/bin:/usr/bin:/bin:/usr/local/sbin:/usr/lib/jvm/default/bin:/usr/bin/site_perl:/usr/bin/vendor_perl:/usr/bin/core_perl:/usr/local/go/bin:/home/ziad/go/bin:/home/ziad/.local/bin:/home/ziad/go/bin:/opt/nvim:/usr/local/bin:/usr/local/go/bin:/home/ziad/go/bin:/home/ziad/.local/bin:/home/ziad/go/bin:/opt/nvim:/usr/local/bin
