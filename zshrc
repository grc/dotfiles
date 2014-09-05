
#  -*- mode: shell-script -*-
export PATH=~/bin:/opt/local/bin:$PATH
export TZ=Europe/London
export LANG=en_GB.UTF-8
export INFOPATH=~/info:/usr/local/share/info/:/usr/share/info/:/usr/local/share/info/

bindkey -me 2> /dev/null


fpath=(~/zsh $fpath)


export EDITOR='emacsclient -c'



# Global alias shortcuts
alias -g M="| less"
alias -g G="| grep"

alias uxterm=xterm

# Setup coloured ls output on different operating systems
if [[ $OSTYPE == darwin* ]];
then
    export CLICOLOR=1
    export LSCOLORS="exfxcxdxBxegedabagacad"
elif [[ $OSTYPE == linux-gnu ]];
then
    eval $(dircolors -b)
    alias ls="ls --color=auto"
fi


# Determine external IP address
alias myip4="w3m -4 -dump http://chroot-me.in/ip/ | head -n2"






# On 'grc-mcu' we need to share the existing bash history 
if [[ $HOST == 'grc-mcu' ]]
then
    HISTFILE=~/.bash_history
    SAVEHIST=1000
    HISTSIZE=1000
else
    setopt inc_append_history share_history histignoredups 
    setopt extended_history
    SAVEHIST=5000
    HISTFILE=~/.zhistory
    HISTSIZE=5000
fi



# LaTex
export TEXINPUTS=:.:~/.latex:$TEXINPUTS

# stop ^S from locking the terminal
setopt noflowcontrol





#M-m will copy from the end of the line, moving back each time
autoload -Uz copy-earlier-word
zle -N copy-earlier-word
bindkey "^[m" copy-earlier-word



# emacs style ^w copies the region to be pasted with ^y
bindkey "^w" copy-region-as-kill

bindkey "^[r" history-beginning-search-backward


setopt prompt_bang # ! in prompt will be replaced by history number

autoload -U colors && colors
prev_exit="%(?..$fg[red][%?])"
export PROMPT="%{$fg[green]%}! %n@%m: %~$prev_exit%{$reset_color%} "



# autopushd pushes directiories onto a stack.  Stack can be viewed
# with dirs -v and then directory can be moved to with ~1, ~2 etc.
setopt autocd autopushd pushdignoredups


# Completion system

autoload compinit && compinit


# ESC h will trigger the run-help command
#unalias run-help
#autoload -Uz run-help



# Simplified ssh: If a host appears in my .ssh/config then alias its
# host name to the command to ssh into it.

SSH_CONFIG='~/.ssh/config'
if [[ -r $SSH_CONFIG ]]
then
   for host in $(grep ^Host $SSH_CONFIG | cut -d ' ' -f 2);
   do
       alias $host="ssh -q $host"
   done
fi


# Auto correction
setopt correct # Just correct teh command, correctings args gives too many errors



# Don't want spawned commands killed if I exit this window
setopt nohup

autoload -U zmv
# rename batches of files mmv *.txt *.foo
alias mmv='noglob zmv -W'


autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line





# Native OSX coreutils is older than that available through macports
# and doesn't include `shuf' amongst other things.  If we've installed coreutils,
# set up aliases


insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo




# Syntax highlighting
# source ~/git-repos/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh


# A lot of the OSX default installed command line tools
# are ancient compared with the current GNU ones installed
# using mac ports

MACPORT_UTILS=(shuf sort)
MACPORT_PATH=/opt/local/bin
for UTIL in $MACPORT_UTILS
do
    NEW_PATH=${MACPORT_PATH}/g${UTIL}
    if [[ -x $NEW_PATH ]]
    then
	alias $UTIL=$NEW_PATH
    fi
done
    
	    



core_count() {
if [[ $OSTYPE == darwin* ]];
then
    sysctl -n machdep.cpu.core_count
elif [[ $OSTYPE == linux-gnu ]];
then
    grep --count processor /proc/cpuinfo 
fi
}


