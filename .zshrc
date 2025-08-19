# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=9999999999
SAVEHIST=$HISTSIZE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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

# Get the current Git branch
gbranch() {
    BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        echo " > %F{blue}$BRANCH%F{%(#.blue.green)}"
    fi
}

tworkspace () {
	TWORKSPACE=$(terraform workspace show)
	if [ -n "$TWORKSPACE" ]; then
		if [ "$TWORKSPACE" != "default" ]; then
			echo " | %F{magenta}$TWORKSPACE%F{%(#.blue.green)}"
		fi
	fi
}

prompt_venv() {
    echo "%B%F{red}${VIRTUAL_ENV:+$(basename $VIRTUAL_ENV)}%F{%(#.blue.green)}"
}

#PS1='%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n㉿%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]$(gbranch)$(tworkspace)
#└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '

configure_prompt() {
    prompt_symbol=㉿
    # Old green
    #59FF60

    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀
    case "$PROMPT_ALTERNATIVE" in
        twoline)
	     PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(prompt_venv))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]$(gbranch)$(tworkspace)\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            # Right-side prompt with exit codes and background processes
            #RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
            ;;
        oneline)
	     PROMPT=$'%F{%(#.blue.green)}${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(prompt_venv))─}%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b$(gbranch)$(tworkspace)%F{reset} %(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
	     PROMPT=$'%F{%(#.blue.green)}${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(prompt_venv))─}%B%F{red}%n'$prompt_symbol$'%m%b%F{reset}:%B%F{blue}%~%b$(gbranch)$(tworkspace)%F{reset} %(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE='twoline'
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    configure_prompt

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    ;;
esac

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# some more ls aliases
alias ll='ls -l --group-directories-first'
alias la='ls -A --group-directories-first'
alias lla='ls -la --group-directories-first'
alias l='ls -CF --group-directories-first'

# CUSTOM ENVIRONMENT VARIABLES FOR MW ##########################################
export DEV_INTE="AWSPowerUserAccess-159851557642"
export USANDPIT="046955552049--UTS-AWS-Sandpit"
export BINARIES="/usr/local/bin"
export TESTBENCHLOC=~/Documents/testbench
export DITLOC=~/Documents/IT\ OPS
export CONSTANT_PYTHONPATH=$PYTHONPATH

export AWS_DEV_INTE="159851557642"
export AWS_SANDPIT="046955552049"
export AWS_NP_DATA="014498658256"
export AWS_PR_DATA="014498658553"
################################################################################


################################################################################
alias kv=kvim
alias kvd="kv ."

alias _="clear"
alias __="exit"
alias __CLEAN__="sudo apt clean && sudo apt autoclean"
alias __UPGRADE__="sudo apt upgrade -y"
alias __UPDATE__="sudo apt update -y"
alias __FULL_SUITE__="sudo hwclock --hctosys && __UPDATE__ && __UPGRADE__ && sudo apt autoremove -y && sudo snap refresh"
alias __EDIT__="kv ~/.zshrc -c\"set number\" -c \":292\" -c \"set relativenumber\""
alias __VEDIT__="kv ~/.vimrc"
alias shrc="cd -- ~/Documents/-shrc"
alias DIT="cd ~/Documents/IT\ OPS/"
alias tbench="cd ~/Documents/testbench/"
alias py="python3"

alias glog="git log"
alias glogn="ghash $1"
alias gtree="glog --graph --oneline --all"
alias gstat="git status"
alias gdiff="git diff"
alias gdiff2="gdiff --word-diff=color --word-diff-regex=."
alias gadd="git add"
alias gpull="git pull"
alias gcomm="git commit"
alias gout="git checkout $1"
alias gmerge="git merge $1 --no-commit"
alias gmer="gmerge $1"
alias -s git="git clone"

alias -s png="eog --new-instance"
alias -s jpg="eog --new-instance"
alias -s jpeg="eog --new-instance"
alias -s svg="eog --new-instance"
alias -s txt="kv"
alias -s docx="libreoffice"
alias -s tf="kv"
alias -s hcl="kv"
alias -s pdf="evince"
alias CMMTP='function _cmmtp() { xdg-open "https://uts-edu.atlassian.net/browse/CMMTP-$1"; }; _cmmtp'

alias vsc="code ."
alias cpc="xclip -sel c < "
alias postman="~/Postman/Postman"

