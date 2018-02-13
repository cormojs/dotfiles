path=(~/bin $path)

autoload -Uz select-word-style
select-word-style bash

# completion
autoload -U compinit
compinit

zstyle ':completion:*' list-colors 'di=32' 'ln=35' 'so=34' 'ex=31' 'bd=46;34' 'cd=43;34'
zstyle ':completion:*:default' menu select=1
zstyle ':completion:*:descriptions' format '%BCompleting %d%b'
zstyle ':completion::prefix:*' completer _complete

# predict-on
autoload predict-on
predict-on

function predict-and-accept () {
    zle accept-line
    predict-on
}

zle -N predict-and-accept
bindkey '^M' predict-and-accept

# prompt
case ${UID} in
    0)
	PROMPT="%B%{[31m%}%/#%{[m%}%b "
	PROMPT2="%B%{[31m%}%_#%{[m%}%b "
	SPROMPT="%B%{[31m%}%r is correct? [n,y,a,e]:%{[m%}%b "
	[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
	;;
    *)
	PROMPT=$'%1(v|%F{green}%1v%f\n|)'$'%m{%{[31m%}%n%b%}}%# '
	PROMPT2="%{[31m%}%_%%%{[m%} "
	SPROMPT="%{[31m%}%r is correct? [n,y,a,e]:%{[m%} "
	[ -n "${REMOTEHOST}${SSH_CONNECTION}" ] && 
        PROMPT="%{[37m%}${HOST%%.*} ${PROMPT}"
	;;
esac


# git prompt
autoload -Uz add-zsh-hook
autoload -Uz colors
colors
autoload -Uz vcs_info

zstyle ':vcs_info:*' enable git svn hg bzr
zstyle ':vcs_info:*' formats '(%s)-[%b]'
zstyle ':vcs_info:*' actionformats '(%s)-[%b|%a]'
zstyle ':vcs_info:(svn|bzr):*' branchformat '%b:r%r'
zstyle ':vcs_info:bzr:*' use-simple true

autoload -Uz is-at-least
if is-at-least 4.3.10; then
  # この check-for-changes が今回の設定するところ
  zstyle ':vcs_info:git:*' check-for-changes true
  zstyle ':vcs_info:git:*' stagedstr "+"    # 適当な文字列に変更する
  zstyle ':vcs_info:git:*' unstagedstr "-"  # 適当の文字列に変更する
  zstyle ':vcs_info:git:*' formats '(%s)-[%b] %c%u'
  zstyle ':vcs_info:git:*' actionformats '(%s)-[%b|%a] %c%u'
fi



precmd () {
    # 1行あける
    print
    # カレントディレクトリ
    local left=' %{\e[38;5;2m%}(%~)%{\e[m%}'
    # バージョン管理されてた場合、ブランチ名
    vcs_info
    local right="%{\e[38;5;32m%}${vcs_info_msg_0_}%{\e[m%}"
    # スペースの長さを計算
    # テキストを装飾する場合、エスケープシーケンスをカウントしないようにします
    local invisible='%([BSUbfksu]|([FK]|){*})'
    local leftwidth=${#${(S%%)left//$~invisible/}}
    local rightwidth=${#${(S%%)right//$~invisible/}}
    local padwidth=$(($COLUMNS - ($leftwidth + $rightwidth) % $COLUMNS))

    print -P $left${(r:$padwidth:: :)}$right
}


# status line

case "${TERM}" in
    xterm-256color)
	function preexec() {
	    case "${COLUMNS}" in
		191)
		    RPROMPT='%130>>%B%{[31m%}[%~]%b%}-----------------------------------------------------------'
		    ;;
		*)
		    RPROMPT='%50>>%B%{[31m%}[%~]%b%}-----------------------------------------------------------'
		    ;;
	    esac

	    echo -ne "\ek${1%% *}\e\\"
	}
	;;
esac


function chpwd() {
    echo -ne "\ek$(basename $(pwd))\e\\"
}



# emacs like key binding
bindkey -e

# history
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000

setopt hist_ignore_dups
setopt share_history
setopt auto_cd
setopt auto_pushd
setopt correct
setopt list_packed
setopt noautoremoveslash
setopt nolistbeep
setopt complete_aliases
setopt printeightbit
setopt printeight_bit
stty stop undef

# export JAVA_HOME="/opt/iced"
# export LC_ALL=ja_JP.utf-8
# export LANG=ja_JP.utf-8

# aliases
# alias man="man -P\"cat | nkf -w | /usr/bin/less\""
alias lsnc="ls --color=never"
alias ll="ls -l"
alias la="ls -a"
alias lat="ls -lat"
alias rr="rm -ri"
alias e="emacsclient"
alias -g X="| xargs"
alias -g X0="| xargs -0"
alias -g XX="| xargs -0i -L100 xli {}"

alias mencoder_dvd="mencoder -oac copy -ovc x264 -x264encopts crf=20:qp_step=4:ratetol=4 -vf filmdint,pp=15r,scale=720:480 -aid 128 -sid 0 -ofps 30000/1001 "

function ts2mp4_60fps() {
    local TS=$1
    shift
    ffmpeg -y -i $TS -f mp4 -vcodec libx264 -fpre ~/.ffmpeg/libx264-hq-ts.ffpreset -r 60000/1001 -aspect 16:9 -s 960x720 -bufsize 20000k -maxrate 25000k -acodec libfaac -ac 2 -ar 48000 -aq 100 -threads 8 $@
}

function ts2mp4_6ch() {
    local TS=$1
    shift
    ffmpeg -y -i $TS -f mp4 -vcodec libx264 -fpre ~/.ffmpeg/libx264-hq-ts.ffpreset -r 30000/1001 -aspect 16:9 -s 960x720 -bufsize 20000k -maxrate 25000k -acodec libfaac -ac 6 -ar 48000 -aq 100 -threads 8 $@
}

function ts2mp4_30fps() {
    local TS=$1
    shift
    ffmpeg -y -i $TS -f mp4 -vcodec libx264 -fpre ~/.ffmpeg/libx264-hq-ts.ffpreset -r 30000/1001 -aspect 16:9 -s 960x720 -bufsize 20000k -maxrate 25000k -acodec libfaac -ac 2 -ar 48000 -aq 100 -threads 8 $@
}

function ts2mp4_24fps() {
    local TS=$1
    shift
    ffmpeg -y -r 30000/1001 -i $TS -vf yadif=1 -f mp4 -vcodec libx264 -aspect 16:9 -s 1440x1080 -bufsize 20000k -maxrate 25000k -acodec libfaac -ac 2 -ar 48000 -aq 100 -threads 8 -fpre ~/.ffmpeg/libx264-hq-ts.ffpreset -r 24000/1001 $@
}



function mkcd() {
    mkdir $1 && cd $1
}

function dinfo() {
    du $@ --max-depth=1 | sort -nr | perl -MMath::Round -wple 's&(\d+)&($1>=1024**3)?nearest(0.1, $1/(1024**3)) . "T":($1>=1024**2)?nearest(0.1, $1/(1024**2)) . "G":($1>=1024)?nearest(0.1, $1/1024) . "M":$1 . "K"&e'
}

# emacs file-processing
function emipt() {
    perl -we 'shift @ARGV;print "(progn (setq argv (list";while($foo=shift @ARGV){print " \"$ENV{PWD}/$foo\"";}print ")) nil)";' $@ | xargs -0 -i emacsclient-emacs-23 -e {} $1
}

function findpic() {
    find $@ -regex '.*\.\(jpg\|jpeg\|bmp\|png\|gif\)' -print0
}