# Pexip development environment variables used by vagrant
# On the MacBook Air we're a bit constrained for both memory and 
# CPUS.
if [[ $HOST == GilesAir* ]];
then
    # By default we'll use host only as it's less susceptible
    # to disruption when we change wireless networks rtc
    
    export PEXDEV_NFS=1

    # Bridge the vagrant VM to this interface
    export PEXDEV_BRIDGED_ADAPTER="en0: Wi-Fi (AirPort)"
    export PEXDEV_CPUS=2
    export PEXDEV_MEMORY=2048
fi

# Directory shortcuts on my development laptop
if [[ $HOST == GilesAir* ]];
then
    hash -d mcu="/Users/grc/pexdev/mcu"
    hash -d it="/Users/grc/pexdev/IT"
    hash -d license="/Users/grc/work/license"
    hash -d vagrant="/Users/grc/pexdev/mcu/buildtools"
    hash -d webmgt="/Users/grc/pexdev/mcu/si/web/management"
    hash -d webrsrc="/Users/grc/pexdev/mcu/resources/web/static"
    hash -d userdocs="/Users/grc/DropBox/PexShared/User documentation"
fi

export PYTHONPATH="/Users/grc/pexdev/mcu"

# developmant shortcuts
alias vssh='ORIGINAL_DIR=$(pwd);~vagrant; vagrant up; vagrant ssh; cd $ORIGINAL_DIR'

# prompt
setopt prompt_subst

ZSH_THEME_GIT_PROMPT_PREFIX="%{$reset_color%}%{$fg[green]%}["
ZSH_THEME_GIT_PROMPT_SUFFIX="]%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN=""
 
# show git branch/tag, or name-rev if on detached head
parse_git_branch() {
  (command git symbolic-ref -q HEAD || command git name-rev --name-only --no-undefined --always HEAD) 2>/dev/null
}
 
# show red star if there are uncommitted changes
parse_git_dirty() {
  if command git diff-index --quiet HEAD 2> /dev/null; then
    echo "$ZSH_THEME_GIT_PROMPT_CLEAN"
  else
    echo "$ZSH_THEME_GIT_PROMPT_DIRTY"
  fi
}
 
# if in a git repo, show dirty indicator + git branch
git_custom_status() {
  local git_where="$(parse_git_branch)"
  [ -n "$git_where" ] && echo "$(parse_git_dirty)$ZSH_THEME_GIT_PROMPT_PREFIX${git_where#(refs/heads/|tags/)}$ZSH_THEME_GIT_PROMPT_SUFFIX"
}
 
# show current rbenv version if different from rbenv global
rbenv_version_status() {
  local ver=$(rbenv version-name)
  [ "$(rbenv global)" != "$ver" ] && echo "[$ver]"
}
 
# put fancy stuff on the right
if which rbenv &> /dev/null; then
  RPS1='$(git_custom_status)%{$fg[red]%}$(rbenv_version_status)%{$reset_color%} $EPS1'
else
  RPS1='$(git_custom_status) $EPS1'
fi
 

# Needed to correctly build emacs in a macports based X11 set up
# I was experiencing this bug: http://trac.macports.org/ticket/42928
# libjpeg and libxft weren't being found
if [[ -x /opt/local/bin/port ]]
then
   export LDFLAGS="-L/opt/local/lib"
   export CPPFLAGS="-I/opt/local/include"
fi



function most_useless_use_of_zsh {
   local lines columns colour a b p q i pnew
   ((columns=COLUMNS-1, lines=LINES-1, colour=0))
   for ((b=-1.5; b<=1.5; b+=3.0/lines)) do
       for ((a=-2.0; a<=1; a+=3.0/columns)) do
           for ((p=0.0, q=0.0, i=0; p*p+q*q < 4 && i < 32; i++)) do
               ((pnew=p*p-q*q+a, q=2*p*q+b, p=pnew))
           done
           ((colour=(i/4)%8))
            echo -n "\\e[4${colour}m "
        done
        echo
    done
}
