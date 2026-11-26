package com.diary.daily

import android.app.Activity
import com.google.android.play.agesignals.AgeSignalsAccessRequest
import com.google.android.play.agesignals.AgeSignalsException
import com.google.android.play.agesignals.AgeSignalsManagerFactory
import com.google.android.play.agesignals.AgeSignalsRequest
import com.google.android.play.agesignals.ApplicableAgeFeaturesRequest
import com.google.android.play.agesignals.model.AgeSignalsStatus
import com.google.android.play.agesignals.model.ApplicableAgeFeature
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Play Age Signals API（米カリフォルニア州 AB 1043・ブラジル Digital ECA などへの対応）。
 *
 * 起動のたびに Dart から "check" が呼ばれる。年齢シグナルの共有が法律で義務になっている
 * ユーザー（getApplicableAgeFeatures が MANDATORY_SHARING を返す人）にだけ要求を出し、
 * それ以外のユーザーには Play のプロンプトを出さない。
 *
 * 結果は Map で返し、失敗しても例外にはしない（年齢シグナルが取れなくてもアプリは普通に動く）。
 * 受け取った年齢帯は端末内で広告の設定に使うだけで、どこにも送らない。installId も使わない。
 */
class AgeSignalsChannel(private val activity: Activity, messenger: BinaryMessenger) {

    private val manager = AgeSignalsManagerFactory.create(activity.applicationContext)

    init {
        MethodChannel(messenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "check" -> check { result.success(it) }
                else -> result.notImplemented()
            }
        }
    }

    private fun check(reply: (Map<String, Any?>) -> Unit) {
        manager.getApplicableAgeFeatures(ApplicableAgeFeaturesRequest.builder().build())
            .addOnSuccessListener { features ->
                if (!features.features().contains(ApplicableAgeFeature.MANDATORY_SHARING)) {
                    reply(mapOf("mandatory" to false))
                    return@addOnSuccessListener
                }
                requestAccess(reply)
            }
            .addOnFailureListener { reply(error(it)) }
    }

    private fun requestAccess(reply: (Map<String, Any?>) -> Unit) {
        val request = AgeSignalsAccessRequest.builder().setActivity(activity).build()
        manager.requestAgeSignalsAccess(request)
            .addOnSuccessListener { access ->
                val status = access.ageSignalsStatus() ?: AgeSignalsStatus.UNSPECIFIED
                if (status != AgeSignalsStatus.SHARED) {
                    reply(mapOf("mandatory" to true, "status" to status))
                    return@addOnSuccessListener
                }
                manager.checkAgeSignals(AgeSignalsRequest.builder().build())
                    .addOnSuccessListener { signals ->
                        reply(
                            mapOf(
                                "mandatory" to true,
                                "status" to status,
                                "ageLower" to signals.ageLower(),
                                "ageUpper" to signals.ageUpper(),
                            )
                        )
                    }
                    .addOnFailureListener { reply(error(it)) }
            }
            .addOnFailureListener { reply(error(it)) }
    }

    private fun error(e: Exception): Map<String, Any?> =
        mapOf("error" to ((e as? AgeSignalsException)?.errorCode ?: INTERNAL_ERROR))

    companion object {
        const val CHANNEL = "com.diary.daily/age_signals"
        private const val INTERNAL_ERROR = -100
    }
}
