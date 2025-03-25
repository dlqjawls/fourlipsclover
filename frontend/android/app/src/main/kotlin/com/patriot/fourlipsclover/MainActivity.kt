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
    // lazy 프로퍼티를 사용하지만 getter 메서드는 따로 만들지 않음
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
                    // 라벨 추가 메서드
                    "addLabel" -> {
                        Log.d("KakaoMap", "addLabel 메서드 호출됨")
                        try {

                             // call.arguments를 Map으로 캐스팅
        val arguments = call.arguments as Map<String, Any?>
        
        // 모든 인자 출력
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
                            // zIndex를 가져올 때 Any로 받아서 처리
                            val zIndexValue = arguments?.get("zIndex")
                            
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
                    // 라벨 제거 메서드
                    "removeLabel" -> {
                        Log.d("KakaoMap", "removeLabel 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        kakaoMapPlugin.removeLabel(labelId)
                        result.success(null)
                    }
                    // 모든 라벨 제거 메서드
                    "clearLabels" -> {
                        Log.d("KakaoMap", "clearLabels 메서드 호출됨")
                        kakaoMapPlugin.clearLabels()
                        result.success(null)
                    }
                    // 라벨 위치 업데이트 메서드
                    "updateLabelPosition" -> {
                        Log.d("KakaoMap", "updateLabelPosition 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val latitude = call.argument<Double>("latitude")!!
                        val longitude = call.argument<Double>("longitude")!!
                        kakaoMapPlugin.updateLabelPosition(labelId, latitude, longitude)
                        result.success(null)
                    }
                    // 라벨 텍스트 업데이트 메서드
                    "updateLabelText" -> {
                        Log.d("KakaoMap", "updateLabelText 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val text = call.argument<String>("text")!!
                        kakaoMapPlugin.updateLabelText(labelId, text)
                        result.success(null)
                    }
                    // 라벨 스타일 업데이트 메서드
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

                    "addLabelDirectly" -> {
    Log.d("KakaoMap", "addLabelDirectly 메서드 호출됨")
    try {
        val labelId = call.argument<String>("labelId")!!
        val latitude = call.argument<Double>("latitude")!!
        val longitude = call.argument<Double>("longitude")!!
        val text = call.argument<String>("text")
        val imageAsset = call.argument<String>("imageAsset")
        val textSize = call.argument<Double>("textSize")?.toFloat()
        
        // KakaoMapView의 실행 중인 인스턴스 찾기
        // 아래 코드는 예시이며, KakaoMapView 인스턴스를 실제로 가져오는 코드가 필요합니다
        // 가능하다면 KakaoMapView 인스턴스를 전역으로 유지하거나 찾을 수 있는 방법을 구현해야 합니다
        
        result.success(true)
    } catch (e: Exception) {
        Log.e("KakaoMap", "라벨 직접 추가 오류: ${e.message}")
        result.error("LABEL_ERROR", "라벨 직접 추가 실패: ${e.message}", null)
    }
}
                    // 라벨 가시성 설정 메서드
                    "setLabelVisibility" -> {
                        Log.d("KakaoMap", "setLabelVisibility 메서드 호출됨")
                        val labelId = call.argument<String>("labelId")!!
                        val isVisible = call.argument<Boolean>("isVisible")!!
                        kakaoMapPlugin.setLabelVisibility(labelId, isVisible)
                        result.success(null)
                    }
                    // 지도 타입 설정 메서드
                    "setMapType" -> {
                        Log.d("KakaoMap", "setMapType 메서드 호출됨")
                        val mapType = call.argument<Int>("mapType")!!
                        kakaoMapPlugin.setMapType(mapType)
                        result.success(null)
                    }
                    // 지도 레이블 표시 설정 메서드
                    "setShowMapLabels" -> {
                        Log.d("KakaoMap", "setShowMapLabels 메서드 호출됨")
                        val show = call.argument<Boolean>("show")!!
                        kakaoMapPlugin.setShowMapLabels(show)
                        result.success(null)
                    }
                    // 건물 표시 설정 메서드
                    "setShowBuildings" -> {
                        Log.d("KakaoMap", "setShowBuildings 메서드 호출됨")
                        val show = call.argument<Boolean>("show")!!
                        kakaoMapPlugin.setShowBuildings(show)
                        result.success(null)
                    }
                    // 교통정보 표시 설정 메서드
                    "setShowTraffic" -> {
                        Log.d("KakaoMap", "setShowTraffic 메서드 호출됨")
                        val show = call.argument<Boolean>("show")!!
                        kakaoMapPlugin.setShowTraffic(show)
                        result.success(null)
                    }
                    // 야간 모드 설정 메서드
                    "setNightMode" -> {
                        Log.d("KakaoMap", "setNightMode 메서드 호출됨")
                        val enable = call.argument<Boolean>("enable")!!
                        kakaoMapPlugin.setNightMode(enable)
                        result.success(null)
                    }
                    // 루트라인 
                    "drawRoute" -> {
                    Log.d("KakaoMap", "drawRoute 메서드 호출됨")
                    try {
                        val routeId = call.argument<String>("routeId")!!
                        val coordinates = call.argument<List<Map<String, Double>>>("coordinates")!!
                        
                        // 여기가 문제입니다. 플러터에서 Int 대신 Long으로 값이 전달됨
                        // val lineColor = call.argument<Int>("lineColor") ?: Color.BLUE
                        // 수정된 코드:
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
                        e.printStackTrace() // 스택 트레이스 출력 추가
                        result.error("ROUTE_ERROR", "경로 그리기 실패: ${e.message}", null)
                    }
                }
                "removeRoute" -> {
                    Log.d("KakaoMap", "removeRoute 메서드 호출됨")
                    val routeId = call.argument<String>("routeId")!!
                    kakaoMapPlugin.removeRoute(routeId)
                    result.success(null)
                }
                "clearRoutes" -> {
                    Log.d("KakaoMap", "clearRoutes 메서드 호출됨")
                    kakaoMapPlugin.clearRoutes()
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