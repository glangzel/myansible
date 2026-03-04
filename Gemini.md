# Ubuntu 24.04 Lightweight Dev Environment Setup

## 1. 概要と目標

* **ベースOS**: Ubuntu Server 24.04 (Noble Numbat) を最小インストール。
* **コンセプト**: 安定性と軽快なフットプリントの両立。
* **デスクトップ環境**: i3wm (タイル型ウィンドウマネージャ) を中心とした構成。
* **デザイン**: Gruvboxカラーを基調としたダークテーマ。
* **ユーザー**: SoC System Development所属のエンジニア（Python 3経験あり）。

## 2. コアコンポーネント

| カテゴリ | パッケージ | 役割 |
| --- | --- | --- |
| **Window Manager** | `i3-wm` | メインのデスクトップ環境。 |
| **Status Bar** | `polybar` | 画面上部のステータス表示。 |
| **Launcher** | `rofi` | アプリ起動・モード切替。 |
| **Display Manager** | `lightdm` | ログインマネージャ。 |
| **IME** | `fcitx5-mozc` | 日本語入力（Fcitx5 frontend各種含む）。 |
| **Utility** | `picom`, `feh` | コンポジタ、壁紙設定。 |
| **Laptop Power** | `tlp`, `brightnessctl` | 電源管理、バックライト制御。 |

## 3. 設定のポイント

### i3wm (`~/.config/i3/config`)

* `gaps inner 10`, `gaps outer 5` でウィンドウ間に隙間を確保。
* Gruvboxカラー（`#282828`, `#d79921`等）を定義して境界線に適用。
* `exec --no-startup-id fcitx5 -d` でIMEを自動起動。

### Rofi (`~/.config/rofi/config.rasi`)

* `dmg_blue` ライクなオレンジ（`#d79921`）のハイライトを適用。

### 日本語入力 (Fcitx5)

* 環境変数 (`GTK_IM_MODULE`等) を `~/.xprofile` に記述。
* `im-config -n fcitx5` でシステムに反映。

## 4. トラブルシューティングの記録

* **事象**: `lightdm-webkit2-greeter` の不足、または不適合によりLightDMが起動ループに陥った。
* **解決策**:
1. `lightdm-gtk-greeter` を導入し、`/etc/lightdm/lightdm.conf` で指定。
2. これによりGUIログインが可能になり、X11およびi3wmの正常起動を確認。




## 5. 自動化のロードマップ (Ansible + GNU Stow)


保守性を高めるため、以下の手法で管理する。


* **Ansible**: `roles/` 分割により「drivers」「desktop」「japanese」等の単位で構成を管理。
* **GNU Stow**: `~/setup-ansible/dotfiles/` から `~/.config/` へシンボリックリンクを貼り、設定ファイルの変更を容易にする。
* **一発設定コマンド**:
`sudo ansible-pull -U <GitHub_URL>` で、OSインストール直後の環境を完全再現。

### ディレクトリ構成
```
~/setup-ansible/
├── site.yml                # メインの実行ファイル
├── group_vars/
│   └── all.yml             # 共通変数（ユーザー名など）
├── roles/

│   ├── common/             # 基本ツール
│   ├── drivers/            # ノートPC・ハードウェア関連
│   ├── desktop/            # i3, Polybar, Rofi, LightDM
│   ├── japanese/           # Fcitx5, Mozc
│   └── dotfiles/           # GNU Stowによる設定反映
└── dotfiles/               # 実際の設定ファイル群（Stow対象）
    ├── i3/                 # ~/.config/i3/config 等
    ├── polybar/
    └── rofi/
```
