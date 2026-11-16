package com.diary.daily

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import android.util.Log
import java.io.File
import java.util.Locale

/**
 * 読み上げに渡す文字を、端末の TTS に読ませて **その場で測る**。
 *
 * profile ビルドにだけ入る（release には入らない）。
 * ランナーに音の出口が無くても済むよう、WAV は端末内に書き、
 * 測った数値だけを logcat に出す（ファイルは持ち出さない）。
 *
 * 使い方:
 *   adb shell am broadcast -a com.diary.daily.TTS_PROBE \
 *     --es text "連用日記" --es tag "appTitle" --es locale ja
 */
class TtsProbe : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val text = intent.getStringExtra("text") ?: return
        val tag = intent.getStringExtra("tag") ?: "?"
        val locale = intent.getStringExtra("locale") ?: "ja"
        val ctx = context.applicationContext
        var engine: TextToSpeech? = null
        engine = TextToSpeech(ctx) { status ->
            if (status != TextToSpeech.SUCCESS) {
                Log.i(TAG, "TTS" + SEP + tag + SEP + "init_failed=" + status)
                return@TextToSpeech
            }
            val e = engine ?: return@TextToSpeech
            val want = Locale.forLanguageTag(locale)
            val got = e.setLanguage(want)
            val out = File(ctx.cacheDir, "tts_probe.wav")
            e.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
                override fun onStart(id: String?) {}
                override fun onDone(id: String?) {
                    measure(tag, text, locale, got, out)
                    e.shutdown()
                }
                @Deprecated("required by the base class")
                override fun onError(id: String?) {
                    Log.i(TAG, "TTS" + SEP + tag + SEP + "synth_error")
                    e.shutdown()
                }
            })
            val rc = e.synthesizeToFile(text, Bundle(), out, "probe")
            if (rc != TextToSpeech.SUCCESS) {
                Log.i(TAG, "TTS" + SEP + tag + SEP + "synth_rejected=" + rc)
            }
        }
    }

    /** 出来た WAV を読んで、声の割合・最長無音・秒あたりのモーラを出す。 */
    private fun measure(tag: String, text: String, locale: String,
                        langResult: Int, file: File) {
        if (!file.exists() || file.length() < 64) {
            Log.i(TAG, "TTS" + SEP + tag + SEP + "no_audio")
            return
        }
        val bytes = file.readBytes()
        // WAV の data チャンクを探す（ヘッダ長は端末まかせにしない）
        var pos = 12
        var dataAt = -1
        var dataLen = 0
        var rate = 22050
        var format = 1
        var channels = 1
        var bits = 16
        while (pos + 8 <= bytes.size) {
            val id = String(bytes, pos, 4, Charsets.US_ASCII)
            val len = le32(bytes, pos + 4)
            if (id == "fmt " && pos + 24 <= bytes.size) {
                format = le16(bytes, pos + 8)
                channels = le16(bytes, pos + 10)
                rate = le32(bytes, pos + 12)
                bits = le16(bytes, pos + 22)
            }
            if (id == "data") { dataAt = pos + 8; dataLen = len; break }
            if (len < 0) break          // 壊れた WAV で後退して無限に回らないように
            pos += 8 + len + (len and 1)
        }
        if (dataAt < 0) {
            Log.i(TAG, "TTS" + SEP + tag + SEP + "no_data_chunk")
            return
        }
        // 🔴 この解析は mono / 16bit / PCM だけを前提にしている。ここを見ないと
        // 像の更新で形式が変わった日に黙って違う数字を出す（ステレオなら秒が倍、
        // 8bit なら復号がでたらめで無音を声と読む＝計器が嘘をつく）。
        if (format != 1 || channels != 1 || bits != 16) {
            Log.i(TAG, "TTS" + SEP + tag + SEP + "unsupported_wav=" +
                format + "/" + channels + "ch/" + bits + "bit")
            return
        }
        val end = minOf(dataAt + dataLen, bytes.size)
        val frame = maxOf(1, rate / 50)          // 20ms
        val flags = ArrayList<Boolean>()
        var i = dataAt
        while (i + frame * 2 <= end) {
            var sum = 0.0
            for (k in 0 until frame) {
                val s = ((bytes[i + k * 2 + 1].toInt() shl 8) or
                    (bytes[i + k * 2].toInt() and 0xFF)).toShort().toInt()
                sum += (s * s).toDouble()
            }
            flags.add(Math.sqrt(sum / frame) > 500)
            i += frame * 2
        }
        // 🔴 先頭と末尾の無音は「途中の無音」ではない。合成器が必ず付ける余白で、
        // 長い文ほど末尾が伸びる（2026-09-01 実測: 4.55 秒の 1 文で末尾 0.86 秒。
        // それを「途切れ」と数えて落としていた）。声の割合も、余白を除いた
        // 「話している間」に対して出す。
        val first = flags.indexOfFirst { it }
        val last = flags.indexOfLast { it }
        var voiced = 0
        var silentRun = 0
        var worstSilence = 0
        var worstAt = 0
        if (first >= 0) {
            for (n in first..last) {
                if (flags[n]) {
                    voiced++
                    silentRun = 0
                } else {
                    silentRun++
                    if (silentRun > worstSilence) {
                        worstSilence = silentRun
                        worstAt = n - silentRun + 1
                    }
                }
            }
        }
        val span = if (first < 0) 0 else last - first + 1
        val lead = if (first < 0) 0 else first
        val tail = if (first < 0) 0 else flags.size - 1 - last
        val seconds = (end - dataAt) / 2.0 / rate
        val ratio = if (span == 0) 0.0 else voiced.toDouble() / span
        val moras = maxOf(1, text.count { it.code > 32 })
        Log.i(TAG, "TTS" + SEP + tag + SEP + "locale=" + locale +
            SEP + "lang_result=" + langResult +
            SEP + "seconds=" + String.format(Locale.US, "%.2f", seconds) +
            SEP + "voiced=" + String.format(Locale.US, "%.3f", ratio) +
            SEP + "longest_silence=" + String.format(Locale.US, "%.2f", worstSilence * 0.02) +
            SEP + "silence_at=" + String.format(Locale.US, "%.2f", worstAt * 0.02) +
            SEP + "lead=" + String.format(Locale.US, "%.2f", lead * 0.02) +
            SEP + "tail=" + String.format(Locale.US, "%.2f", tail * 0.02) +
            SEP + "sec_per_char=" + String.format(Locale.US, "%.3f", seconds / moras) +
            SEP + "text=" + text)
    }

    private fun le16(b: ByteArray, at: Int): Int =
        (b[at].toInt() and 0xFF) or ((b[at + 1].toInt() and 0xFF) shl 8)

    private fun le32(b: ByteArray, at: Int): Int =
        (b[at].toInt() and 0xFF) or ((b[at + 1].toInt() and 0xFF) shl 8) or
            ((b[at + 2].toInt() and 0xFF) shl 16) or ((b[at + 3].toInt() and 0xFF) shl 24)

    companion object {
        private const val TAG = "A11YLOG"
        private val SEP = 9.toChar().toString()
    }
}
