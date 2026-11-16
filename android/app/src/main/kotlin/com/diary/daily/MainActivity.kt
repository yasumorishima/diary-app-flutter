package com.diary.daily

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// local_auth (生体認証) が FragmentActivity を要求するため FlutterFragmentActivity を継承
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // アプリロック有効時に FLAG_SECURE を制御
        // （リセントのサムネイル・スクリーンショットから日記本文を守る）
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.diary.daily/secure")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableSecure" -> {
                        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    "disableSecure" -> {
                        window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
