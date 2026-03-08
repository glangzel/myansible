#!/usr/bin/env bash

# 1. すでに動いている polybar プロセスをすべて終了させる
killall -q polybar

# 2. プロセスが完全に終了するまで待機する
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# 3. Polybarを起動（config内のバーの名前が "main" の場合）
# ログを出力しておくと、SoCのシミュレーションログを確認するのと同じ感覚でデバッグできて便利です
polybar 2>&1 | tee -a /tmp/polybar.log & disown

echo "Polybar launched..."
