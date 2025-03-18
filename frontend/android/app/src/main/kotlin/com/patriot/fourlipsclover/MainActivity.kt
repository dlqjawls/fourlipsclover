// android/app/src/main/kotlin/com/patriot/fourlipsclover/MainActivity.kt
package com.patriot.fourlipsclover

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.util.Log
import com.patriot.fourlipsclover.kakao.KakaoMapViewFactory
import com.patriot.fourlipsclover.kakao.KakaoMapPlugin

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.patriot.fourlipsclover/kakao_map"
    // lazy 프로퍼티를 사용하지만 getter 메서드는 따로 만들지 않음
    private val kakaoMapPlugin by lazy { KakaoMapPlugin(context) }
    
    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        Log.d("KakaoMap", "configureFlutterEngine 호출됨")
        
        // 플랫폼 뷰 등록
        try {
            Log.d("KakaoMap", "플랫폼 뷰 등록 시도")
            flutterEngine
                .platformViewsController
                .registry
                .registerViewFactory(
                    "com.patriot.fourlipsclover/kakao_map_view", 
                    KakaoMapViewFactory(flutterEngine.dartExecutor.binaryMessenger, context)
                )
            Log.d("KakaoMap", "플랫폼 뷰 등록 성공")
        } catch (e: Exception) {
            Log.e("KakaoMap", "플랫폼 뷰 등록 실패: ${e.message}")
            e.printStackTrace()
        }
        
        // 메서드 채널 설정
        try {
            Log.d("KakaoMap", "메서드 채널 설정 시도: $CHANNEL")
            MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
                Log.d("KakaoMap", "메서드 호출: ${call.method}")
                when (call.method) {
                    "initializeMap" -> {
                        Log.d("KakaoMap", "initializeMap 메서드 호출됨")
                        result.success(true)
                    }
                    "setMapCenter" -> {
                        Log.d("KakaoMap", "setMapCenter 메서드 호출됨")
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        val zoomLevel = call.argument<Int>("zoomLevel") ?: 3
                        kakaoMapPlugin.setMapCenter(latitude, longitude, zoomLevel)
                        result.success(null)
                    }
                    "addMarker" -> {
                        Log.d("KakaoMap", "addMarker 메서드 호출됨")
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        val title = call.argument<String>("title")
                        kakaoMapPlugin.addMarker(latitude, longitude, title)
                        result.success(null)
                    }
                    else -> {
                        Log.d("KakaoMap", "미구현 메서드 호출: ${call.method}")
                        result.notImplemented()
                    }
                }
            }
            Log.d("KakaoMap", "메서드 채널 설정 성공")
        } catch (e: Exception) {
            Log.e("KakaoMap", "메서드 채널 설정 실패: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // KakaoMapView에서 접근하기 위한 메서드
    // 이름을 변경하여 충돌 방지
    fun getKakaoPlugin(): KakaoMapPlugin {
        return kakaoMapPlugin
    }
}