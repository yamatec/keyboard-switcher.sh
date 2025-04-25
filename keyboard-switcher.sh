#!/bin/bash

# --- 実行モード判定 ---
AUTO_MODE=false

if [[ "$1" == "--auto" ]]; then
    AUTO_MODE=true
fi

# --- 設定保存先・識別情報取得 ---
CONFIG_DIR="$HOME/.config/keyboard_layouts"
AUTOSTART_DIR="$HOME/.config/autostart"
AUTOSTART_FILE="$AUTOSTART_DIR/keyboard-switcher.desktop"
CURRENT_UID=$(id -u)

mkdir -p "$CONFIG_DIR"
mkdir -p "$AUTOSTART_DIR"

resolution=$(xdpyinfo | grep dimensions | awk '{print $2}')
hostname=$(xprop -root | grep Xdpy | cut -d\" -f2 | cut -d@ -f2)

[[ -z "$resolution" ]] && resolution="unknown_resolution"
[[ -z "$hostname" ]] && hostname="unknown_host"

safe_id=$(echo "${hostname}_${resolution}" | tr -cs '[:alnum:]_-' '_')
CONFIG_FILE="$CONFIG_DIR/${safe_id}.conf"

# --- 現在のキーボードレイアウトを取得 ---
current_layout=$(setxkbmap -query | grep layout | awk '{print $2}')

# --- 自動モード: GUIなしで適用する ---
if $AUTO_MODE; then
    if [[ -f "$CONFIG_FILE" ]]; then
        saved_layout=$(cat "$CONFIG_FILE")
        if [[ "$saved_layout" == "us" || "$saved_layout" == "jp" ]]; then
            setxkbmap "$saved_layout"
            echo "[INFO] 自動実行: '${saved_layout}' を適用しました (${safe_id})"
            if ! ps -u $CURRENT_UID -o comm | grep -q "^fcitx5$"; then
                fcitx5 -d
            fi
            exit 0
        fi
    fi
    echo "[INFO] 自動実行: 設定が見つからなかったため変更なし"
    exit 0
fi

# --- 手動実行: GUIで選択 ---
us_selected=FALSE
jp_selected=FALSE

if [[ -f "$CONFIG_FILE" ]]; then
    saved_layout=$(cat "$CONFIG_FILE")
    if [[ "$saved_layout" == "us" ]]; then
        us_selected=TRUE
    elif [[ "$saved_layout" == "jp" ]]; then
        jp_selected=TRUE
    fi
else
    if [[ "$current_layout" == "jp" ]]; then
        jp_selected=TRUE
    else
        us_selected=TRUE
    fi
fi

layout=$(zenity --list \
    --title="キーボードレイアウトの選択" \
    --text="使用するキーボードレイアウトを選んでください\n(端末: ${hostname}, 解像度: ${resolution})" \
    --radiolist \
    --column="選択" --column="レイアウト" \
    $us_selected "us (英語)" \
    $jp_selected "jp (日本語)" \
    FALSE "削除（設定をリセット）")

# --- ユーザーが削除を選択した場合 ---
if [[ "$layout" == "削除（設定をリセット）" ]]; then
    zenity --question --title="設定削除" --text="自動実行設定とキーボード設定を削除しますか？"
    if [[ $? -eq 0 ]]; then
        rm -f "$AUTOSTART_FILE"
        rm -rf "$CONFIG_DIR"
        zenity --info --text="削除が完了しました。"
        echo "[INFO] 削除が完了しました。"
    else
        echo "[INFO] 削除をキャンセルしました。"
    fi
    exit 0
fi

# --- キーボードレイアウトの適用 ---
if [[ "$layout" == "us (英語)" ]]; then
    setxkbmap us
    echo "us" > "$CONFIG_FILE"
    if ! ps -u $CURRENT_UID -o comm | grep -q "^fcitx5$"; then
        fcitx5 -d
    fi
elif [[ "$layout" == "jp (日本語)" ]]; then
    setxkbmap jp
    echo "jp" > "$CONFIG_FILE"
    if ! ps -u $CURRENT_UID -o comm | grep -q "^fcitx5$"; then
        fcitx5 -d
    fi
else
    zenity --info --text="レイアウトが選択されませんでした。"
    exit 1
fi

# --- 自動起動用のデスクトップエントリーを作成 ---
# Exec行はスクリプト配置により適宜書き換え /usr/local/bin/ 推奨
cat <<EOF > "$AUTOSTART_FILE"
[Desktop Entry]
Type=Application
Exec=$HOME/keyboard-switcher.sh --auto
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

zenity --info --text="設定内容を保存し自動実行を設定しました (${AUTOSTART_FILE})"
echo "[INFO] 設定内容を保存し自動実行を設定しました (${AUTOSTART_FILE})"
