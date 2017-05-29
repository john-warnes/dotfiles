# Tmux alias
alias tmux='tmux -2'
alias ta='tmux attach -t'
alias tnew='tmux new -s'
alias tls='tmux ls'
alias tkill='tmux kill-session -t'

# conveience alias for editing configs
alias ev='vim ~/.vimrc'
alias et='vim ~/.tmux.conf'
alias ez='vim ~/.zshrc'


# ls alias
alias ls='ls -GFh'
alias ll='ls -GFhl'
alias la='ls -GFha'
alias lr='ls -Gfhlrt'

# Development alias
alias gcc='gcc -std=c11 -Wall'
alias mpicc='mpicc-mpich-mp'
alias mysqlstart='sudo /opt/local/bin/mysqld_safe5 &'
alias mysqlstop='/opt/local/bin/mysqladmin5 -u root -p shutdown'

# ssh alias
alias icarus='ssh -X -Y hvalle@icarus.cs.weber.edu'
alias zlinux='ssh -X -Y wsui001@192.86.33.17'
alias zUNIX='ssh -X -Y wsui001@192.86.32.17'
alias mmf='ssh -X -Y us00139@192.86.32.178'
alias atlas='ssh -X -Y hvalle@tier3-atlas3.bellarmine.edu'
alias coeus='ssh -X -Y hvalle@137.190.19.22'

#Colorize GCC output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

