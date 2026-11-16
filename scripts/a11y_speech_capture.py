#!/usr/bin/env python3
"""実機（エミュレータ）で「読み上げが受け取る中身」を集める。

CI のエミュレータ像には **TalkBack も TTS エンジンも入っていない**（2026-08-31 実測。
`pm list packages` に marvin/talkback/tts が 1 件も無く、`adb root` も拒否される）。
そこで TalkBack の代わりに、profile ビルドにだけ入る自前の AccessibilityService
（`android/app/src/profile/.../A11yLogger.kt`）を有効にして、
フレームワークが読み上げへ渡すのと同じ AccessibilityEvent とノードツリーを logcat から拾う。

取れるもの: 読み上げの順序 / 各要素で読まれる文字列 / liveRegion の発火 / 重複読み。
取れないもの: 実際の音声と発音（TTS が無いため。これは user 様の実機でしか確かめられない）。

巡回そのものは `a11y_device_audit.py` の関数をそのまま使う（同じ入口・同じ戻り方）。
"""
import os
import re
import sys
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import a11y_device_audit as audit  # noqa: E402

SERVICE = 'com.diary.daily/com.diary.daily.A11yLogger'
TAG = 'A11YLOG'
MIN_READS = 20  # これ未満なら計測が成立していない（空の success を出さないため）


def enable_service():
    # ログは「有効化する前」に消す。有効化のあとに消すと、接続の合図
    # (SERVICE_CONNECTED) を自分で消してしまう（2026-08-31 に踏んだ）。
    # この時点でアプリは既に立っている（入れ直しは終わっている）。
    audit.adb('logcat', '-c')

    # API 33 以降、サイドロードしたアプリのアクセシビリティ有効化は
    # 「制限付き設定」で拒まれることがある。settings は書けるのに bind されない。
    audit.adb('shell', 'appops', 'set', 'com.diary.daily',
              'ACCESS_RESTRICTED_SETTINGS', 'allow')

    audit.adb('shell', 'settings', 'put', 'secure',
              'enabled_accessibility_services', SERVICE)
    audit.adb('shell', 'settings', 'put', 'secure', 'accessibility_enabled', '1')

    # 「設定に書けたか」ではなく「実際に繋がったか」で判定する。
    for _ in range(15):
        time.sleep(2)
        if any(l.startswith('SERVICE_CONNECTED') for l in captured()):
            return True
    return False


def diagnose():
    print('--- なぜ繋がらなかったか ---')
    ticks = [l for l in captured() if l.startswith('TICK')]
    print('採取の試行 (TICK) : %d 件' % len(ticks))
    for l in ticks[:8]:
        print('  ' + l)
    crash = audit.adb('logcat', '-d', '-b', 'crash').strip().splitlines()
    for l in crash[-8:]:
        print('crash: %s' % l)
    print('settings(enabled) : %s' % audit.adb(
        'shell', 'settings', 'get', 'secure',
        'enabled_accessibility_services').strip())
    print('settings(on)      : %s' % audit.adb(
        'shell', 'settings', 'get', 'secure', 'accessibility_enabled').strip())
    dump = audit.adb('shell', 'dumpsys', 'accessibility')
    for line in dump.splitlines():
        if 'A11yLogger' in line or 'Installed' in line or 'Enabled' in line:
            print('dumpsys           : %s' % line.strip())
    pm = audit.adb('shell', 'pm', 'dump', 'com.diary.daily')
    hit = [l.strip() for l in pm.splitlines() if 'A11yLogger' in l]
    print('APK にサービスは入っているか: %s'
          % ('入っている / ' + hit[0] if hit else '入っていない（ビルドに含まれていない）'))


def captured():
    """logcat から自分のタグの行だけを取り出す。

    🔴 `-v raw` を必ず使う。既定の threadtime 書式はタグを 8 桁に詰めるので、
    7 文字の A11YLOG は `A11YLOG :`（コロンの前に空白）になり、
    `TAG + ':'` で探すと 1 行も拾えない（2026-08-31 に踏んで 1 回分の走行を無駄にした）。
    """
    out = audit.adb('logcat', '-d', '-v', 'raw', '-s', TAG + ':I')
    heads = ('SERVICE_CONNECTED', 'SCREEN_BEGIN', 'SCREEN_END', 'READ',
             'FOCUS', 'ANNOUNCE', 'TEXT_CHANGED', 'TICK', 'CONTENT',
             'LIVEREGION')
    return [l.strip() for l in out.splitlines() if l.strip().startswith(heads)]


