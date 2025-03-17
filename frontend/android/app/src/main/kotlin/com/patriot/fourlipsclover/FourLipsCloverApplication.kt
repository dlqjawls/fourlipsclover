package com.patriot.fourlipsclover

import android.app.Application
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.os.Bundle
import com.kakao.vectormap.KakaoMapSdk
import android.util.Log

class FourLipsCloverApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        
        try {
            // 메타데이터에서 API 키 가져오기
            val applicationInfo: ApplicationInfo = packageManager.getApplicationInfo(
                packageName, PackageManager.GET_META_DATA
            )
            val bundle: Bundle = applicationInfo.metaData
            val apiKey: String = bundle.getString("com.kakao.vectormap.APP_KEY", "")
            
            Log.d("KakaoMapApp", "카카오맵 SDK 초기화 시도")
            KakaoMapSdk.init(this, apiKey)
            Log.d("KakaoMapApp", "카카오맵 SDK 초기화 성공")
        } catch (e: Exception) {
            Log.e("KakaoMapApp", "카카오맵 SDK 초기화 실패: ${e.message}")
            e.printStackTrace()
        }
    }
}