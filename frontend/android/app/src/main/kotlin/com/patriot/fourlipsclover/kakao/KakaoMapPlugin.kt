package com.patriot.fourlipsclover.kakao

import android.content.Context
import android.graphics.Color
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.camera.CameraUpdateFactory
import com.kakao.vectormap.label.Label
import com.kakao.vectormap.label.LabelOptions
import com.kakao.vectormap.label.LabelLayer
import com.kakao.vectormap.label.LabelLayerOptions
import com.kakao.vectormap.label.LabelManager
import com.kakao.vectormap.label.LabelStyle
import com.kakao.vectormap.label.LabelStyles
import com.kakao.vectormap.label.LabelTextStyle
import com.kakao.vectormap.label.LabelTextBuilder
import com.kakao.vectormap.label.OrderingType
import com.kakao.vectormap.label.CompetitionType
import com.kakao.vectormap.label.CompetitionUnit
import android.util.Log
import com.patriot.fourlipsclover.R
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.MethodChannel
import com.kakao.vectormap.route.RouteLine
import com.kakao.vectormap.route.RouteLineLayer
import com.kakao.vectormap.route.RouteLineManager
import com.kakao.vectormap.route.RouteLineOptions
import com.kakao.vectormap.route.RouteLineSegment
import com.kakao.vectormap.route.RouteLineStyle
import com.kakao.vectormap.route.RouteLineStyles
import com.kakao.vectormap.route.RouteLinePattern

class KakaoMapPlugin(private val context: Context) {
    
    companion object {
        // 싱글턴 인스턴스
        @Volatile private var INSTANCE: KakaoMapPlugin? = null
        
        fun getInstance(context: Context): KakaoMapPlugin {
            return INSTANCE ?: synchronized(this) {
                INSTANCE ?: KakaoMapPlugin(context).also { INSTANCE = it }
            }
        }
    }
    
    private var kakaoMap: KakaoMap? = null
    private var labelManager: LabelManager? = null
    private var labelLayer: LabelLayer? = null
    private val labels = mutableMapOf<String, Label>()
    private var routeLineManager: RouteLineManager? = null
    private var routeLineLayer: RouteLineLayer? = null
    private val routeLines = mutableMapOf<String, RouteLine>()
    private var handler = Handler(Looper.getMainLooper())
    private lateinit var methodChannel: MethodChannel
    
