#!/usr/bin/env python3
"""読み上げに渡す文字を、端末の TTS に実際に読ませて測る。

CI のランナーには音の出口が無い（サウンドカードも録音の道具も無い）。
そこで WAV は端末の中に書き、測るのも端末の中でやり、数値だけを logcat から拾う。

⚠️ これは「TalkBack が喋る音」ではない。TalkBack はどの像にも入っていない
（2026-09-01 実測）。ここで測れるのは「その文字を TTS に読ませた音」まで。

像は google_apis_playstore を使う（google_apis には TTS が入っていない）。
"""
import json
import re
import subprocess
import sys
import time

PKG = 'com.diary.daily'
TAG = 'A11YLOG'
ACTION = PKG + '.TTS_PROBE'


def adb(*args):
    return subprocess.run(('adb',) + args, capture_output=True, text=True).stdout


def logged():
    out = adb('logcat', '-d', '-v', 'raw', '-s', TAG + ':I')
    return [l.strip() for l in out.splitlines() if l.strip().startswith('TTS')]


def shq(value):
    '''端末側のシェル用に囲う。

    🔴 adb shell は引数を空白で繋いで端末側で割り直す。囲わないと
    「📖 連用日記」が「📖」で切れ、後ろの語が別の引数として食われる
    （2026-09-01 に実測。tag まで壊れた）。
    '''
    return "'" + value.replace("'", "'" + chr(92) + "''") + "'"


def say(text, tag, locale):
    before = len(logged())
    # 🔴 宛先を明示し、停止状態も含める。入れたばかりのアプリは「停止状態」で、
    # 既定の am broadcast は配送しない。暗黙のブロードキャストは Oreo 以降
    # マニフェスト受信側に届きにくいという制約もある（2026-09-01 に 14 件全滅）。
    out = adb('shell', 'am', 'broadcast',
              '-n', PKG + '/.TtsProbe',
              '--include-stopped-packages',
              '-a', ACTION,
              '--es', 'text', shq(text), '--es', 'tag', tag,
              '--es', 'locale', locale)
    if 'Broadcast completed' not in out:
        print('  （配送できていない: %s）' % out.strip().replace(chr(10), ' ')[:120])
    for _ in range(30):
        time.sleep(2)
        lines = logged()
        if len(lines) > before:
            return lines[-1]
    return None


def phrases(locale):
    """読み上げが実際に渡される文字を l10n から取る（画面の文言そのもの）。"""
    with open('lib/l10n/app_%s.arb' % locale, encoding='utf-8') as fh:
        d = json.load(fh)
    keys = ['appTitle', 'a11yBack', 'a11yDarkMode', 'a11yPrevMonth',
            'a11yNextMonth', 'a11yCloseHint', 'homePromptLabel',
            'a11yGuideTitle', 'a11yGuideStart', 'a11yGuideCalendar',
            'moodFun', 'moodGood', 'moodSad', 'promptQuestion1']
    out = []
    for k in keys:
        v = d.get(k)
        if isinstance(v, str) and v.strip():
            out.append((k, v))
    return out


# 🔴 前後の余白は「間」ではない。合成器は文の前後に必ず無音を付け、長い文ほど
# 末尾が伸びる（2026-09-01 実測: 4.55 秒の 1 文で末尾 0.86 秒）。測る側（TtsProbe）が
# 先頭と末尾の無音を落としてから声の割合と途中の無音を出すので、
# 「短い語には当てない」という例外は要らなくなった。
BAD_VOICED = 0.50      # 話している間のうち声が出ている割合がこれ未満なら間が多すぎる
BAD_SILENCE = 0.80     # 文の途中の無音がこれを超えたら途切れて聞こえる

# 🔴 文と文の間の「間」は途切れではなく、読み上げに要る間。段落をまるごと
# 測ると文末の休止がそのまま「最長無音」に出てしまう（2026-09-01 実測:
# 3 文の案内 15.09 秒で 0.98 秒／2 文の案内は 0.74 秒）。
# そこで無音の判定は 1 文の内側だけに当て、文をまたぐ間は数えない。
SENTENCE_END = '。！？!?'


