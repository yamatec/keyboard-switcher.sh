# keyboard-switcher.sh
# 動作確認は ubuntu 24.04
#
#・自動実行時(--auto)＋保存情報あり：保存された情報で設定して静かに終了
#・自動実行時(--auto)＋保存情報なし：なにもせず静かに終了
#・手動実行時＋保存情報あり        ：GUIを開き保存された情報を表示
#・手動実行時＋保存情報なし        ：GUIを開く
#
# usキーボード、jpキーボードを任意に選択。選択した情報を解像度とあわせ保存。
# 削除を選ぶとレイアウト情報や自動実行のファイルを抹消するとても無害な作り。
#
#~/.config/keyboard_layouts/ 以下に「ホスト名＿解像度.conf」の設定ファイルを作って記憶。
#~/.config/autostart/keyboard-switcher.desktop を自動作成
#
#[ /usr/share/applications/keyboard-switcher.desktop ]
#[Desktop Entry]
#Name=キーボードレイアウト切替
#Exec=/usr/local/bin/keyboard-switcher.sh　←ここは環境にあわせてフルpathを！
#Type=Application
#Terminal=false
#Icon=input-keyboard
#Categories=Settings;Utility;
#
