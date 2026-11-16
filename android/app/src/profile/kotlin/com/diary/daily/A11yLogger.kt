package com.diary.daily

import android.accessibilityservice.AccessibilityService
import android.graphics.Rect
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

/**
 * 読み上げ検証専用のアクセシビリティサービス。
 *
 * profile ビルドの source set にだけ置いてあるので **release には入らない**。
 * TalkBack が喋る材料そのもの（AccessibilityEvent とノードツリー）を logcat に出す。
 * CI のエミュレータ像には TalkBack も TTS も入っていない（2026-08-31 実測）ため、
 * 「読み上げが受け取る中身」はこのサービスで取る。
 */
class A11yLogger : AccessibilityService() {

    private val handler = Handler(Looper.getMainLooper())

    /**
     * 一定間隔で画面を採る。イベントだけに頼ると、Flutter の意味ツリーが
     * 組み上がる前に見に行って 1 件しか取れない（2026-08-31 実測）。
     */
    private val sampler = object : Runnable {
        override fun run() {
            dumpWindow("tick")
            handler.postDelayed(this, TICK_MS)
        }
    }

    override fun onServiceConnected() {
        Log.i(TAG, "SERVICE_CONNECTED")
        handler.postDelayed(sampler, TICK_MS)
    }

    override fun onUnbind(intent: android.content.Intent?): Boolean {
        handler.removeCallbacks(sampler)
        return super.onUnbind(intent)
    }

    override fun onInterrupt() {}

    override fun onAccessibilityEvent(event: AccessibilityEvent) {
        if (event.packageName?.toString() != PKG) return
        when (event.eventType) {
            AccessibilityEvent.TYPE_ANNOUNCEMENT ->
                Log.i(TAG, "ANNOUNCE\t" + joinText(event))
            AccessibilityEvent.TYPE_VIEW_ACCESSIBILITY_FOCUSED ->
                Log.i(TAG, "FOCUS\t" + describe(event.source))
            AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED ->
                dumpWindow("window_state_changed")
            AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED -> {
                // 文字を伴うものだけ記録すると、liveRegion が文字なしで飛んできた場合に
                // 自分で捨てることになる。件数は全部数え、中身があるものは中身も残す。
                val text = joinText(event)
                val empty = text == CH_Q2
                if (contentEvents < MAX_EVENTS) {
                    contentEvents++
                    // 🔴 イベントは文字を運ばない（33 件中 0 件＝2026-09-01 実測）。
                    // 読み上げはイベントを受けてから「その要素の名前」を読みに行くので、
                    // 見るべきは発火元の要素。
                    Log.i(TAG, "CONTENT" + CH_TAB + "types=" + event.contentChangeTypes +
                        CH_TAB + "empty=" + empty + CH_TAB + text +
                        CH_TAB + "src=" + describe(event.source))
                }
                // 🔴 Flutter のこのイベントは文字も発火元も持たない（実測）。
                // 読み上げがお祝いを読むかどうかは、要素に live region の印が
                // 付いているかで決まるので、そこを直接見る。一瞬で消える表示も
                // イベント駆動なら取り逃さない。
                if (System.currentTimeMillis() - lastLive > 300) {
                    lastLive = System.currentTimeMillis()
                    rootInActiveWindow?.let { findLive(it, 0) }
                }
            }
            else -> {}
        }
    }

    /** いま見えている画面を、読み上げが辿る順（深さ優先）で書き出す。 */
    private fun dumpWindow(reason: String) {
        // 画面が変わるたびに全走査すると重い。間引く。
        val now = System.currentTimeMillis()
        if (now - lastDump < QUIET_MS) return
        val root = rootInActiveWindow
        // なぜ採れなかったのかを必ず残す（黙って抜けると原因が分からない）
        if (root == null) {
            Log.i(TAG, "TICK	root=null	reason=" + reason)
            return
        }
        Log.i(TAG, "TICK	pkg=" + root.packageName + "	children=" + root.childCount +
            "	reason=" + reason)
        lastDump = now
        Log.i(TAG, "SCREEN_BEGIN\t" + reason + "\tpkg=" + root.packageName)
        val counter = intArrayOf(0)
        walk(root, 0, counter)
        Log.i(TAG, "SCREEN_END\t" + reason + "\tnodes=" + counter[0])
    }

    /** live region の印が付いた要素だけを拾う（読み上げが割り込んで読む対象）。 */
    private fun findLive(node: AccessibilityNodeInfo, depth: Int) {
        if (depth > 24) return
        if (node.liveRegion != 0) {
            Log.i(TAG, "LIVEREGION" + CH_TAB + describe(node))
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            findLive(child, depth + 1)
        }
    }