def launch():
    # 🔴 force-stop してはいけない。サービスは同じアプリの中にいるので、
    # 自分の計測器を撃ち落とすことになる。しかも force-stop はパッケージを
    # 停止状態にするので enabled_accessibility_services も外れる
    # （2026-08-31 に実測。走行の最後に設定が null に戻っていた）。
    audit.adb('shell', 'am', 'start', '-W', '-n',
              'com.diary.daily/.MainActivity')


def service_alive():
    got = audit.adb('shell', 'settings', 'get', 'secure',
                    'enabled_accessibility_services').strip()
    return SERVICE in got


def ensure_service():
    """外れていたら張り直す。外れたまま歩くと全部が空振りになる。"""
    if service_alive():
        return True
    print('  （サービスが外れていたので張り直す）')
    audit.adb('shell', 'settings', 'put', 'secure',
              'enabled_accessibility_services', SERVICE)
    audit.adb('shell', 'settings', 'put', 'secure', 'accessibility_enabled', '1')
    time.sleep(4)
    return service_alive()


def last_screen(lines):
    """直近に採れた 1 画面ぶんの READ 行。"""
    out, cur = [], []
    for l in lines:
        if l.startswith('SCREEN_BEGIN'):
            cur = []
        elif l.startswith('SCREEN_END'):
            if cur:
                out = cur
        elif l.startswith('READ'):
            cur.append(l)
    return out


BOUNDS = re.compile(r'bounds=(-?\d+),(-?\d+),(-?\d+),(-?\d+)')


