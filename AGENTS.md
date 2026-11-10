# Repository guidance / Repository 指引

- Keep the CLI free of font files, credentials, user-specific paths, and private inventory data.  
  CLI 不得包含字型檔、登入憑證、使用者專用路徑或私人清單資料。
- Never request, print, or persist a GitHub password, token, SSH private key, or one-time code. Authentication must stay inside the official `gh auth login` flow.  
  絕不可要求、輸出或保存 GitHub 密碼、token、SSH 私密金鑰或一次性代碼；登入必須留在官方 `gh auth login` 流程內。
- Preserve macOS-system and Homebrew font fingerprint exclusions. Never weaken them to filename-only matching.  
  必須保留 macOS 系統字型及 Homebrew 字型指紋排除，不得退化為只比對檔名。
- Keep `/Library/Fonts` opt-in and never copy `/System/Library/Fonts`.  
  `/Library/Fonts` 必須維持選用，亦不得複製 `/System/Library/Fonts`。
- Keep user-facing text interleaved in Traditional Chinese and English.  
  使用者訊息應維持繁體中文及英文交錯。
- Run `zsh -n bin/fontvault`, `bin/fontvault version`, and a dry run before release.  
  發佈前執行 `zsh -n bin/fontvault`、`bin/fontvault version` 及試跑。

