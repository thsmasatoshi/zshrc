# gitのブランチ表示
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git svn
zstyle ':vcs_info:*' max-exports 6 # formatに入る変数の最大数
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' formats '%b@%r' '%c' '%u'
zstyle ':vcs_info:git:*' actionformats '%b@%r|%a' '%c' '%u'
setopt prompt_subst
function vcs_echo {
    local st branch color
    STY= LANG=en_US.UTF-8 vcs_info
    st=`git status 2> /dev/null`
    if [[ -z "$st" ]]; then return; fi
    branch="$vcs_info_msg_0_"
    if   [[ -n "$vcs_info_msg_1_" ]]; then color=${fg[green]} #staged
    elif [[ -n "$vcs_info_msg_2_" ]]; then color=${fg[red]} #unstaged
    elif [[ -n `echo "$st" | grep "^Untracked"` ]]; then color=${fg[blue]} # untracked
    else color=${fg[cyan]}
    fi
    echo "%{$color%}(%{$branch%})%{$reset_color%}" | sed -e s/@/"%F{yellow}@%f%{$color%}"/
}
PROMPT='
%F{yellow}[%~]%f `vcs_echo`
%(?.$.%F{red}$%f) '
# or use pre_cmd, see man zshcontrib
vcs_info_wrapper() {
  vcs_info
  if [ -n "$vcs_info_msg_0_" ]; then
    echo "%{$fg[grey]%}${vcs_info_msg_0_}%{$reset_color%}$del"
  fi
}
RPROMPT=$'$(vcs_info_wrapper)'

# zplug
source ~/.zplug/init.zsh
zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# zsh-git-prompt用の設定
source /usr/local/opt/zsh-git-prompt/zshrc.sh
PROMPT='%B%m%~%b$(git_super_status) %# '

# theme (https://github.com/sindresorhus/pure#zplug)
zplug "sindresorhus/pure"

# enhanced
zplug "b4b4r07/enhancd", use:init.sh

# history関係
zplug "zsh-users/zsh-history-substring-search"

# oh-my-zshのgitエイリアス系
zplug "plugins/git",   from:oh-my-zsh

# タイプ補完
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "chrissicool/zsh-256color"

# emojiを有効にする
zplug "stedolan/jq", \
    from:gh-r, \
    as:command, \
    rename-to:jq
zplug "b4b4r07/emoji-cli", \
    on:"stedolan/jq"

# fzf fzf-bin にホスティングされているので注意
# またファイル名が fzf-bin となっているので fzf としてリネームする
zplug "junegunn/fzf-bin", as:command, from:gh-r, rename-to:fzf

# 必要ならばアーキテクチャ指定
zplug "peco/peco", as:command, from:gh-r

# プラグイン未インストール時に聞く
if ! zplug check --verbose; then
  printf "これ入れます？どうします？ [y/N]: "
  if read -q; then
    echo; zplug install
  fi
fi

# anyframe リビジョン固定
zplug "mollifier/anyframe", at:4c23cb60

# GOPATH, GOROOT
export GOPATH=$HOME/go
export GOROOT=$HOME/homebrew/opt/go/libexec

export PATH="$GOPATH/bin:$PATH"
export PATH="$GOROOT/bin:$PATH"

# alias
alias restart='exec $SHELL -l'

#zstyle
# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を詰めて表示
setopt list_packed
# 補完候補一覧をカラー表示
zstyle ':completion:*' list-colors ''

# nvm 環境変数
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# 読み込み順序を設定して構文ハイライトを読み込み（2 以上は compinit 後に読み込まれるようになる）
zplug "zsh-users/zsh-syntax-highlighting", defer:2

# コマンドをリンクして、PATH に追加し、プラグインは読み込む
zplug load --verbose
