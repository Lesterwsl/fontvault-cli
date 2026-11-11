# fontvault

`fontvault` is a macOS CLI for backing up personal fonts, Homebrew package lists, and an application-name inventory to a private Git repository.  
`fontvault` 是 macOS CLI，可把個人字型、Homebrew 套件清單及應用程式名稱清單備份至私人 Git repository。

It deliberately excludes macOS-managed and Homebrew-managed font binaries. Homebrew font casks are saved as reinstall commands instead.  
它會排除 macOS 與 Homebrew 管理的字型二進位檔，並改為保存 Homebrew 字型 cask 的重裝指令。

## What is backed up / 會備份甚麼

| Item / 項目 | Backup behavior / 備份方式 |
|---|---|
| Personal fonts in `~/Library/Fonts` / `~/Library/Fonts` 的個人字型 | The actual `.ttf`, `.ttc`, `.otf`, `.otc`, and `.dfont` files are copied after macOS, Homebrew, duplicate, empty, and unreadable files are excluded. / 排除 macOS、Homebrew、重複、空白及無法讀取的檔案後，複製實際字型檔。 |
| Shared fonts in `/Library/Fonts` / `/Library/Fonts` 的共用字型 | Not included by default; copied only with `--include-shared` or an enabled setting. / 預設不包含；只有使用 `--include-shared` 或啟用設定時才複製。 |
| Homebrew / Homebrew | A restorable `Brewfile`, a font-cask-only Brewfile, and a readable package/version list are saved. Homebrew font binaries are not copied. / 保存可還原的 `Brewfile`、只含字型 cask 的 Brewfile，以及易讀套件與版本清單；不複製 Homebrew 字型檔。 |
| Applications / 應用程式 | Names, versions, and detected sources from `/Applications` and `~/Applications` are saved as Markdown. App bundles are not copied. / 將 `/Applications` 與 `~/Applications` 的名稱、版本及偵測來源保存為 Markdown；不複製 app bundle。 |
| Font manifests / 字型清單 | SHA-256 hashes, classification results, and Homebrew font reinstall commands are saved. / 保存 SHA-256、分類結果及 Homebrew 字型重裝指令。 |

### What is not backed up / 不會備份甚麼

- macOS-managed font binaries and everything in `/System/Library/Fonts`; matching copies found in user locations are also excluded.<br>
  macOS 管理的字型檔及 `/System/Library/Fonts` 內所有內容均不會備份；使用者位置中的相同副本亦會排除。
- Homebrew-managed font binaries; the relevant cask reinstall commands are saved instead.<br>
  Homebrew 管理的字型檔不會備份，改為保存相關 cask 重裝指令。
- Application binaries, application data, preferences, documents, system applications, and iCloud data.<br>
  不會備份應用程式本體、app 資料、偏好設定、文件、系統應用程式或 iCloud 資料。
- Passwords, GitHub tokens, SSH private keys, cookies, one-time codes, or other credentials.<br>
  不會保存密碼、GitHub token、SSH 私密金鑰、cookie、一次性代碼或其他憑證。

## Install on this Mac / 在目前的 Mac 安裝

```bash
brew install Lesterwsl/tap/fontvault
fontvault setup --account Lesterwsl --repo-name mac-font-backup
fontvault doctor
```

## Commands / 指令

Running `fontvault` without arguments opens its interactive terminal menu. Arrow keys and `j/k` navigate, Enter selects, and `q` exits.<br>
不帶參數執行 `fontvault` 會開啟互動式終端選單；可使用方向鍵或 `j/k` 移動、Enter 選擇、`q` 離開。

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
fontvault doctor                    # validate dependencies, Git, and repository access
```

## Progress and change review / 進度與變更檢查

Every manual backup and preview reports its current phase, from environment checks through Homebrew, application, system-font, and personal-font scanning, so a longer scan does not look frozen.<br>
每次手動備份及預覽都會顯示目前階段，包括環境檢查、Homebrew、應用程式、系統字型及個人字型掃描，因此較長的掃描不會看似停頓。

Before anything is written, fontvault compares the proposed snapshot with the previous backup. Personal fonts, Homebrew formulae, Homebrew casks, and applications have separate added, removed, and changed counts followed by complete, untruncated detail lists. Version changes show old → new, and font-content changes are reported by path. It also shows the number of generated files that differ and the old/new font-data size.<br>
寫入任何資料前，fontvault 會將新快照與上次備份比較。個人字型、Homebrew formula、Homebrew cask 及應用程式會分別顯示新增、移除及變更數量，並列出完整且不截斷的詳情；版本變更會顯示舊版 → 新版，字型內容變更則按路徑列出。畫面亦會顯示有差異的產生檔案數目，以及字型資料的新舊大小。

In preview output, “removed” means the item existed in the previous snapshot but is absent from the current Mac, so it would be removed from the next snapshot. Preview never uninstalls a package or deletes a font.<br>
在預覽結果中，「移除」代表該項目存在於上次快照、但目前 Mac 已沒有，因此下次快照會把它移出清單；預覽不會解除安裝套件或刪除字型。

Interactive backups ask for confirmation after this comparison. Non-interactive backup calls are rejected unless the caller explicitly supplies `--yes`. Fontvault does not install or manage background jobs; backups run only when the user or an explicitly configured external caller starts one.<br>
互動備份會在顯示比較結果後才詢問確認；非互動備份若未明確加入 `--yes` 便會拒絕執行。Fontvault 不會安裝或管理背景工作；只有使用者或明確設定的外部呼叫端啟動時才會備份。

## New Mac setup / 新 Mac 設定

No password, token, SSH private key, or one-time login code is stored in the CLI, tap, configuration, or backup repository. The GitHub username and repository name are safe to provide as command arguments.<br>
CLI、tap、設定及備份 repository 都不會保存密碼、token、SSH 私密金鑰或一次性登入代碼；GitHub 使用者名稱及 repository 名稱則可安全作為指令參數。

On a new Mac, first install Homebrew from [brew.sh](https://brew.sh/), then run:<br>
在新 Mac 上，先從 [brew.sh](https://brew.sh/) 安裝 Homebrew，再執行：

```bash
brew install Lesterwsl/tap/fontvault
fontvault setup --account Lesterwsl --repo-name mac-font-backup
fontvault doctor
fontvault status
fontvault restore all
```

`fontvault` installs GitHub CLI and the other required command-line dependencies through the Homebrew formula. `fontvault setup` then checks the tools, starts the official browser-based `gh auth login` flow if needed, verifies private-repository access, and asks before cloning. `doctor` and `status` let you review the new Mac before the separate `restore all` confirmation.<br>
Homebrew formula 會連同 GitHub CLI 及其他必要指令工具安裝 `fontvault`。之後 `fontvault setup` 會檢查工具、需要時啟動官方瀏覽器 `gh auth login` 流程、驗證私人 repository 權限，並在 clone 前詢問。你可先用 `doctor` 及 `status` 檢查新 Mac，再於獨立的 `restore all` 確認中開始還原。

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

The backup also stops safely for an active backup process, unresolved Git conflicts, insufficient temporary disk space, files of 100 MB or more, and a remote branch that contains commits missing locally. The lock records its owning process and is automatically recovered if that process no longer exists. If the network or credentials fail after a commit, the local commit is retained for a later push.<br>
遇到仍在執行的備份程序、未解決 Git 衝突、臨時空間不足、單檔達 100 MB，或遠端含本機沒有的 commit 時，備份會安全停止。鎖定會記錄所屬程序；若該程序已不存在，便會自動復原。若 commit 後網路或憑證失敗，本機 commit 會保留，供稍後再次 push。

