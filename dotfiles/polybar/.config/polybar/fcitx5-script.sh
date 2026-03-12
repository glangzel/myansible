#!/bin/bash

# fcitx5-remote を使って現在の入力メソッド名を取得
INPUT=$(fcitx5-remote -n)

if [[ "$INPUT" == "keyboard-br" ]]; then
    echo "PT-BR"
elif [[ "$INPUT" == "mozc" ]]; then
    echo "Mozc"
elif [[ -z "$INPUT" ]]; then
    echo "NONE"
else
    # その他の入力（usなど）があればそのまま表示、または "OTHER" と出す
    echo "$INPUT"
fi

