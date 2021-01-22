# git ブランチ名を色付きで表示させるメソッド
function rprompt-git-current-branch {
  local branch_name st branch_status
  if [ ! -e ".git"  ]; then
    # git 管理されていないディレクトリは何も返さない
    return
  fi
  branch_name=`git rev-parse --abbrev-ref HEAD 2> /dev/null`
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"`  ]]; then
    # 全て commit されてクリーンな状態
    branch_status="%F{green}"
  elif [[ -n `echo "$st" | grep "^Untracked files"`  ]]; then
    # git 管理されていないファイルがある状態
    branch_status="%F{red}?"
  elif [[ -n `echo "$st" | grep "^Changes not staged for commit"`  ]]; then
    # git add されていないファイルがある状態
    branch_status="%F{red}+"
  elif [[ -n `echo "$st" | grep "^Changes to be committed"`  ]]; then
    # git commit されていないファイルがある状態
    branch_status="%F{yellow}!"
  elif [[ -n `echo "$st" | grep "^rebase in progress"`  ]]; then
    # コンフリクトが起こった状態
    echo "%F{red}!(no branch)"
    return
  else
    # 上記以外の状態の場合
    branch_status="%F{blue}"
  fi
  # ブランチ名を色付きで表示する
  echo "${branch_status}[$branch_name]"
}
# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
# プロンプトの右側にメソッドの結果を表示させる
RPROMPT='`rprompt-git-current-branch`'
# tmuxにセッションがなかったら新規セッションを立ち上げた際に分割処理設定を読み込む
alias tmux="tmux -2 new-session \; source-file ~/.tmux/new-session"
# history増加
alias history='history -500'
# dirs複数業表示
alias dirs='dirs -v'
# pushdのキーストロークを減らす
alias pd='pushd'
# pdsでpeco移動
function pds() {
  # peco が無ければ何もしない
  ! which peco >/dev/null 2>&1 && echo 'please install peco' 1>&2 && return 1
  # dirs -v の結果を peco でフィルタリングして、キューの番号を取得
  local pushd_number=$(dirs -v | peco | perl -anE 'say $F[0]')
  # peco が強制終了されたら何もしない
  [[ -z $pushd_number ]] && return 1
  # 移動
  pushd +$pushd_number
  return $?
}
