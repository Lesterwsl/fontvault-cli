# fontvault

`fontvault` is a macOS CLI for backing up personal fonts, Homebrew package lists, and an application-name inventory to a private Git repository.  
`fontvault` 是 macOS CLI，可把個人字型、Homebrew 套件清單及應用程式名稱清單備份至私人 Git repository。

It deliberately excludes macOS-managed and Homebrew-managed font binaries. Homebrew font casks are saved as reinstall commands instead.  
它會排除 macOS 與 Homebrew 管理的字型二進位檔，並改為保存 Homebrew 字型 cask 的重裝指令。

## Install / 安裝

```bash
brew install Lesterwsl/tap/fontvault
fontvault setup --account Lesterwsl --repo-name mac-font-backup
fontvault doctor
```

## Commands / 指令

Running `fontvault` without arguments opens an interactive terminal menu inspired by the clear navigation and preview-first safety style of tools such as [Mole](https://github.com/tw93/mole). Arrow keys and `j/k` navigate, Enter selects, and `q` exits. The implementation and branding are original to fontvault.  
不帶參數執行 `fontvault` 會開啟互動式終端選單；設計參考 [Mole](https://github.com/tw93/mole) 清楚導航及先預覽再執行的安全風格。可使用方向鍵或 `j/k` 移動、Enter 選擇、`q` 離開；實作與品牌均為 fontvault 原創。

```bash
fontvault                           # interactive menu
fontvault backup                    # snapshot, commit, and push
fontvault backup --dry-run          # classify without changing the repository
fontvault status                    # show current backup and Git state
fontvault apps                      # print the application inventory
fontvault homebrew                  # print the Homebrew inventory
fontvault restore fonts             # restore Homebrew font casks and personal fonts
fontvault restore homebrew          # install the full saved Brewfile
fontvault restore all               # restore the Brewfile and personal fonts
fontvault schedule --daily 03:00    # install the daily LaunchAgent
fontvault unschedule                # remove the LaunchAgent
fontvault logs                      # show the latest automatic-backup log
fontvault doctor                    # validate dependencies, Git, and schedule
```

## New Mac setup / 新 Mac 設定

No password, token, SSH private key, or one-time login code is stored in the CLI, tap, configuration, or backup repository. The GitHub username and repository name are safe to provide as command arguments.  
CLI、tap、設定及備份 repository 都不會保存密碼、token、SSH 私密金鑰或一次性登入代碼；GitHub 使用者名稱及 repository 名稱則可安全作為指令參數。

On a new Mac, first install Homebrew from [brew.sh](https://brew.sh/), then run:  
在新 Mac 上，先從 [brew.sh](https://brew.sh/) 安裝 Homebrew，再執行：

```bash
brew install Lesterwsl/tap/fontvault
fontvault setup --account Lesterwsl --repo-name mac-font-backup
```

`fontvault setup` checks Homebrew, Git, GitHub CLI, `jq`, authentication, private-repository access, and the destination path. If GitHub authentication is missing, it offers to start the official browser-based `gh auth login` flow; the password is entered only through GitHub's own secure interface. It clones the private repository only after confirmation and does not start restoration automatically.  
`fontvault setup` 會檢查 Homebrew、Git、GitHub CLI、`jq`、登入狀態、私人 repository 存取權及目的路徑。若尚未登入，它只會詢問是否啟動官方瀏覽器 `gh auth login` 流程；密碼只會在 GitHub 自己的安全介面輸入。程式會先取得確認才 clone 私人 repository，亦不會自動開始還原。

Review the environment and restore plan before making changes:  
實際變更前先檢查環境及還原計劃：

```bash
fontvault doctor
fontvault status
fontvault restore all
```

## Classification / 分類方式

- System-managed fonts are fingerprinted from `/System/Library/Fonts`, `/System/Library/AssetsV2`, and the system FontServices framework. Matching copies are excluded.  
  系統字型會從 `/System/Library/Fonts`、`/System/Library/AssetsV2` 及系統 FontServices framework 建立指紋；相同副本會被排除。
- Homebrew font casks are detected from cask metadata. Installed targets and font files in Caskroom are fingerprinted and excluded.  
  Homebrew 字型會從 cask metadata 辨識，並以安裝目標及 Caskroom 字型檔指紋排除。
- Remaining supported font files in `~/Library/Fonts` are backed up as personal fonts. `/Library/Fonts` remains opt-in.  
  `~/Library/Fonts` 中其餘支援的字型會視為個人字型；`/Library/Fonts` 仍需明確啟用。

Supported extensions are `.ttf`, `.ttc`, `.otf`, `.otc`, and `.dfont`.  
支援 `.ttf`、`.ttc`、`.otf`、`.otc` 及 `.dfont`。

## Data repository / 資料 repository

Generated data is written below `font-backup-data/` in the configured private repository:  
產生的資料會寫入已設定私人 repository 的 `font-backup-data/`：

```text
font-backup-data/
├── applications/applications.md
├── fonts/user/
├── homebrew/Brewfile
├── homebrew/Brewfile.fonts
├── homebrew/homebrew.md
└── manifests/
    ├── font-classification.md
    ├── fonts.tsv
    └── macos-system-fonts.tsv
```

Only generated backup data is staged automatically; unrelated repository changes are never included.  
自動 commit 只會 stage 產生的備份資料，不會包含其他 repository 變更。

## Conflict handling / 衝突處理

Interactive restores ask before changing an existing font or installed Homebrew package. Choices include keeping, overwriting or reinstalling, applying the choice to all remaining conflicts, or cancelling.  
互動還原遇到現有字型或已安裝 Homebrew 套件時會先詢問；可選擇保留、覆蓋／重裝、套用至其餘衝突或取消。

Identical font files are skipped automatically because no change is required. Non-interactive restores use the safe default and keep existing items:  
完全相同的字型會自動略過，因為不需要變更；非互動還原採用安全預設並保留現有項目：

```bash
fontvault restore all --non-interactive
```

The backup also stops safely for unresolved Git conflicts, insufficient temporary disk space, files of 100 MB or more, and a remote branch that contains commits missing locally. If the network or credentials fail after a commit, the local commit is retained for a later push.  
遇到未解決 Git 衝突、臨時空間不足、單檔達 100 MB，或遠端含本機沒有的 commit 時，備份會安全停止；若 commit 後網路或憑證失敗，本機 commit 會保留，供稍後再次 push。