def targets(read_lines):
    """押せて名前があるものの中心座標。広告は避ける（画面下端の帯）。"""
    seen, out = set(), []
    for l in read_lines:
        if '押せる' not in l:
            continue
        m = BOUNDS.search(l)
        if not m:
            continue
        x1, y1, x2, y2 = (int(v) for v in m.groups())
        if x2 <= x1 or y2 <= y1:
            continue
        name = l.split('name="', 1)[-1].split('"', 1)[0]
        key = (name, (x1 + x2) // 2, (y1 + y2) // 2)
        if key in seen:
            continue
        seen.add(key)
        out.append(key)
    return out


SKIP_WORDS = ('Skip', 'スキップ', 'Next', '次へ', 'Start', 'はじめる', 'Get started')
HOME_MIN = 8  # これ未満ならホームに入れていない（別の画面を測って success にしない）


WAIT_WORDS = ('Wait', '待機', 'OK', '閉じる', 'Close app', 'アプリを終了')


def clear_dialogs():
    '''システムの ANR ダイアログを閉じる。放っておくと画面を覆って
    ずっと pkg=android しか採れない（2026-09-01 に実測。14 回の採取が全部これ）。'''
    for _ in range(6):
        block = last_screen(captured())
        if not block:
            return
        # 直近の画面がアプリのものならダイアログは出ていない
        pkg = current_pkg(captured())
        if pkg == 'com.diary.daily':
            return
        hit = [t for t in targets(block) if t[0] in WAIT_WORDS]
        if not hit:
            return
        name, x, y = hit[0]
        print('ダイアログを閉じる: %s' % name)
        audit.adb('shell', 'input', 'tap', str(x), str(y))
        time.sleep(5)


def current_pkg(lines):
    pkg = ''
    for l in lines:
        if l.startswith('SCREEN_BEGIN') and 'pkg=' in l:
            pkg = l.split('pkg=', 1)[1].strip()
    return pkg


def past_onboarding():
    """初回案内を最後まで送る。ここを飛ばすと Skip/Next だけを測って終わる
    （2026-08-31 に実測。11 画面 56 要素を採ったが全部オンボーディングだった）。"""
    for _ in range(8):
        clear_dialogs()
        found = targets(last_screen(captured()))
        skips = [t for t in found if t[0] in SKIP_WORDS]
        if not skips:
            return found
        name, x, y = skips[0]
        print('初回案内を送る: %s' % name)
        audit.adb('shell', 'input', 'tap', str(x), str(y))
        time.sleep(6)
    return targets(last_screen(captured()))


WRITE_WORDS = ('Write today', '今日を書く', 'Write', '書く')
SAVE_WORDS = ('Save', '保存', 'Done', '完了')


def screen_names(block):
    return tuple(spoken(parsed(l)[1])[0] for l in block)


def wait_change(before, budget=24):
    '''画面が実際に変わるまで待つ。待たずに次を探すと、まだ前の画面の記録を
    読んでしまう（2026-09-01 に実測。書く画面に入れず「保存が無い」と誤判定した）。'''
    end = time.time() + budget
    while time.time() < end:
        time.sleep(3)
        now = last_screen(captured())
        if now and screen_names(now) != before:
            return now
    return last_screen(captured())


def ime_shown():
    out = audit.adb('shell', 'dumpsys', 'input_method').replace(' ', '')
    return 'mInputShown=true' in out


def write_one_entry():
    '''日記を 1 件書いて保存する。

    お祝いは liveRegion で読み上げに割り込む作りなので、保存の流れを通さないと
    発火するか確かめられない（巡回だけでは 0 件のまま＝2026-09-01 に実測）。
    '''
    found = targets(last_screen(captured()))
    hit = [t for t in found if any(w in t[0] for w in WRITE_WORDS)]
    if not hit:
        print('「書く」が見つからないので保存の流れは通していない')
        return False
    name, x, y = hit[0]
    print('日記を書く: %s' % name)
    before = screen_names(last_screen(captured()))
    audit.adb('shell', 'input', 'tap', str(x), str(y))
    block = wait_change(before)
    print('  書く画面に入れたか: %s'
          % ('はい' if any('入力欄' in l for l in block) else 'いいえ'))

    box = [l for l in block if '入力欄' in l]
    if box:
        _d, body = parsed(box[0])
        r = rect_of(body)
        if r:
            audit.adb('shell', 'input', 'tap',
                      str((r[0] + r[2]) // 2), str((r[1] + r[3]) // 2))
            time.sleep(2)
    audit.adb('shell', 'input', 'text', 'hello')
    time.sleep(3)

    # キーボードが保存ボタンを覆っていることがある（前の走行で到達できたりできなかったり
    # したのはこれ）。見つかるまで戻るキーで閉じてから探し直す。
    save = []
    for attempt in range(3):
        save = [t for t in targets(last_screen(captured()))
                if any(w in t[0] for w in SAVE_WORDS)]
        if save:
            break
        if not ime_shown():
            # キーボードが出ていないのに戻るキーを押すと、アプリごと抜けて
            # ランチャーに出てしまう（2026-09-01 に実測。診断画面が Gmail や
            # YouTube の並ぶホームだった）。押してよいのは IME が出ている時だけ。
            print('  （キーボードは出ていないので戻るキーは押さない）')
            break
        print('  （保存が見えないのでキーボードを閉じて探し直す %d 回目）' % (attempt + 1))
        audit.adb('shell', 'input', 'keyevent', '4')
        time.sleep(5)
    if not save:
        print('「保存」が見つからない。そのとき見えていたもの:')
        show_order(last_screen(captured()), '保存が見つからなかった画面')
        return False
    name, x, y = save[0]
    print('保存する: %s' % name)
    audit.adb('shell', 'input', 'tap', str(x), str(y))
    time.sleep(10)
    show_order(last_screen(captured()), '保存の直後に見えている画面')
    return True


def walk_the_app():
    """自分の記録から座標を読んで画面を回る。uiautomator は使わない。"""
    launch()
    time.sleep(20)
    clear_dialogs()
    for line in audit.adb('shell', 'dumpsys', 'activity', 'activities').splitlines():
        if 'ResumedActivity' in line or 'mFocusedWindow' in line:
            print('前面: %s' % line.strip())
    if not ensure_service():
        print('起動の途中でサービスが外れた＝計測は始まっていない')
        return False
    home = past_onboarding()
    print('ホームで押せるもの: %d' % len(home))
    show_order(last_screen(captured()), 'ホーム画面を読み上げが辿る順')
    if len(home) < HOME_MIN:
        print('ホームに入れていない（押せるもの %d 個・最低 %d 個）'
              '＝別の画面を測っている。成果として読んではいけない。'
              % (len(home), HOME_MIN))
        for t in home:
            print('  見えているもの: %s' % t[0])
        return False
    wrote = write_one_entry()
    print('保存の流れを通せたか: %s' % ('はい' if wrote else 'いいえ'))
    time.sleep(4)

    for name, x, y in home:
        print('--- %s ---' % name)
        ensure_service()
        audit.adb('shell', 'input', 'tap', str(x), str(y))
        time.sleep(6)
        audit.adb('shell', 'input', 'keyevent', '4')
        time.sleep(4)
    return len(home) > 0


AD_CLS = 'android.webkit.WebView'


def rect_of(body):
    m = BOUNDS.search(body)
    return tuple(int(v) for v in m.groups()) if m else None


def inside(small, big):
    return (small[0] >= big[0] and small[1] >= big[1]
            and small[2] <= big[2] and small[3] <= big[3])


def parsed(line):
    '''READ 行を (深さ, 中身) に分ける。'''
    body = line.split(chr(9), 2)[-1]
    return len(body) - len(body.lstrip(' ')), body.strip()


def spoken(body):
    name = body.split('name=' + chr(34), 1)[-1].split(chr(34), 1)[0] if 'name=' in body else ''
    role = body.split('role=', 1)[1].split(' ')[0] if 'role=' in body else ''
    return name, role


def show_order(read_lines, title):
    print(chr(10) + '=== ' + title + ' ===')
    for i, line in enumerate(read_lines[:40], 1):
        _depth, body = parsed(line)
        name, role = spoken(body)
        print('  %2d. %s%s' % (i, name or '(名前なし)',
                               ('  [%s]' % role) if role else ''))


def report(lines):
    screens = reads = 0
    announces, mine, ads, dupes = [], [], [], []
    content_events = []
    live_regions = []
    prev_name = None
    ad_boxes = []
    in_app = False

    for line in lines:
        if line.startswith('SCREEN_BEGIN'):
            in_app = 'pkg=com.diary.daily' in line
            if in_app:
                screens += 1
            prev_name = None
        elif not in_app:
            continue
        elif line.startswith('READ'):
            reads += 1
            _depth, body = parsed(line)
            # 広告は Google の WebView の中身。こちらでは名前を付けられない。
            # 🔴 入れ子の深さでは分けられない（広告の中身は WebView と同じ深さで出る＝
            # 2026-09-01 に実測）。WebView の矩形に入っているかで判定する。
            if '!AD_NO_NAME' in body:
                ads.append(body)
            elif '!NO_NAME' in body:
                mine.append(body)
            name, _role = spoken(body)
            if name and name == prev_name and not in_ad:
                dupes.append(name)
            prev_name = name
        elif line.startswith(('ANNOUNCE', 'TEXT_CHANGED')):
            announces.append(line)
        elif line.startswith('CONTENT'):
            content_events.append(line)
        elif line.startswith('LIVEREGION'):
            live_regions.append(line.split(chr(9), 1)[-1].strip())

    print(chr(10) + '=== 読み上げが受け取った中身 ===')
    print('画面                       : %d' % screens)
    print('読み上げ対象のノード       : %d' % reads)
    print('読み上げの割り込み（liveRegion / announcement）: %d' % len(announces))
    for a in announces[:10]:
        print('  ' + a)
    named = [c for c in content_events
             if 'src=' in c and c.split('src=', 1)[1].strip()
             and 'name=""' not in c.split('src=', 1)[1]]
    print('画面の中身が変わった知らせ : %d 件（うち発火元が中身を持つもの %d 件）'
          % (len(content_events), len(named)))
    for c in named[:10]:
        print('  ' + c.split('src=', 1)[1][:160])
    uniq = sorted(set(live_regions))
    print('読み上げが割り込んで読む印（live region）が付いた要素 : %d 種'
          % len(uniq))
    for u in uniq[:15]:
        print('  ' + u[:160])
    print('連続して同じ名前を読む箇所 : %d' % len(dupes))
    for d in dupes[:10]:
        print('  ' + d)
    print('押せるのに名前が無い（アプリ自身）: %d' % len(mine))
    for b in mine[:20]:
        print('  ' + b)
    print('押せるのに名前が無い（広告の中・こちらでは直せない）: %d' % len(ads))
    for b in ads[:5]:
        print('  ' + b)
    return reads, len(mine)


def main():
    print('=== 端末 ===')
    print('Android %s' % audit.adb('shell', 'getprop',
                                   'ro.build.version.release').strip())
    if not enable_service():
        print('自前のアクセシビリティサービスが繋がらなかった＝計測は始まっていない')
        diagnose()
        return 1
    print('サービス接続 OK（SERVICE_CONNECTED を確認）')

    ok = walk_the_app()
    lines = captured()
    if not any(l.startswith('SERVICE_CONNECTED') for l in lines):
        print('SERVICE_CONNECTED がログに無い＝サービスが繋がっていない。'
              '「名前なし 0」を成果として読んではいけない。')
        return 1
    if not ok:
        print('巡回を最後までやれなかった（下の集計は途中までのもの）')
    reads, bad = report(lines)
    if reads < MIN_READS:
        print('読み上げ対象を %d 件しか拾えていない（最低 %d 件）'
              '＝計測になっていない。「名前なし 0」を成果として読んではいけない。'
              % (reads, MIN_READS))
        diagnose()
        return 1
    if not ok:
        return 1
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
