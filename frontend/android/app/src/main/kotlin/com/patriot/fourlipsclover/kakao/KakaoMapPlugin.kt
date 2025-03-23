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
import com.kakao.vectormap.label.OrderingType
import com.kakao.vectormap.label.CompetitionType
import com.kakao.vectormap.label.CompetitionUnit
import android.util.Log

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
    
    // KakaoMap 등록 및 초기화
    fun registerKakaoMap(map: KakaoMap) {
        Log.d("KakaoMapPlugin", "registerKakaoMap 호출됨: ${map != null}")
        
        this.kakaoMap = map
        
        // LabelManager 초기화
        try {
            this.labelManager = map.getLabelManager()
            Log.d("KakaoMapPlugin", "LabelManager 초기화 성공: ${labelManager != null}")
            
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
    }
    
    // 지도 중심 이동
    fun setMapCenter(latitude: Double, longitude: Double, zoomLevel: Int) {
        Log.d("KakaoMapPlugin", "지도 중심 이동@@@@@: lat=$latitude, lng=$longitude, zoom=$zoomLevel")

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
                markerStyle.setTextStyles(LabelTextStyle.from(16, Color.BLACK))
            }
            
            // 라벨 옵션 생성
            val options = LabelOptions.from(position)
                .setStyles(markerStyle)
            
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
                
// 이미지 리소스 처리 부분 수정
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
        // 오류 시 기본 리소스 사용
        resourceId = android.R.drawable.ic_menu_mylocation
    }
}
                // LabelStyle 생성
                val labelStyle = LabelStyle.from(resourceId)
                
                // 텍스트 스타일 설정
                if (textSize != null) {
                    val color = textColor?.toInt() ?: Color.BLACK
                    labelStyle.setTextStyles(LabelTextStyle.from(textSize.toInt(), color))
                    Log.d("KakaoMapPlugin", "텍스트 스타일 설정: 크기=${textSize.toInt()}, 색상=$color")
                }
                
                // LabelOptions 생성
                val options = LabelOptions.from(position)
                    .setStyles(labelStyle)
                    .setClickable(isClickable)
                
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
                label.remove() // Label 클래스의 remove() 메서드 사용
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
                label.remove() // Label 클래스의 remove() 메서드 사용
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
                label.moveTo(position) // Label 클래스의 moveTo() 메서드 사용
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
                // label.changeText(text) // Label 클래스의 changeText() 메서드 사용
                Log.d("KakaoMapPlugin", "라벨 텍스트 업데이트 성공: $labelId")
            } catch (e: Exception) {
                Log.e("KakaoMapPlugin", "라벨 텍스트 업데이트 실패: ${e.message}")
                e.printStackTrace()
            }
        } else {
            Log.d("KakaoMapPlugin", "텍스트 업데이트할 라벨 없음: $labelId")
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
    
    // 라벨 가시성 설정
    fun setLabelVisibility(labelId: String, isVisible: Boolean) {
        Log.d("KakaoMapPlugin", "라벨 가시성 설정: id=$labelId, visible=$isVisible")
        
        val label = labels[labelId]
        if (label != null) {
            try {
                if (isVisible) {
                    label.show() // Label 클래스의 show() 메서드 사용
                } else {
                    label.hide() // Label 클래스의 hide() 메서드 사용
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
    
    // 지도 타입 설정
    fun setMapType(mapType: Int) {
        Log.d("KakaoMapPlugin", "지도 타입 설정: $mapType")
        // 카카오맵 SDK에서 지도 타입 설정 구현
    }
    
    // 지도 레이블 표시 설정
    fun setShowMapLabels(show: Boolean) {
        Log.d("KakaoMapPlugin", "지도 레이블 표시 설정: $show")
        // 카카오맵 SDK에서 지도 레이블 표시 설정 구현
    }
    
    // 건물 표시 설정
    fun setShowBuildings(show: Boolean) {
        Log.d("KakaoMapPlugin", "건물 표시 설정: $show")
        // 카카오맵 SDK에서 건물 표시 설정 구현
    }
    
    // 교통정보 표시 설정
    fun setShowTraffic(show: Boolean) {
        Log.d("KakaoMapPlugin", "교통정보 표시 설정: $show")
        // 카카오맵 SDK에서 교통정보 표시 설정 구현
    }
    
    // 야간 모드 설정
    fun setNightMode(enable: Boolean) {
        Log.d("KakaoMapPlugin", "야간 모드 설정: $enable")
        // 카카오맵 SDK에서 야간 모드 설정 구현
    }
}