def sentences(text):
    """句点・感嘆符・疑問符で切る（読点や矢印では切らない）。

    絵文字だけ・記号だけの切れ端は 1 文として立てず前の文にくっつける。
    単独で読ませても音にならず「音が出なかった」と誤って落ちるため
    （例:「きょう、いちばん笑ったことは？😆」の 😆）。
    """
    out, cur = [], ''
    for ch in text:
        cur += ch
        if ch in SENTENCE_END:
            out.append(cur.strip())
            cur = ''
    if cur.strip():
        out.append(cur.strip())
    merged = []
    for piece in out:
        if not piece:
            continue
        if any(c.isalnum() for c in piece) or not merged:
            merged.append(piece)
        else:
            merged[-1] += piece
    return [m for m in merged if any(c.isalnum() for c in m)]


def main():
    locale = sys.argv[1] if len(sys.argv) > 1 else 'ja'
    adb('logcat', '-c')
    # 一度起こしておく（停止状態のままだと受信側が動かないことがある）
    adb('shell', 'am', 'start', '-W', '-n', PKG + '/.MainActivity')
    time.sleep(8)
    items = phrases(locale)
    # 段落は「まるごと」と「1 文ずつ」の両方を読ませる。
    # 声の割合はどちらにも当て、途中の無音は 1 文の内側だけで見る。
    units = []
    for tag, text in items:
        ss = sentences(text)
        units.append((tag, text, len(ss) <= 1))
        if len(ss) > 1:
            for n, s in enumerate(ss, 1):
                units.append(('%s_s%d' % (tag, n), s, True))
    print('読ませる文言: %d 件（%s・うち %d 件は文ごとの読み直し）'
          % (len(units), locale, len(units) - len(items)))
    rows = []
    for tag, text, ck_silence in units:
        line = say(text, tag, locale)
        if line is None:
            print('  %-22s 応答なし' % tag)
            rows.append((tag, None, ck_silence))
            continue
        print('  ' + line)
        rows.append((tag, line, ck_silence))

    print('')
    print('=== 測った結果 ===')
    bad = []
    for tag, line, ck_silence in rows:
        if line is None or 'seconds=' not in line:
            bad.append('%s: 音が出なかった（%s）' % (tag, line))
            continue
        # 🔴 前の発話が遅れて届いた行を次の tag の結果として読まないよう、
        # 行に入っている tag と突き合わせる（計器の取り違え防止）。
        fields = line.split(chr(9))
        if len(fields) < 2 or fields[1] != tag:
            bad.append('%s: 別の行を拾っている（%s）' % (tag, line[:60]))
            continue
        got = dict(re.findall(r'(\w+)=([^\t]+)', line))
        voiced = float(got.get('voiced', 0))
        silence = float(got.get('longest_silence', 0))
        at = float(got.get('silence_at', 0))
        # ja の声が入っていない像でも英語の声で読めば数字は出る。
        # setLanguage の戻りが負なら、その言語では読めていない。
        if int(got.get('lang_result', 0)) < 0:
            bad.append('%s: その言語で読めていない（lang_result=%s）'
                       % (tag, got.get('lang_result')))
        if voiced < BAD_VOICED:
            bad.append('%s: 声の割合 %.3f（%.2f 未満）' % (tag, voiced, BAD_VOICED))
        if ck_silence and silence > BAD_SILENCE:
            bad.append('%s: 文の途中の無音 %.2f 秒（%.2f 秒超・%.2f 秒の所）'
                       % (tag, silence, BAD_SILENCE, at))
    if not rows:
        print('1 件も読ませていない＝計測になっていない')
        return 1
    print('気になるもの: %d 件' % len(bad))
    for b in bad:
        print('  ' + b)
    return 1 if bad else 0


if __name__ == '__main__':
    sys.exit(main())