alias lsl="ls -l --group-directories-first"
alias lsa="ls -a --group-directories-first"
alias lsla="ls -la --group-directories-first"

alias terr="terraform"
alias gr="grep"
alias leganto_tmpl="$TESTBENCHLOC/Leganto/replace_template.sh $1"

alias __SHOW_DESKTOP__="xdotool key ctrl+alt+d"
alias __COPY__="xclip -selection clipboard"
alias __PASTE__="xclip -out -selection clipboard"

alias __REBOOT__="sudo reboot now"
alias __REBOOT_UEFI__="systemctl reboot --firmware-setup"
alias __REBOOT_BIOS__="__REBOOT_UEFI__"
alias __RESTART_BT__="systemctl restart bluetooth"
alias boot_win="sudo grub-reboot 2 && reboot"
alias __REBOOT_WIN__="boot_win"

alias __REFRESH__="sudo swapoff -a && sudo swapon -a"

alias __install="sudo dpkg -i $1"
alias __extract="tar -xzvf $1"

#################################################################################


################################################################################

EE() {
	export AWS_PROFILE=$1
}

LGIN() {
	EE $1
	aws sso login --profile $1
}

__GETLOG() {
	set -e
	unzip ~/Downloads/logs_$1.zip -d ~/Downloads/logs_$1/
	kvim ~/Downloads/logs_$1/*/*.txt
	rm ~/Downloads/logs_$1.zip
}

__RMLOG() {
	rm -r ~/Downloads/logs_$1/
}

FASTPUSH () {
	git commit -a -m $2
	git push origin $1
}

MV_BINARY() {
	sudo mv $1 /usr/local/bin
}

LEN() {
	s=$1
	echo ${#s}
}

L() {
	leganto $@ | __COPY__
	echo $(__PASTE__)
}

json2terr() {
	set -e
	__PASTE__ > ~/Documents/testbench/Leganto/sfn.json
	py ~/Documents/testbench/Leganto/jsontoterr.py ~/Documents/testbench/Leganto/sfn.json | __COPY__
	echo "Done."
}

now() {
	date +"%A %d %B %Y %H:%M:%S.%N %Z (%z)" | __COPY__
	echo $(__PASTE__)
}

ddiff() {
	~/Documents/testbench/excel/descdiff/rundescdiff.sh "$@"
}

mssng() {
	py ~/Documents/testbench/excel/missing/missing.py
}

gpush() {
	if [ -z $1 ]
	then
		echo "Please provide a branch as the first argument."
	else
		git push origin $1
	fi
}

ghash() {
	if [ -z $1 ]
	then
		GLOGN=5
	else
		GLOGN=$1
	fi

	glog -n $GLOGN --pretty=format:'%h "%Cgreen%s%Creset" - %cn; %ar (%aD)'
}

ghashf() {
	if [ -z $1 ]
	then
		HASHOF=1
	else
		HASHOF=$1
	fi

	ghash $HASHOF | tail -n 1 | awk '{ print $1 }'
}

gdiffh() {
	if [ -z $2 ]
	then
		gdiff $(ghashf 1) $(ghashf $1)
	else
		gdiff $(ghashf $1) $(ghashf $2)
	fi
}

grepo() {
	REMOTE_URL=$(git config --get remote.origin.url)

	if [[ $REMOTE_URL == git@*:* ]]
	then
		HTTPS_URL=${REMOTE_URL/git@/https:\/\/}
		HTTPS_URL=${HTTPS_URL/github\.com:/github\.com\/}
		HTTPS_URL=${HTTPS_URL/\.git/\/tree/$(git rev-parse --abbrev-ref HEAD 2>/dev/null)}
		echo $HTTPS_URL
	fi
}

gopen() {
	REMOTE_URL=$(grepo)

	if [ ! -z $REMOTE_URL ]
	then
		xdg-open "$REMOTE_URL" > /dev/null 2>&1
	else
		echo "Not a .git repository!"
	fi
}

fpush() {
	USAGE_MESSAGE="fpush __TARGET_BRANCH__ __RETURN_BRANCH__"
	if [ -z $1 ]
	then
		echo $USAGE_MESSAGE
	elif [ -z $2 ]
	then
		echo $USAGE_MESSAGE
	else
		TARGET_BRANCH=$1
		RETURN_BRANCH=$2
		gpush $RETURN_BRANCH && gout $TARGET_BRANCH && gpull && gmer $RETURN_BRANCH && gpush $TARGET_BRANCH && gout $RETURN_BRANCH
	fi
}

__watch_cpu() {
	watch -n.05 "grep \"^[c]pu MHz\" /proc/cpuinfo"
}

qjq() {
	VALID=1

	if [ -z $1 ]
	then
		echo "Please provide a JSON in \$1 as Input."
		VALID=0
	fi

	if [ -z $2 ]
	then
		echo "Please enter a jquery expression."
		VALID=0
	fi

	if [ $VALID -eq 1 ]
	then
		cat $1 | jq -r $2
	fi
}

pjq() {
	if [ -z $1 ]
	then
		echo "Please provide a jquery expression."
	else
		__PASTE__ | jq -r $1
	fi
}

here() {
	if [ -z $1 ]
	then
		nautilus . >/dev/null 2>&1
	else
		nautilus $1 >/dev/null 2>&1
	fi
}

kenv () {
	. ~/venv/KALI_VENV/bin/activate
}

MOUNT_WIN() {

	if [ -z $1 ]
	then
		mkdir -p ~/mounted
		MOUNTLOC=~/mounted
	else
		MOUNTLOC=$1
	fi

	sudo mount /dev/nvme0n1p3 $MOUNTLOC
}

update_discord() {
	DISCORD_URL="https://discord.com/api/download?platform=linux&format=deb"
	DISCORD_TMP_LOC="/tmp/discord-debian-linux.tar.gz"

	curl --location --output $DISCORD_TMP_LOC $DISCORD_URL
	__install $DISCORD_TMP_LOC
}


compdef __git_branch_names gpush
compdef __git_branch_names fpush

################################################################################


################################################################################
bindkey "^ " autosuggest-accept
################################################################################

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Source autosuggestions and autocomplete
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/zsh-autocomplete/zsh-autocomplete.plugin.zsh

# Custom function to show file details like ls -la
function show_ls {
    local prefix="${LBUFFER}" # Text typed so far
    # Show 'ls -la' for the matching files/directories
    if [[ -d "$prefix" ]]; then
        LBUFFER=$prefix
        zle redisplay
        ls -la "$prefix" --group-directories-first
    fi
}

# Bind the custom function to be triggered on each key press
zle -N show_ls
# bindkey "^I" show_ls

# Set completion options
zstyle ':completion:*' menu select=long-list
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' verbose yes

# Enable common substring completion
zstyle ':completion:*' completer _complete _files _correct _prefix _ignored
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
# 'r:|[.]*=**'
zstyle ':completion:*' max-errors 2
zstyle ':completion:*' accept-exact 'true'

# Use the default completers to find and insert the common substring
zstyle ':completion:*' use-cache yes

# Bind Tab to autocomplete with the common substring
bindkey '^I' expand-or-complete

# Python Autocomplete Shenanigans ##############################################

#compdef python3.13
# Run something, muting output or redirecting it to the debug stream
# depending on the value of _ARC_DEBUG.
# If ARGCOMPLETE_USE_TEMPFILES is set, use tempfiles for IPC.
__python_argcomplete_run() {
    if [[ -z "${ARGCOMPLETE_USE_TEMPFILES-}" ]]; then
        __python_argcomplete_run_inner "$@"
        return
    fi
    local tmpfile="$(mktemp)"
    _ARGCOMPLETE_STDOUT_FILENAME="$tmpfile" __python_argcomplete_run_inner "$@"
    local code=$?
    cat "$tmpfile"
    rm "$tmpfile"
    return $code
}

__python_argcomplete_run_inner() {
    if [[ -z "${_ARC_DEBUG-}" ]]; then
        "$@" 8>&1 9>&2 1>/dev/null 2>&1 </dev/null
    else
        "$@" 8>&1 9>&2 1>&9 2>&1 </dev/null
    fi
}

_python_argcomplete() {
    local IFS=$'\013'
    local script=""
    if [[ -n "${ZSH_VERSION-}" ]]; then
        local completions
        completions=($(IFS="$IFS" \
            COMP_LINE="$BUFFER" \
            COMP_POINT="$CURSOR" \
            _ARGCOMPLETE=1 \
            _ARGCOMPLETE_SHELL="zsh" \
            _ARGCOMPLETE_SUPPRESS_SPACE=1 \
            __python_argcomplete_run ${script:-${words[1]}}))
        local nosort=()
        local nospace=()
        if is-at-least 5.8; then
            nosort=(-o nosort)
        fi
        if [[ "${completions-}" =~ ([^\\]): && "${match[1]}" =~ [=/:] ]]; then
            nospace=(-S '')
        fi
        _describe "${words[1]}" completions "${nosort[@]}" "${nospace[@]}"
    else
        local SUPPRESS_SPACE=0
        if compopt +o nospace 2> /dev/null; then
            SUPPRESS_SPACE=1
        fi
        COMPREPLY=($(IFS="$IFS" \
            COMP_LINE="$COMP_LINE" \
            COMP_POINT="$COMP_POINT" \
            COMP_TYPE="$COMP_TYPE" \
            _ARGCOMPLETE_COMP_WORDBREAKS="$COMP_WORDBREAKS" \
            _ARGCOMPLETE=1 \
            _ARGCOMPLETE_SHELL="bash" \
            _ARGCOMPLETE_SUPPRESS_SPACE=$SUPPRESS_SPACE \
            __python_argcomplete_run ${script:-$1}))
        if [[ $? != 0 ]]; then
            unset COMPREPLY
        elif [[ $SUPPRESS_SPACE == 1 ]] && [[ "${COMPREPLY-}" =~ [=/:]$ ]]; then
            compopt -o nospace
        fi
    fi
}
if [[ -z "${ZSH_VERSION-}" ]]; then
    complete -o nospace -o default -o bashdefault -F _python_argcomplete python3.13
else
    # When called by the Zsh completion system, this will end with
    # "loadautofunc" when initially autoloaded and "shfunc" later on, otherwise,
    # the script was "eval"-ed so use "compdef" to register it with the
    # completion system
    autoload is-at-least
    if [[ $zsh_eval_context == *func ]]; then
        _python_argcomplete "$@"
    else
        compdef _python_argcomplete python3.13
    fi
fi

################################################################################

#complete -o nospace -C /usr/local/bin/terraform terraform


# PYTHONPATH Recompute on Change Directory -------------------------------------

_rebuild_pythonpath_for_repo() {
  local target="contrib/src/lambda"
  local base="${CONSTANT_PYTHONPATH}"
  local -a addpaths=()

  if [[ -d "$target" ]]; then
    setopt local_options null_glob extended_glob

    # Include the target dir and all subdirectories (recursive).
    # (If you only want immediate children, use: "$target" "$target"/*(/) )
    local -a candidates
    candidates=( "$target" "$target"/**/*(/) )

    local d
    for d in "${candidates[@]}"; do
      case "$d" in
        (#b)*/(.git|.hg|.svn)(/*|) ) continue ;;
        (#b)*/(.venv|venv)(/*|)     ) continue ;;
        (#b)*/(__pycache__|.mypy_cache|.pytest_cache|.ruff_cache)(/*|) ) continue ;;
        (#b)*/(node_modules|.tox|dist|build|.direnv)(/*|) ) continue ;;
      esac
      addpaths+=("$d")
    done

    # Make everything ABSOLUTE (resolve ./..; keeps symlinks intact).
    # Use ${var:A} if you prefer resolving symlinks.
    local -a abs_addpaths=()
    for d in "${addpaths[@]}"; do
      abs_addpaths+=("${d:a}")   # change to ${d:A} to resolve symlinks
    done
    addpaths=("${abs_addpaths[@]}")

    # OPTIONAL (tighter): keep only dirs that actually contain Python files
    local -a filtered=()
    for d in "${addpaths[@]}"; do
      [[ -n ${(f)"$(print -r -- $d/*.py(N) $d/**/__init__.py(N))"} ]] && filtered+=("$d")
    done
    addpaths=("${filtered[@]}")
  fi

  # Join new entries and prepend baseline (if any).
  local joined combined
  joined="${(j/:/)addpaths}"
  if [[ -n "$base" && -n "$joined" ]]; then
    combined="$base:$joined"
  elif [[ -n "$base" ]]; then
    combined="$base"
  else
    combined="$joined"
  fi

  # De-duplicate while preserving order.
  local -a parts
  parts=( ${(s/:/)combined} )
  typeset -aU parts
  export PYTHONPATH="${(j/:/)parts}"
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _rebuild_pythonpath_for_repo

_rebuild_pythonpath_for_repo
