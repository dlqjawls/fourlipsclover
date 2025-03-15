import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import 'widgets/logo_section.dart';
import 'widgets/search_bar.dart';
import 'widgets/hashtag_selector.dart';
import 'widgets/local_favorites.dart';
import 'widgets/category_recommendations.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 화면 크기 정보 가져오기
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white, // 명시적으로 흰색 배경 지정
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 로고 섹션과 상단 여백 추가
              Padding(
                padding: const EdgeInsets.only(top: 24.0),
                child: LogoSection(),
              ),

              // 상단 섹션 (위젯 간 간격 증가)
              const SizedBox(height: 32.0),

              // 검색바
              CustomSearchBar(),

              // 해시태그 선택기 (약간의 음수 마진으로 더 가깝게 배치)
              Transform.translate(
                offset: const Offset(0, -10),
                child: HashtagSelector(),
              ),

              // 첫 화면에서 보이는 상단 섹션과 하단 콘텐츠 사이 공간
              SizedBox(height: screenHeight * 0.12),

              // 하단 콘텐츠
              LocalFavorites(),
              const SizedBox(height: 24),
              CategoryRecommendations(),
              const SizedBox(height: 32), // 하단 여백 추가
            ],
          ),
        ),
      ),
    );
  }
}
