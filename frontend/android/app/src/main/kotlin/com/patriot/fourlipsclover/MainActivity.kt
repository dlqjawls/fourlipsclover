// android/app/src/main/kotlin/com/patriot/fourlipsclover/MainActivity.kt
package com.patriot.fourlipsclover

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.util.Log
import com.patriot.fourlipsclover.kakao.KakaoMapViewFactory
import com.patriot.fourlipsclover.kakao.KakaoMapPlugin
import android.graphics.Color
import com.kakao.vectormap.LatLng

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.patriot.fourlipsclover/kakao_map"
    // 카카오맵 플러그인 인스턴스
    private val kakaoMapPlugin by lazy { KakaoMapPlugin.getInstance(context) }
    
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
                    // 지도 초기화
                    "initializeMap" -> {
                        Log.d("KakaoMap", "initializeMap 메서드 호출됨")
                        result.success(true)
                    }
                    // 지도 중심점 설정
                    "setMapCenter" -> {
                        Log.d("KakaoMap", "setMapCenter 메서드 호출됨")
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        val zoomLevel = call.argument<Int>("zoomLevel") ?: 3
                        kakaoMapPlugin.setMapCenter(latitude, longitude, zoomLevel)
                        result.success(null)
                    }
                    // 마커 추가
                    "addMarker" -> {
                        Log.d("KakaoMap", "addMarker 메서드 호출됨")
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        val title = call.argument<String>("title")
                        kakaoMapPlugin.addMarker(latitude, longitude, title)
                        result.success(null)
                    }
                    // 라벨 추가
                    "addLabel" -> {
                        Log.d("KakaoMap", "addLabel 메서드 호출됨")
                        try {
                            // 인자 로깅
                            val arguments = call.arguments as Map<String, Any?>
                            arguments.forEach { (key, value) ->
                                Log.d("KakaoMap", "키: $key, 값: $value, 타입: ${value?.javaClass}")
                            }
                            
                            val labelId = call.argument<String>("labelId")!!
                            val latitude = call.argument<Double>("latitude")!!
                            val longitude = call.argument<Double>("longitude")!!
                            val text = call.argument<String>("text")
                            val imageAsset = call.argument<String>("imageAsset")
                            val textColor = call.argument<Int>("textColor")?.toLong()
                            val backgroundColor = call.argument<Int>("backgroundColor")?.toLong()
                            val textSize = call.argument<Double>("textSize")?.toFloat()
                            val alpha = call.argument<Double>("alpha")?.toFloat() ?: 1.0f
                            val rotation = call.argument<Double>("rotation")?.toFloat() ?: 0.0f
                            
                            // zIndex 처리
                            val zIndexValue = arguments["zIndex"]
                            val safeZIndex = when (zIndexValue) {
                                is Long -> zIndexValue.toInt()
                                is Int -> zIndexValue
                                is Double -> zIndexValue.toInt()
                                else -> 0
                            }
                            val isClickable = call.argument<Boolean>("isClickable") ?: true
                            
                            kakaoMapPlugin.addLabel(
                                labelId = labelId,
                                latitude = latitude,
                                longitude = longitude,
                                text = text,
                                imageAsset = imageAsset,
                                textColor = textColor,
                                textSize = textSize,
                                backgroundColor = backgroundColor,
                                alpha = alpha,
                                rotation = rotation,
                                zIndex = safeZIndex,
                                isClickable = isClickable
                            )
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("KakaoMap", "라벨 추가 오류: ${e.message}")
                            result.error("LABEL_ERROR", "라벨 추가 실패: ${e.message}", null)
                        }
                    }
                    // 라벨 제거
                    "removeLabel" -> {
                        Log.d("KakaoMap", "removeLabel 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        kakaoMapPlugin.removeLabel(labelId)
                        result.success(null)
                    }
                    // 모든 라벨 제거
                    "clearLabels" -> {
                        Log.d("KakaoMap", "clearLabels 메서드 호출됨")
                        kakaoMapPlugin.clearLabels()
                        result.success(null)
                    }
                    // 라벨 위치 업데이트
                    "updateLabelPosition" -> {
                        Log.d("KakaoMap", "updateLabelPosition 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        kakaoMapPlugin.updateLabelPosition(labelId, latitude, longitude)
                        result.success(null)
                    }
                    // 라벨 텍스트 업데이트
                    "updateLabelText" -> {
                        Log.d("KakaoMap", "updateLabelText 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val text = call.argument<String>("text")!!
                        kakaoMapPlugin.updateLabelText(labelId, text)
                        result.success(null)
                    }
                    // 라벨 스타일 업데이트
                    "updateLabelStyle" -> {
                        Log.d("KakaoMap", "updateLabelStyle 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val textColor = call.argument<Int>("textColor")
                        val textSize = call.argument<Double>("textSize")?.toFloat()
                        val backgroundColor = call.argument<Int>("backgroundColor")
                        val alpha = call.argument<Double>("alpha")?.toFloat()
                        val rotation = call.argument<Double>("rotation")?.toFloat()
                        val zIndex = call.argument<Number>("zIndex")?.toLong()
                        
                        kakaoMapPlugin.updateLabelStyle(
                            labelId = labelId,
                            textColor = textColor,
                            textSize = textSize,
                            backgroundColor = backgroundColor,
                            alpha = alpha,
                            rotation = rotation,
                            zIndex = zIndex
                        )
                        result.success(null)
                    }
                    // 라벨 직접 추가
                    "addLabelDirectly" -> {
                        Log.d("KakaoMap", "addLabelDirectly 메서드 호출됨")
                        try {
                            val labelId = call.argument<String>("labelId")!!
                            val latitude = call.argument<Double>("latitude")!!
                            val longitude = call.argument<Double>("longitude")!!
                            val text = call.argument<String>("text")
                            val imageAsset = call.argument<String>("imageAsset")
                            val textSize = call.argument<Double>("textSize")?.toFloat()
                            
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("KakaoMap", "라벨 직접 추가 오류: ${e.message}")
                            result.error("LABEL_ERROR", "라벨 직접 추가 실패: ${e.message}", null)
                        }
                    }
                    // 라벨 가시성 설정
                    "setLabelVisibility" -> {
                        Log.d("KakaoMap", "setLabelVisibility 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val isVisible = call.argument<Boolean>("isVisible")!!
                        kakaoMapPlugin.setLabelVisibility(labelId, isVisible)
                        result.success(null)
                    }
                    // 경로 그리기
                    "drawRoute" -> {
                        Log.d("KakaoMap", "drawRoute 메서드 호출됨")
                        try {
                            val routeId = call.argument<String>("routeId")!!
                            val coordinates = call.argument<List<Map<String, Double>>>("coordinates")!!
                            
                            val lineColorValue = call.argument<Number>("lineColor")
                            val lineColor = lineColorValue?.toInt() ?: Color.BLUE
                            
                            val lineWidth = call.argument<Double>("lineWidth")?.toFloat() ?: 5f
                            val showArrow = call.argument<Boolean>("showArrow") ?: true
                            
                            // 좌표 리스트 변환
                            val points = coordinates.map { coordinate ->
                                LatLng.from(coordinate["latitude"]!!, coordinate["longitude"]!!)
                            }
                            
                            kakaoMapPlugin.drawRoute(routeId, points, lineColor, lineWidth, showArrow)
                            result.success(true)
                        } catch (e: Exception) {
                            Log.e("KakaoMap", "경로 그리기 오류: ${e.message}")
                            e.printStackTrace()
                            result.error("ROUTE_ERROR", "경로 그리기 실패: ${e.message}", null)
                        }
                    }
                    // 경로 제거
                    "removeRoute" -> {
                        Log.d("KakaoMap", "removeRoute 메서드 호출됨")
                        val routeId = call.argument<String>("routeId")!!
                        kakaoMapPlugin.removeRoute(routeId)
                        result.success(null)
                    }
                    // 모든 경로 제거
                    "clearRoutes" -> {
                        Log.d("KakaoMap", "clearRoutes 메서드 호출됨")
                        kakaoMapPlugin.clearRoutes()
                        result.success(null)
                    }
                    // 미구현 메서드 처리
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
    
    // KakaoMapPlugin 인스턴스 접근 메서드
    fun getKakaoPlugin(): KakaoMapPlugin {
        return kakaoMapPlugin
    }
}