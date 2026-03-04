# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
export HISTSIZE=10000
export HISTFILESIZE=20000

export HISTCONTROL=ignoreboth
shopt -s histappend
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"


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
    xterm-color|*-256color) color_prompt=yes;;
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
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac


# Set Default Editor
export EDITOR=nvim
export VISUAL=nvim


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

alias vim='nvim'  # vimと打ってもnvimが起動するように
alias lg='lazygit' # lazygitを lg で起動


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
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/bin/verible:$PATH" 


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion


# ==========================================
# 3. 補完と検索 (Completion & Search)
# ==========================================

# 大文字小文字を区別せずに補完する
bind "set completion-ignore-case on"

# タブキー1回で候補を表示する (デフォルトは2回)
bind "set show-all-if-ambiguous on"

# bash-completion の読み込み
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
elif [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# --- FZF連携設定 (コマンド履歴検索・ファイル検索) ---
# FZFがインストールされている場合のみ有効化
# --- FZF連携設定 (Ubuntu/Debian版) ---
if command -v fzf >/dev/null 2>&1; then
    # キーバインド (Ctrl+r, Ctrl+t, Alt+c)
    if [ -f /usr/share/doc/fzf/examples/key-bindings.bash ]; then
        source /usr/share/doc/fzf/examples/key-bindings.bash
    fi
    # 補完機能 (**.TAB など)
    if [ -f /usr/share/doc/fzf/examples/completion.bash ]; then
        source /usr/share/doc/fzf/examples/completion.bash
    fi
    
    # プレビュー設定
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :500 {} || cat {}'"
fi



# ============================================
# 6. GHQ設定
# ============================================

function ghq-path() {
    ghq list --full-path | fzf
}

function dev() {
    local moveto
    moveto=$(ghq-path)
    cd "${moveto}" || exit 1

    # rename session if in tmux

    if [[ -n ${TMUX} ]]; then
        local repo_name
        repo_name="${moveto##*/}"

        tmux rename-session "${repo_name//./-}"
    fi
}



# ==========================================
# 5. プロンプト設定 (Git Status Prompt)
# ==========================================

# Gitリポジトリ情報を取得する関数の定義
parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# プロンプトの色定義
RESET="\[\033[0m\]"
GREEN="\[\033[32m\]"
BLUE="\[\033[34m\]"
YELLOW="\[\033[33m\]"
RED="\[\033[31m\]"

# プロンプトの構築
# 形式: [ユーザー@ホスト ディレクトリ (gitブランチ)] $ 
set_bash_prompt() {
    # 直前のコマンドが成功なら緑、失敗なら赤にするスマイルマーク :)
    if [ $? -eq 0 ]; then
        STATUS_COLOR="$GREEN"
    else
        STATUS_COLOR="$RED"
    fi
    
    PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${YELLOW}\$(parse_git_branch)${RESET}\n${STATUS_COLOR}\$ ${RESET}"
}

# コマンド実行ごとにプロンプトを再構築
PROMPT_COMMAND="set_bash_prompt; $PROMPT_COMMAND"

# multi-agent-shogun aliases (added by first_setup.sh)
alias css='tmux attach-session -t shogun'
alias csm='tmux attach-session -t multiagent'
