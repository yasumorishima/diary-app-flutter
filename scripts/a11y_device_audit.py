#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""動いているアプリが Android の読み上げ機構へ何を渡しているかを、実機（エミュレータ）で測る。

`test/a11y_names_test.dart` は **ソースを読んだ静的な掃引**なので、
「実際に画面へ出たときにどうなるか」は保証しない。ここでは
`uiautomator dump` で **実行中のアプリのアクセシビリティノードツリー**を取り、
押せるノードに名前（content-desc / text）が入っているかを数える。
uiautomator 自身がアクセシビリティのクライアントなので、これを繋ぐと Flutter は
TalkBack のときと同じセマンティクスを生成する＝読み上げが受け取るのと同じデータ。

ホームを起点に、押せるノードを 1 つずつ叩いて 1 段先の画面へ入り、
戻ってまた次、という総当たりで回る（画面名を決め打ちしないので、
表示言語が変わっても・画面が増えても効く）。

数え方の 3 区分（1 回目の走行で分かったこと）:
- **アプリのノード** … 名前が空なら落とす
- **広告（`android.webkit.WebView` 配下）** … AdMob の SDK が描く中身で
  こちらから名前を付けられない。除外して件数だけ出す
- **`android.widget.EditText`** … `uiautomator dump` は `hintText` を出さないので、
  空欄の入力欄は content-desc も text も空に見える。**dump だけでは判定できない**ので
  落とさず、周りのノードの名前を並べて後から人が読めるようにする。
  このアプリの入力欄 3 つ（書くの本文・タグ、さがすの入力欄）については
  `test/a11y_hint_test.dart` で決着済み＝`hintText` は Flutter のセマンティクスの
  **label** に入る（実測 label="きょうは どんな 日でしたか？" / hint="" / value=""）。
  **「読み上げへ何も渡していない」ではない**。ここで空に見えるのは
  dump が `hintText` を出力しないから

空回りの検知は **ホーム単体のノード数**で行う（2 回目の走行で、起動直後の ANR
ダイアログを「ホーム」として巡回したのに、合計 22 個がしきい値 20 を超えて
success で終わった。合計はあとの画面で水増しされる）。