    // KakaoMap 등록 및 초기화

fun registerKakaoMap(map: KakaoMap) {
    Log.d("KakaoMapPlugin", "registerKakaoMap 호출됨: ${map != null}")
    
    this.kakaoMap = map
    
    // LabelManager 초기화
    try {
        // 기존 방식으로 LabelManager 가져오기
        this.labelManager = map.getLabelManager()
        Log.d("KakaoMapPlugin", "LabelManager 초기화 성공: ${labelManager != null}")

        // RouteLineManager 초기화
        try {
            this.routeLineManager = map.getRouteLineManager()
            this.routeLineLayer = routeLineManager?.getLayer()
            Log.d("KakaoMapPlugin", "RouteLineManager 초기화 성공: ${routeLineManager != null}")
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "RouteLineManager 초기화 실패: ${e.message}")
            e.printStackTrace()
        }           
        
        // 커스텀 LabelLayer 생성
        try {
            // 기존 레이어가 있는지 확인
            labelLayer = labelManager?.getLayer("customLabelLayer")
            Log.d("KakaoMapPlugin", "기존 레이어 확인: ${labelLayer != null}")
            
            // 없으면 새로 생성
            if (labelLayer == null) {
                val layerOptions = LabelLayerOptions.from("customLabelLayer")
                    .setOrderingType(OrderingType.Rank)
                    .setCompetitionUnit(CompetitionUnit.IconAndText)
                    .setCompetitionType(CompetitionType.All)
                    .setZOrder(5000)
                
                labelLayer = labelManager?.addLayer(layerOptions)
                Log.d("KakaoMapPlugin", "커스텀 라벨 레이어 생성 성공: ${labelLayer != null}")
            }
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "라벨 레이어 생성 실패: ${e.message}")
            e.printStackTrace()
        }
    } catch (e: Exception) {
        Log.e("KakaoMapPlugin", "LabelManager 초기화 실패: ${e.message}")
        e.printStackTrace()
    }
    
    setupLabelClickListener(map)
}
    
    // 지도 중심 이동
    fun setMapCenter(latitude: Double, longitude: Double, zoomLevel: Int) {
        Log.d("KakaoMapPlugin", "지도 중심 이동: lat=$latitude, lng=$longitude, zoom=$zoomLevel")

        kakaoMap?.let { map ->
            val position = LatLng.from(latitude, longitude)
            // 중심 위치 설정
            val cameraUpdate = CameraUpdateFactory.newCenterPosition(position)
            map.moveCamera(cameraUpdate)
            
            // 줌 레벨 설정
            val zoomUpdate = CameraUpdateFactory.zoomTo(zoomLevel)
            map.moveCamera(zoomUpdate)
        }
    }
    
    // 마커 추가
    fun addMarker(latitude: Double, longitude: Double, title: String?) {
        Log.d("KakaoMapPlugin", "마커 추가: lat=$latitude, lng=$longitude, title=$title")
        
        try {
            val markerId = "marker_${System.currentTimeMillis()}"
            val position = LatLng.from(latitude, longitude)
            
            // 마커 스타일 생성
            val markerStyle = LabelStyle.from(android.R.drawable.ic_menu_mylocation)
            
            // 텍스트가 있는 경우 텍스트 스타일 설정
            if (title != null) {
                markerStyle.setTextStyles(LabelTextStyle.from(16, Color.RED))
            }
            
            // LabelOptions 생성
            val options = LabelOptions.from(position)
                .setStyles(markerStyle)
                .setClickable(true)

            // 텍스트 설정 (title이 있는 경우)
            if (title != null) {
                options.setTexts(LabelTextBuilder().setTexts(title))
            }
            
            // 라벨 추가
            val label = labelLayer?.addLabel(options)
            
            if (label != null) {
                labels[markerId] = label
                Log.d("KakaoMapPlugin", "마커 추가 성공: $markerId")
            } else {
                Log.e("KakaoMapPlugin", "마커 추가 실패: 라벨 생성 실패")
            }
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "마커 추가 실패: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // 라벨 추가
    fun addLabel(
        labelId: String, 
        latitude: Double, 
        longitude: Double, 
        text: String? = null,
        imageAsset: String? = null,
        textColor: Long? = null,
        textSize: Float? = null,
        backgroundColor: Long? = null,
        alpha: Float = 1.0f,
        rotation: Float = 0.0f,
        zIndex: Int = 0,
        isClickable: Boolean = true,
        pinType: Boolean = false
    ) {
        Log.d("KakaoMapPlugin", "라벨 추가 시도: id=$labelId, lat=$latitude, lng=$longitude")
        Log.d("KakaoMapPlugin", "KakaoMap 상태: ${kakaoMap != null}")
        Log.d("KakaoMapPlugin", "LabelManager 상태: ${labelManager != null}")
        Log.d("KakaoMapPlugin", "LabelLayer 상태: ${labelLayer != null}")
        
        labelLayer?.let { layer ->
            try {
                // 이미 존재하는 라벨 ID인 경우 먼저 제거
                if (labels.containsKey(labelId)) {
                    val oldLabel = labels[labelId]
                    if (oldLabel != null) {
                        oldLabel.remove()
                        labels.remove(labelId)
                    }
                }
                
                val position = LatLng.from(latitude, longitude)
                
                // 기본 이미지 리소스 ID
                var resourceId = android.R.drawable.ic_menu_mylocation
                
                // 이미지 리소스 처리
                if (imageAsset != null) {
                    Log.d("KakaoMapPlugin", "이미지 에셋 검색 시도: $imageAsset")
                    
                    // 이미지 매핑 - 특정 이미지 이름 변환
                    val mappedImageAsset = when(imageAsset) {
                        "svg_clover" -> "logo"
                        else -> imageAsset
                    }
                    
                    // 변환된 이름으로 리소스 찾기
                    val customResourceId = context.resources.getIdentifier(
                        mappedImageAsset, 
                        "drawable", 
                        context.packageName
                    )
                    
                    if (customResourceId != 0) {
                        resourceId = customResourceId
                        Log.d("KakaoMapPlugin", "이미지 리소스 찾음: $mappedImageAsset ($customResourceId)")
                    } else {
                        Log.e("KakaoMapPlugin", "이미지 리소스 찾을 수 없음: $mappedImageAsset")
                        resourceId = android.R.drawable.ic_menu_mylocation
                    }
                }
                
                // LabelStyle 생성
                val labelStyle = LabelStyle.from(resourceId)
                
                // 텍스트 스타일 설정
                if (textSize != null) {
                    val color = textColor?.toInt() ?: Color.BLACK
                    
                    val textStyle = LabelTextStyle.from(textSize.toInt(), color)
                    textStyle.stroke = 3
                    textStyle.strokeColor = Color.WHITE
                    labelStyle.setTextStyles(textStyle)
                    
                    Log.d("KakaoMapPlugin", "텍스트 스타일 설정: 커스텀 폰트 적용")
                }
                
                // LabelOptions 생성
                val options = LabelOptions.from(position)
                    .setStyles(labelStyle)
                    .setClickable(isClickable)
                
                // 텍스트가 있으면 설정
                if (text != null) {
                    try {
                        options.setTexts(LabelTextBuilder().setTexts(text))
                        Log.d("KakaoMapPlugin", "라벨 텍스트 설정: \"$text\"")
                    } catch (e: Exception) {
                        Log.e("KakaoMapPlugin", "텍스트 설정 오류: ${e.message}")
                        e.printStackTrace()
                    }
                }
                
                Log.d("KakaoMapPlugin", "라벨 옵션 생성 완료")
                
                // 라벨 생성 및 등록
                val label = layer.addLabel(options)
                
                if (label != null) {
                    // 회전 적용 (필요시)
                    if (rotation != 0.0f) {
                        label.rotateTo(rotation)
                    }
                    
                    labels[labelId] = label
                    Log.d("KakaoMapPlugin", "라벨 추가 성공: $labelId, 위치: ${label.getPosition()}")
                } else {
                    Log.e("KakaoMapPlugin", "라벨 추가 실패: 라벨 생성 실패")
                }
                
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 추가 예외 발생: ${e.message}")
                e.printStackTrace()
            }
        } ?: run {
            Log.e("KakaoMapPlugin", "라벨 레이어가 초기화되지 않았습니다")
        }
    }
    
    // 라벨 제거
    fun removeLabel(labelId: String) {
        Log.d("KakaoMapPlugin", "라벨 제거: $labelId")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                label.remove()
                labels.remove(labelId)
                Log.d("KakaoMapPlugin", "라벨 제거 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 제거 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "제거할 라벨 없음: $labelId")
        }
    }
    
    // 모든 라벨 제거
    fun clearLabels() {
        Log.d("KakaoMapPlugin", "모든 라벨 제거")
        
        try {
            // 각 라벨 제거
            for (label in labels.values) {
                label.remove()
            }
            
            // 맵 초기화
            labels.clear()
            Log.d("KakaoMapPlugin", "모든 라벨 제거 성공")
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "모든 라벨 제거 실패: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // 라벨 위치 업데이트
    fun updateLabelPosition(labelId: String, latitude: Double, longitude: Double) {
        Log.d("KakaoMapPlugin", "라벨 위치 업데이트: id=$labelId, lat=$latitude, lng=$longitude")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                val position = LatLng.from(latitude, longitude)
                label.moveTo(position)
                Log.d("KakaoMapPlugin", "라벨 위치 업데이트 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 위치 업데이트 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "위치 업데이트할 라벨 없음: $labelId")
        }
    }
    
    // 라벨 텍스트 업데이트
    fun updateLabelText(labelId: String, text: String) {
        Log.d("KakaoMapPlugin", "라벨 텍스트 업데이트: id=$labelId, text=$text")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                // label.changeText(text) // 텍스트 변경 메서드 구현 필요
                Log.d("KakaoMapPlugin", "라벨 텍스트 업데이트 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 텍스트 업데이트 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "텍스트 업데이트할 라벨 없음: $labelId")
        }
    }
    
    // 경로 그리기
    fun drawRoute(
        routeId: String, 
        points: List<LatLng>,
        lineColor: Int = Color.BLUE,
        lineWidth: Float = 5f,
        showArrow: Boolean = true
    ) {
        Log.d("KakaoMapPlugin", "경로 그리기 시작: $routeId, 포인트 수: ${points.size}")
        
        if (routeLineLayer == null) {
            Log.e("KakaoMapPlugin", "경로 레이어가 초기화되지 않았습니다")
            return
        }
        
        try {
            // 기존 경로가 있으면 제거
            if (routeLines.containsKey(routeId)) {
                val oldRouteLine = routeLines[routeId]
                oldRouteLine?.remove()
                routeLines.remove(routeId)
            }
            
            // 초록색 라인으로 설정 (색상 #189E1E)
            val greenColor = Color.parseColor("#189E1E")
            val strokeWidth = 4f
            
            // 화살표 패턴 생성 - 줌 레벨에 따라 간격 조정
            val arrowPattern1 = if (showArrow) {
                RouteLinePattern.from(R.drawable.route_arrow, 120f)  // 낮은 줌에서는 간격 넓게
            } else null
            
            val arrowPattern2 = if (showArrow) {
                RouteLinePattern.from(R.drawable.route_arrow, 80f)   // 중간 줌에서는 중간 간격
            } else null
            
            val arrowPattern3 = if (showArrow) {
                RouteLinePattern.from(R.drawable.route_arrow, 50f)   // 높은 줌에서는 간격 좁게
            } else null
            
            // 줌 레벨별 스타일 설정
            val style1 = if (arrowPattern1 != null) {
                RouteLineStyle.from(25f, greenColor, strokeWidth, Color.WHITE, arrowPattern1)
                    .setZoomLevel(10)  // 줌 레벨 10부터 적용 (멀리서 볼 때 굵게)
            } else {
                RouteLineStyle.from(25f, greenColor, strokeWidth, Color.WHITE)
                    .setZoomLevel(10)
            }
                
            val style2 = if (arrowPattern2 != null) {
                RouteLineStyle.from(17f, greenColor, strokeWidth, Color.WHITE, arrowPattern2)
                    .setZoomLevel(14)  // 줌 레벨 14부터 적용 (중간 거리)
            } else {
                RouteLineStyle.from(17f, greenColor, strokeWidth, Color.WHITE)
                    .setZoomLevel(14)
            }
                
            val style3 = if (arrowPattern3 != null) {
                RouteLineStyle.from(15f, greenColor, strokeWidth, Color.WHITE, arrowPattern3)
                    .setZoomLevel(17)  // 줌 레벨 17부터 적용 (가까이서 볼 때 얇게)
            } else {
                RouteLineStyle.from(15f, greenColor, strokeWidth, Color.WHITE)
                    .setZoomLevel(17)
            }
            
            // 여러 스타일을 하나로 묶기
            val routeLineStyles = RouteLineStyles.from(style1, style2, style3)
            
            // 경로 세그먼트 생성 (스타일 모음 적용)
            val segment = RouteLineSegment.from(points, routeLineStyles)
            
            // 경로 옵션 생성
            val options = RouteLineOptions.from(listOf(segment))
            
            // 경로 추가
            val routeLine = routeLineLayer?.addRouteLine(options)
            
            if (routeLine != null) {
                routeLines[routeId] = routeLine
                Log.d("KakaoMapPlugin", "경로 그리기 성공: $routeId")
            } else {
                Log.e("KakaoMapPlugin", "경로 그리기 실패")
            }
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "경로 그리기 오류: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // 경로 제거
    fun removeRoute(routeId: String) {
        Log.d("KakaoMapPlugin", "경로 제거: $routeId")
        
        val routeLine = routeLines[routeId]
        if (routeLine != null) {
            try {
                routeLine.remove()
                routeLines.remove(routeId)
                Log.d("KakaoMapPlugin", "경로 제거 성공: $routeId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "경로 제거 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "제거할 경로 없음: $routeId")
        }
    }
    
    // 모든 경로 제거
    fun clearRoutes() {
        Log.d("KakaoMapPlugin", "모든 경로 제거")
        
        try {
            for (routeLine in routeLines.values) {
                routeLine.remove()
            }
            routeLines.clear()
            Log.d("KakaoMapPlugin", "모든 경로 제거 성공")
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "모든 경로 제거 실패: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // 라벨 스타일 업데이트
    fun updateLabelStyle(
        labelId: String, 
        textColor: Int? = null, 
        textSize: Float? = null, 
        backgroundColor: Int? = null, 
        alpha: Float? = null, 
        rotation: Float? = null, 
        zIndex: Long? = null
    ) {
        Log.d("KakaoMapPlugin", "라벨 스타일 업데이트: $labelId")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                // 기존 스타일 가져오기
                val oldStyles = label.getStyles()
                
                // 새 스타일 생성
                val resourceId = android.R.drawable.ic_menu_mylocation // 기본 이미지
                val labelStyle = LabelStyle.from(resourceId)
                
                // 텍스트 스타일 설정
                if (textSize != null && textColor != null) {
                    labelStyle.setTextStyles(LabelTextStyle.from(textSize.toInt(), textColor))
                }
                
                // 스타일 변경 적용
                label.changeStyles(LabelStyles.from(labelStyle))
                
                // 회전 설정 (있다면)
                if (rotation != null) {
                    label.rotateTo(rotation)
                }
                
                // rank 설정 (있다면)
                if (zIndex != null) {
                    label.changeRank(zIndex)
                }
                Log.d("KakaoMapPlugin", "라벨 스타일 업데이트 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 스타일 업데이트 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "스타일 업데이트할 라벨 없음: $labelId")
        }
    }
    
    // 메서드 채널 설정
    fun setMethodChannel(channel: MethodChannel) {
        this.methodChannel = channel
    }
    
    // 라벨 클릭 리스너 설정
    fun setupLabelClickListener(map: KakaoMap) {
        map.setOnLabelClickListener { kakaoMap, layer, label ->
            val clickedLabelId = labels.entries.find { it.value == label }?.key
            
            if (clickedLabelId != null) {
                Log.d("KakaoMapPlugin", "라벨 클릭됨: $clickedLabelId")
                
                // Flutter로 이벤트 전송
                try {
                    val arguments = HashMap<String, Any>()
                    arguments["labelId"] = clickedLabelId
                    methodChannel.invokeMethod("onLabelClick", arguments)
                    Log.d("KakaoMapPlugin", "Flutter로 라벨 클릭 이벤트 전송 성공")
                } catch (e: Exception) {
                    Log.e("KakaoMapPlugin", "Flutter로 이벤트 전송 실패: ${e.message}")
                }
                
                // 펄스 애니메이션 추가
                addPulseAnimation(label)
                
                true // 이벤트 처리 완료
            } else {
                false // 이벤트 처리 안함
            }
        }
    }
    
    // 펄스 애니메이션 추가
    fun addPulseAnimation(label: Label) {
        try {
            // 확대 및 축소 애니메이션 구현
            val originalScale = 1.0f
            
            // 확대 (2.5배)
            label.scaleTo(2.5f, 2.5f, 400)
            
            // 원래 크기로 돌아오기
            handler.postDelayed({
                label.scaleTo(originalScale, originalScale, 500)
                
                // 회전 효과 추가 (약간의 흔들림 효과)
                val currentRotation = label.getRotation()
                
                handler.postDelayed({
                    // 오른쪽으로 살짝 회전
                    label.rotateTo(currentRotation + 0.3f, 100)
                    
                    handler.postDelayed({
                        // 왼쪽으로 살짝 회전
                        label.rotateTo(currentRotation - 0.3f, 100)
                        
                        handler.postDelayed({
                            // 원래 위치로 복귀
                            label.rotateTo(currentRotation, 100)
                        }, 100)
                    }, 100)
                }, 50)
            }, 200)
            
            Log.d("KakaoMapPlugin", "펄스 애니메이션 시작됨")
        } catch (e: Exception) {
            Log.e("KakaoMapPlugin", "펄스 애니메이션 실패: ${e.message}")
            e.printStackTrace()
        }
    }
    
    // 라벨 가시성 설정
    fun setLabelVisibility(labelId: String, isVisible: Boolean) {
        Log.d("KakaoMapPlugin", "라벨 가시성 설정: id=$labelId, visible=$isVisible")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                if (isVisible) {
                    label.show()
                } else {
                    label.hide()
                }
                Log.d("KakaoMapPlugin", "라벨 가시성 설정 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 가시성 설정 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "가시성 설정할 라벨 없음: $labelId")
        }
    }
}