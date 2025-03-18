package com.patriot.fourlipsclover.kakao

import android.content.Context
import com.kakao.vectormap.KakaoMap
import com.kakao.vectormap.LatLng
import com.kakao.vectormap.camera.CameraUpdateFactory

class KakaoMapPlugin(private val context: Context) {
    
    private var kakaoMap: KakaoMap? = null
    
    fun registerKakaoMap(map: KakaoMap) {
        this.kakaoMap = map
    }
    
    fun setMapCenter(latitude: Double, longitude: Double, zoomLevel: Int) {
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
    
    // 마커 기능은 주석 처리
    fun addMarker(latitude: Double, longitude: Double, title: String?) {
        // 나중에 구현
    }
}