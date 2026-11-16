"""起動直後のエミュレータが落ち着くまで待つ（最大 300 秒・これ自体はジョブを落とさない）。

2026-11-15 以降、起動直後に "Process system isn't responding" /
"Pixel Launcher isn't responding" が出て、そのまま監査がホームへ入れない回が
大半になった（ubuntu-24.04/26.04・エミュレータ 37.1.11/37.2.13・Flutter
3.47.5/3.47.9 のどれでも起きた・11 回中 3 回だけ成功）。システムが固まって
いる最中にアプリを開くのをやめ、次の状態が 30 秒続くのを待ってから開く:
起動完了・前面の窓がある・「応答していません」の窓が出ていない。

確かめるたびに HOME を押す。入力を送らないと、固まったランチャーは ANR を
出さないことがあり「静か」と「応答している」を取り違える。

ANR のダイアログは BACK では消えない（AOSP android14
AppNotRespondingDialog.java の setCancelable(false)）。監査と同じく
「待機」ボタンを押す。
"""
import os
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from a11y_device_audit import adb, dump, parse, is_system_dialog, dismiss_dialog, anr_detail  # noqa: E402

LIMIT = 300
CALM_NEEDED = 6  # 5 秒おき＝30 秒


def focus():
    for ln in adb('shell', 'dumpsys', 'window').splitlines():
        if 'mCurrentFocus' in ln:
            return ln.strip()
    return ''


def main():
    start = time.time()
    calm = 0
    dialogs = 0
    f = ''
    while time.time() - start < LIMIT:
        boot = adb('shell', 'getprop', 'sys.boot_completed').strip()
        adb('shell', 'input', 'keyevent', 'KEYCODE_HOME')
        time.sleep(2)
        f = focus()
        xml = dump()
        ns = parse(xml)[0] if xml else []
        stalled = 'not responding' in f.lower() or (ns and is_system_dialog(ns))
        if stalled:
            dialogs += 1
            print('settle: %3d 秒: %s' % (time.time() - start, f))
            if dialogs == 1:
                anr_detail(ns)
            dismiss_dialog(ns)
            calm = 0
        elif boot == '1' and f and 'null' not in f and xml:
            calm += 1
        else:
            calm = 0
        if calm >= CALM_NEEDED:
            print('settle: %d 秒で 30 秒続けて落ち着いた（ANR ダイアログ %d 回・load %s）'
                  % (time.time() - start, dialogs, adb('shell', 'cat', '/proc/loadavg').strip()))
            return 0
        time.sleep(3)
    print('::warning::settle: %d 秒以内に落ち着かなかった（ANR ダイアログ %d 回・最後の前面 %s・load %s）。そのまま続ける'
          % (LIMIT, dialogs, f, adb('shell', 'cat', '/proc/loadavg').strip()))
    return 0


if __name__ == '__main__':
    sys.exit(main())