    private fun walk(node: AccessibilityNodeInfo, depth: Int, counter: IntArray) {
        if (counter[0] >= MAX_NODES) return
        val line = describe(node)
        if (line.isNotEmpty()) {
            Log.i(TAG, "READ\t" + counter[0] + "\t" + "  ".repeat(minOf(depth, 8)) + line)
            counter[0] = counter[0] + 1
        }
        for (i in 0 until node.childCount) {
            val child = node.getChild(i) ?: continue
            walk(child, depth + 1, counter)
        }
    }

    /**
     * その要素で読み上げが手にする文字列。
     * 名前が無いのに押せるものは `!NO_NAME` を付ける（監査で落とす目印）。
     */
    private fun describe(node: AccessibilityNodeInfo?): String {
        if (node == null) return "(source なし)"
        val desc = node.contentDescription?.toString()?.trim() ?: ""
        val text = node.text?.toString()?.trim() ?: ""
        val name = if (desc.isNotEmpty()) desc else text
        val hint = if (Build.VERSION.SDK_INT >= 26) {
            node.hintText?.toString()?.trim() ?: ""
        } else ""
        val state = if (Build.VERSION.SDK_INT >= 30) {
            node.stateDescription?.toString()?.trim() ?: ""
        } else ""

        val roles = mutableListOf<String>()
        if (node.isClickable) roles.add("押せる")
        if (node.isEditable) roles.add("入力欄")
        if (node.isCheckable) roles.add(if (node.isChecked) "オン" else "オフ")
        if (node.isSelected) roles.add("選択中")
        if (!node.isEnabled) roles.add("無効")

        if (name.isEmpty() && hint.isEmpty() && state.isEmpty() && roles.isEmpty()) {
            return ""
        }

        val parts = mutableListOf<String>()
        parts.add("name=" + quote(name))
        if (hint.isNotEmpty()) parts.add("hint=" + quote(hint))
        if (state.isNotEmpty()) parts.add("state=" + quote(state))
        if (roles.isNotEmpty()) parts.add("role=" + roles.joinToString(","))
        if (node.liveRegion != 0) parts.add("LIVE=" + node.liveRegion)
        val box = Rect()
        node.getBoundsInScreen(box)
        parts.add("bounds=%d,%d,%d,%d".format(box.left, box.top, box.right, box.bottom))
        parts.add("cls=" + (node.className?.toString() ?: ""))
        // ヒントだけを持つ空の入力欄は「無名」ではない。
        // 読み上げは空欄のとき hintText を読む（2026-09-01 に実測して誤判定を直した）。
        if (node.isClickable && name.isEmpty() && hint.isEmpty() && state.isEmpty()) {
            // 広告かどうかは親をたどって決める。矩形で判定すると、広告の外枠が
            // 採れた回とそうでない回で分類が揺れる（2026-09-01 に実測）。
            parts.add(if (insideWebView(node)) "!AD_NO_NAME" else "!NO_NAME")
        }
        return parts.joinToString(" ")
    }

    /** 祖先に WebView がいるか（＝広告の中身か）。 */
    private fun insideWebView(node: AccessibilityNodeInfo): Boolean {
        var cur: AccessibilityNodeInfo? = node.parent
        var depth = 0
        while (cur != null && depth < 12) {
            if (cur.className?.toString()?.contains("WebView") == true) return true
            cur = cur.parent
            depth++
        }
        return false
    }

    private fun joinText(event: AccessibilityEvent): String {
        val text = event.text.filterNotNull().joinToString(" / ") { it.toString().trim() }
        val desc = event.contentDescription?.toString()?.trim() ?: ""
        return if (text.isNotEmpty()) quote(text) else quote(desc)
    }

    private fun quote(s: String) = "\"" + s.replace("\n", " ") + "\""

    private var lastDump = 0L
    private var contentEvents = 0
    private var lastLive = 0L

    companion object {
        private const val QUIET_MS = 1500L
        private const val TICK_MS = 3000L
        private const val MAX_NODES = 400
        // タブ。ssh 越しの編集でバックスラッシュが落ちる事故を避けるため文字コードで書く。
        private val CH_TAB = 9.toChar().toString()
        private val CH_Q2 = 34.toChar().toString() + 34.toChar().toString()
        private const val MAX_EVENTS = 300
        private const val TAG = "A11YLOG"
        private const val PKG = "com.diary.daily"
    }
}
