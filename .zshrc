alias vim='nvim'
alias vi='vi'
alias gs='git status'
alias gla='git log --all --oneline --graph'
alias gl='git log --oneline --graph'

# 1. Vi motion in terminal
bindkey -v

# 2. Prevent Ctrl+D from disconnecting the session
setopt IGNORE_EOF

# 3. Save history immediately after each command (Native Zsh execution)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# 4. Allow coredump (Note: macOS stores these securely in /cores/)
ulimit -c unlimited

# 5. Advanced Globbing & Matching
# Zsh has recursive globbing (**/) and extglob equivalents turned on natively.
# Enabling EXTENDED_GLOB unlocks advanced pattern exclusions.
setopt EXTENDED_GLOB

# 6. Native Git Branch in Prompt (vcs_info)
# This line tells Zsh to dynamically evaluate variables inside the prompt string
setopt prompt_subst

autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats ' (%b)'

# Configure the prompt look (Green User/Host, Blue working directory)
# We can use a clean literal newline right inside the single quotes instead of a variable
PROMPT='%F{green}%n%f:%F{blue}%~%f${vcs_info_msg_0_}
%% '

export RUST_BACKTRACE=1
# export RUST_BACKTRACE=full

source <(fzf --zsh)
#
# 7. Auto-start or attach to tmux
if [[ -z "$TMUX" && -n "$PS1" ]] && command -v tmux &>/dev/null; then
    exec tmux new-session -A -s main
fi
