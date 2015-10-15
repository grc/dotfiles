# zshrc -*- mode: sh; -*-
# Zsh configuration, mostly used on OSX though trying to keep
# compatible with Linux too.



# Setting up PATH
# Macports uses the /opt/local/bin path
[[ -x /opt/local/bin/port ]] && PATH=/opt/local/bin:$PATH

# Amazon Web Services tool installs to /usr/local/bin
[[ -x /usr/local/bin/aws ]] && PATH=/usr/local/bin:$PATH

# and my local bin directory
export PATH=~/bin:$PATH  

export TZ=Europe/London
export LANG=en_GB.UTF-8


export INFOPATH=~/info:/usr/local/share/info/:/usr/share/info/:/usr/local/share/info/

bindkey -me 2> /dev/null


fpath=(~/zsh $fpath)


# Use emacsclient as the default editor, firing up an emacs server if
# there isn't one running already.
export EDITOR='emacsclient -c'
export ALTERNATE_EDITOR='emacs'


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

# Set the prompt colour according to whether or not we are connected
# via an ssh session.  This makes it somewhat easier to sopt when
# you're working on a remote machine.
if [[ -z $SSH_CONNECTION ]];
then
    # we are not ssh'd in
    NORMAL_PROMPT=green
else
    NORMAL_PROMPT=yellow
fi

# prompt
setopt prompt_subst

autoload -Uz vcs_info



# Update the xterm title with the name of the currently running
# command.  precmd will then rewrite that again when the prompt is
# displayed.
preexec() { print -n "\e]0;${HOST:r} ${(q)1//(#m)[$'\000-\037\177-']/${(q)MATCH}}\a" }

precmd()
{
    print -Pn "\e]0;%m: %~\a"  # Update the xterm title
    vcs_info
    RPROMPT=$vcs_info_msg_0_
}

zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:git*' formats "%{$fg[red]%}%u%c%{$fg[$NORMAL_PROMPT]%}[%b]%{$reset_color%}"

export PROMPT="%{$fg[$NORMAL_PROMPT]%}! %n@%m %~ >%{$reset_color%} "


# Get zsh to report if the command returns a failure code
setopt print_exit_value

# autopushd pushes directories onto a stack.  Stack can be viewed
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
setopt correct # Just correct the command, correctings args gives too many errors



# Don't want spawned commands killed if I exit this window
setopt nohup

autoload -U zmv
# rename batches of files mmv *.txt *.foo
alias mmv='noglob zmv -W'


autoload -U edit-command-line
zle -N edit-command-line
bindkey '\C-x\C-e' edit-command-line





insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[1" insert-sudo # M-1



# A lot of the OSX default installed command line tools
# are ancient compared with the current GNU ones installed
# using mac ports


MACPORT_UTILS=(find shuf sort sed)
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




# Needed to correctly build emacs in a macports based X11 set up
# I was experiencing this bug: http://trac.macports.org/ticket/42928
# libjpeg and libxft weren't being found
if [[ -x /opt/local/bin/port ]]
then
   export LDFLAGS="-L/opt/local/lib"
   export CPPFLAGS="-I/opt/local/include"
fi






# Change directory to that containing the file in the currently active
# emacs buffer.  THe (Q) parameter expansion flag removes a level of
# quoting.
cde() {
    cd ${(Q)$(emacsclient -e '(with-current-buffer
                               (window-buffer)
                               default-directory) ')}
}



# up: move up the directory stack either a numeric amount or to a
# directory with the required prefix.
#
# With this helper function, you
# can do a lot more actually: Say you are in ~/src/zsh/Src/Builtins
# and want to go to ~/src/zsh. Just say up zsh. Or even just up z.
#
# And as a bonus, if you capture the output of up, it will print the
# directory you want, and not change to it. So you can do:
#
# mv foo.c $(up zsh)
# Taken from http://chneukirchen.org/blog/category/zsh.html

up() {
  local op=print
  [[ -t 1 ]] && op=cd # The test [[ -t 1 ]] checks whether stdout is a terminal
  case "$1" in
    '') up 1;;
    -*|+*) $op ~$1;;
    <->) $op $(printf '../%.0s' {1..$1});;
    *) local -a seg; seg=(${(s:/:)PWD%/*})
       local n=${(j:/:)seg[1,(I)$1*]}
       if [[ -n $n ]]; then
         $op /$n
       else
         print -u2 up: could not find prefix $1 in $PWD
         return 1
       fi
  esac
}

[[ $TERM = "dumb" ]] && unsetopt zle && PS1='$ '

# Persist directory stack across sessions
# Again from http://chneukirchen.org/blog/category/zsh.html
DIRSTACKSIZE=9
DIRSTACKFILE=~/.zdirs
if [[ -f $DIRSTACKFILE ]] && [[ $#dirstack -eq 0 ]]; then
  dirstack=( ${(f)"$(< $DIRSTACKFILE)"} )
  [[ -d $dirstack[1] ]] && cd $dirstack[1] && cd $OLDPWD
fi
chpwd() {
  print -l $PWD ${(u)dirstack} >$DIRSTACKFILE
}
