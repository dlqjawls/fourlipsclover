package com.patriot.fourlipsclover.kakao

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import io.flutter.plugin.platform.PlatformView
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.KakaoMapReadyCallback
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.MapLifeCycleCallback
import com.kakao.vectormap.MapView
import com.kakao.vectormap.camera.CameraUpdateFactory
import android.util.Log

class KakaoMapView(
    private val context: Context,
    private val viewId: Int,
    private val creationParams: Map<String?, Any?>?
) : PlatformView {
    
    private val mapView: MapView
    private val layout: FrameLayout
    
    private val latitude: Double = creationParams?.get("latitude") as? Double ?: 37.5665
    private val longitude: Double = creationParams?.get("longitude") as? Double ?: 126.9780
    private val zoomLevel: Int = creationParams?.get("zoomLevel") as? Int ?: 3
    
    init {
        android.util.Log.d("KakaoMapView", "지도 뷰 초기화 시작")
        layout = FrameLayout(context)
        mapView = MapView(context)
        layout.addView(mapView)
        
        // 지도 시작
        mapView.start(object : MapLifeCycleCallback() {
            override fun onMapDestroy() {
                android.util.Log.d("KakaoMapView", "지도 제거됨")
            }
            
            override fun onMapError(p0: Exception?) {
                android.util.Log.e("KakaoMapView", "지도 오류 발생: ${p0?.message}")
                p0?.printStackTrace()
            }
        }, object : KakaoMapReadyCallback() {
            override fun onMapReady(kakaoMap: KakaoMap) {
                android.util.Log.d("KakaoMapView", "지도 준비 완료")
                // 초기 위치 설정
                val position = LatLng.from(latitude, longitude)
                val cameraUpdate = CameraUpdateFactory.newCenterPosition(position)
                kakaoMap.moveCamera(cameraUpdate)
                
                // 줌 레벨 설정
                val zoomUpdate = CameraUpdateFactory.zoomTo(zoomLevel)
                kakaoMap.moveCamera(zoomUpdate)
                
                // MainActivity 참조 제거, 필요시 나중에 추가
            }
        })
    }
    
    override fun getView(): View {
        return layout
    }
    
@Override
override fun dispose() {
    try {
        Log.d("KakaoMapView", "dispose 호출")
        mapView.pause()
    } catch (e: Exception) {
        Log.e("KakaoMapView", "dispose 오류: ${e.message}")
        e.printStackTrace()
    }
}
}