前面がどのアプリかは **dump の XML が持つ `package` 属性**で見る（3 回目の走行で
`dumpsys window displays` の正規表現が Android 14 に一致せず、前面が常に空文字に
なっていた＝判定そのものが壊れていた）。
"""
import re
import subprocess
import sys
import time
import xml.etree.ElementTree as ET
from collections import Counter

PKG = 'com.diary.daily'
ACTIVITY = '%s/.MainActivity' % PKG
BOUNDS = re.compile(r'\[(\d+),(\d+)\]\[(\d+),(\d+)\]')
HOME_MIN = 10        # ホームでこれだけ押せるものが見えなければ、監査が始まっていない
LAUNCH_TRIES = 3
LAUNCH_BUDGET = 120  # 秒

WAIT_WORDS = {'Wait', '待機'}
ANR_WORDS = {'Close app', 'アプリを終了', "isn't responding", '応答していません',
             'Application not responding'}
SKIP_WORDS = {'Skip', 'スキップ', 'Start', 'はじめる', 'Get started'}


def adb(*args):
    return subprocess.run(('adb',) + args, capture_output=True, text=True).stdout


def dump():
    for _ in range(4):
        out = adb('shell', 'uiautomator', 'dump', '/sdcard/ui.xml')
        if 'dumped to' in out or 'hierchary' in out or 'hierarchy' in out:
            xml = adb('shell', 'cat', '/sdcard/ui.xml')
            if xml.lstrip().startswith('<?xml'):
                return xml
        time.sleep(2)
    return None


def parse(xml):
    try:
        root = ET.fromstring(xml)
    except ET.ParseError as e:
        print('XML を読めなかった: %s' % e)
        return [], {}
    parent = {}
    for p in root.iter():
        for c in p:
            parent[c] = p
    return list(root.iter('node')), parent


def pkg_of(ns):
    """前面のアプリ。dump のノードが持つ package 属性の最頻値で見る。"""
    c = Counter(n.get('package') for n in ns if n.get('package'))
    return c.most_common(1)[0][0] if c else ''


def name_of(n):
    return (n.get('content-desc') or '').strip() or (n.get('text') or '').strip()


def center(n):
    m = BOUNDS.match(n.get('bounds') or '')
    if not m:
        return None
    x1, y1, x2, y2 = (int(v) for v in m.groups())
    if x2 - x1 < 8 or y2 - y1 < 8:
        return None
    return (x1 + x2) // 2, (y1 + y2) // 2


def in_webview(n, parent):
    cur = n
    while cur is not None:
        if (cur.get('class') or '') == 'android.webkit.WebView':
            return True
        cur = parent.get(cur)
    return False


def neighbours(n, parent):
    p = parent.get(n)
    if p is None:
        return []
    out = []
    for sib in p.iter('node'):
        nm = name_of(sib)
        if nm and sib is not n:
            out.append('%s=%r' % (sib.get('class', '?').split('.')[-1], nm[:40]))
    return out[:6]


def app_clickables(ns, parent):
    return [n for n in ns
            if n.get('clickable') == 'true' and center(n) and not in_webview(n, parent)]


def tap(xy):
    adb('shell', 'input', 'tap', str(xy[0]), str(xy[1]))
    time.sleep(3)


def back():
    adb('shell', 'input', 'keyevent', '4')
    time.sleep(2)


def is_system_dialog(ns):
    names = {name_of(n) for n in ns if name_of(n)}
    return bool(names & ANR_WORDS or names & WAIT_WORDS)


def dismiss_dialog(ns):
    """ANR（応答していません）等が出ていたら「待機」を押す。"""
    for n in ns:
        if name_of(n) in WAIT_WORDS and center(n):
            tap(center(n))
            return True
    back()
    return False


def maybe_skip_onboarding(ns):
    for n in ns:
        if name_of(n) in SKIP_WORDS and center(n):
            tap(center(n))
            return True
    return False


def screen_key(ns):
    return tuple(sorted({name_of(n) for n in ns if name_of(n)}))[:12]


def anr_detail(ns):
    """ダイアログの中身と、system が記録した ANR の相手を出す。

    回数だけでは「誰が応答していないのか」が分からず原因を推測でしか追えない
    （2026-09-02 実測: 「ANR ダイアログ 13 回」とだけ出て中身が無かった）。
    """
    names = sorted({name_of(n) for n in ns if name_of(n)})
    print('   ダイアログの中身: %s' % (names[:8],))
    out = adb('shell', 'logcat', '-d', '-t', '800')
    hits = [ln.strip() for ln in out.splitlines()
            if 'ANR in' in ln or 'Reason:' in ln or 'not responding' in ln]
    if not hits:
        print('   logcat に ANR の記録は無し')
    for ln in hits[-5:]:
        print('   %s' % ln[:220])


def open_home():
    """ホームが本当に見えている状態にして (ノード, 親) を返す。駄目なら None。"""
    for attempt in range(1, LAUNCH_TRIES + 1):
        adb('shell', 'am', 'force-stop', PKG)
        time.sleep(2)
        adb('shell', 'am', 'start', '-W', '-n', ACTIVITY)
        end = time.time() + LAUNCH_BUDGET
        best = 0
        anr_seen = 0
        while time.time() < end:
            time.sleep(4)
            xml = dump()
            if xml is None:
                continue
            ns, par = parse(xml)
            if is_system_dialog(ns):
                anr_seen += 1
                if anr_seen == 1:
                    anr_detail(ns)
                dismiss_dialog(ns)
                # 🔴 応答していないのが System UI のときは、いなしても前面が
                # 戻らないまま予算を使い切り「アプリが起動できない」ように見える
                # （2026-09-02 実測: 同じ APK で 2 回失敗・3 回成功。相手は毎回
                # "System UI isn't responding" で、logcat に ANR の記録は無い）。
                # いなしたら自分のアクティビティを起こし直す。
                adb('shell', 'am', 'start', '-n', ACTIVITY)
                continue
            if pkg_of(ns) != PKG:
                continue
            if maybe_skip_onboarding(ns):
                continue
            n_app = len(app_clickables(ns, par))
            best = max(best, n_app)
            if n_app >= HOME_MIN:
                print('%d 回目の起動: ホームの押せるノード（広告を除く） %d'
                      '（ANR ダイアログ %d 回）' % (attempt, n_app, anr_seen))
                return ns, par
        print('%d 回目の起動: %d 秒でホームに入れなかった'
              '（最大で %d 個・前面 %r・ANR ダイアログ %d 回）'
              % (attempt, LAUNCH_BUDGET, best, pkg_of(ns) if xml else '', anr_seen))
    return None


def main():
    print('=== 端末 ===')
    print('Android %s / %s'
          % (adb('shell', 'getprop', 'ro.build.version.release').strip(),
             adb('shell', 'getprop', 'ro.product.cpu.abi').strip()))
    tb = [l.strip() for l in adb('shell', 'pm', 'list', 'packages').splitlines()
          if 'talkback' in l.lower()]
    print('TalkBack: %s' % (tb or 'なし'))
    print('（監査は uiautomator をアクセシビリティ client として使う。TalkBack を'
          '有効にすると探索タッチが 2 回叩きになり input tap が壊れるので有効化しない）')

    opened = open_home()
    if opened is None:
        print('\nホームに入れなかった＝監査が始まっていない。'
              '「名前なし 0」を成果として読んではいけない。')
        return 1
    home, home_parent = opened
    screens = [('home', home, home_parent)]
    home_key = screen_key(home)

    targets = [(name_of(n) or '(名前なし)', center(n))
               for n in app_clickables(home, home_parent)]
    print('巡回する入口: %d' % len(targets))

    # 途中でホームへ戻れなくなったら巡回を打ち切る。そのとき「名前なし 0」でも
    # 回れなかった画面は見ていないので、成功として返さない。
    aborted = None
    for i, (label, xy) in enumerate(targets):
        tap(xy)
        xml = dump()
        if xml is None:
            if open_home() is None:
                aborted = i
                break
            continue
        ns, par = parse(xml)
        if is_system_dialog(ns) or pkg_of(ns) != PKG:
            # ANR や外部ブラウザへ出た
            dismiss_dialog(ns)
            reopened = open_home()
            if reopened is None:
                aborted = i
                break
            continue
        if screen_key(ns) != home_key:
            screens.append(('home > %s' % label, ns, par))
        back()
        for _ in range(2):
            x2 = dump()
            if x2 and screen_key(parse(x2)[0]) == home_key:
                break
            back()
        else:
            if open_home() is None:
                aborted = i
                break

    print('\n=== 実機で取れたツリー ===')
    app_total = 0
    ad_unnamed = 0
    bad = []
    pending = []
    for label, ns, par in screens:
        mine = app_clickables(ns, par)
        ads = [n for n in ns
               if n.get('clickable') == 'true' and center(n) and in_webview(n, par)]
        unnamed = [n for n in mine if not name_of(n)]
        edits = [n for n in unnamed if (n.get('class') or '').endswith('EditText')]
        real = [n for n in unnamed if n not in edits]
        app_total += len(mine)
        ad_unnamed += len([n for n in ads if not name_of(n)])
        for n in real:
            bad.append((label, n.get('class'), n.get('bounds')))
        for n in edits:
            pending.append((label, n.get('bounds'), neighbours(n, par)))
        print('%-32s アプリ %3d / 名前なし %d / 判定保留(入力欄) %d / 広告 %d'
              % (label, len(mine), len(real), len(edits), len(ads)))

    print('\n画面 %d / アプリの押せるノード %d / 名前なし %d'
          % (len(screens), app_total, len(bad)))
    for label, cls, b in bad:
        print('  - %s %s %s' % (label, cls, b))

    if pending:
        print('\n判定保留＝空欄の入力欄（uiautomator dump は hintText を出さないので'
              'dump だけでは読み上げの有無を決められない）。'
              'このアプリの入力欄については test/a11y_hint_test.dart で決着済み'
              '＝hintText は Flutter のセマンティクスの label に入る。'
              '周りに出ている名前:')
        for label, b, near in pending:
            print('  - %s EditText %s  周辺: %s' % (label, b, ' | '.join(near) or 'なし'))

    print('\n広告（WebView 配下）の名前なしノード: %d 個は除外した'
          '（AdMob の SDK が描く中身でこちらから名前を付けられない）' % ad_unnamed)

    if aborted is not None:
        print('\n巡回が %d / %d 個目で打ち切られた（ホームへ戻れなかった）。'
              '残りの入口は見ていないので成功として返さない。' % (aborted + 1, len(targets)))
        return 1
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
