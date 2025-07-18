// lib/screens/home/widgets/hashtag_selector.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/theme.dart';
import '../../../providers/search_provider.dart';
import '../../../providers/tag_provider.dart';
import '../../../models/tag_model.dart';
import '../../../widgets/clover_loading_spinner.dart';

class HashtagSelector extends StatefulWidget {
  // 태그 선택 콜백 추가 (필요한 경우)
  final Function(String)? onTagSelected;
  
  const HashtagSelector({Key? key, this.onTagSelected}) : super(key: key);

  @override
  _HashtagSelectorState createState() => _HashtagSelectorState();
}

class _HashtagSelectorState extends State<HashtagSelector> with AutomaticKeepAliveClientMixin {
  
  String? selectedCategory;
  bool isExpanded = false;

  // AutomaticKeepAliveClientMixin 구현
  @override
  bool get wantKeepAlive => true;

  // 대분류 카테고리와 아이콘 정의
  final List<Map<String, dynamic>> categoriesWithIcons = [
    {'name': '맛', 'icon': Icons.restaurant, 'color': Color(0xFFE53935)}, // 빨간색
    {'name': '분위기', 'icon': Icons.mood, 'color': Color(0xFF8E24AA)}, // 보라색
    {'name': '서비스', 'icon': Icons.room_service, 'color': Color(0xFF43A047)}, // 녹색
    {'name': '인테리어/공간', 'icon': Icons.chair, 'color': Color(0xFF1E88E5)}, // 파란색
    {'name': '가격/가성비', 'icon': Icons.monetization_on, 'color': Color(0xFFFFB300)}, // 금색
    {'name': '음식종류/스타일', 'icon': Icons.fastfood, 'color': Color(0xFFFF6F00)}, // 주황색
    {'name': '편의/서비스', 'icon': Icons.emoji_transportation, 'color': Color(0xFF00897B)}, // 청록색
    {'name': '작업', 'icon': Icons.laptop, 'color': Color(0xFF5E35B1)}, // 짙은 보라색
  ];

  // 초기에 보여줄 카테고리 개수
  final int initialCategoryCount = 3;

  @override
  void initState() {
    super.initState();
    // 컴포넌트가 로드될 때 태그 데이터 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // API에서 태그 데이터 가져오기
      final tagProvider = Provider.of<TagProvider>(context, listen: false);
      tagProvider.fetchTags();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 상태 유지
  }

  void _handleCategorySelection(String category) {
    setState(() {
      if (selectedCategory == category) {
        selectedCategory = null; // 이미 선택된 카테고리를 다시 클릭하면 선택 해제
      } else {
        selectedCategory = category; // 새 카테고리 선택
      }
    });
  }

  void _handleTagSelection(TagModel tag) {
    final tagName = '#${tag.name}';
    print('HashtagSelector: 태그 선택됨 - $tagName, ID: ${tag.tagId}');
    
    // SearchProvider에 태그 추가
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    print('HashtagSelector: 기존 태그 목록 - ${searchProvider.selectedTags}');
    
    // 태그가 이미 목록에 있으면 추가하지 않음
    if (!searchProvider.selectedTags.contains(tagName)) {
      // 태그 이름과 ID를 함께 추가
      searchProvider.addTagWithId(tagName, tag.tagId);
      print('HashtagSelector: 업데이트된 태그 목록 - ${searchProvider.selectedTags}');
      print('HashtagSelector: 업데이트된 태그 ID 목록 - ${searchProvider.selectedTagIds}');
    }
    
    // 태그 선택 콜백이 있으면 호출
    if (widget.onTagSelected != null) {
      widget.onTagSelected!(tagName);
    }
  }

  // 하드코딩된 태그 선택 핸들러 (API 실패 시 폴백용)
  void _handleHardcodedTagSelection(String hashtag) {
    print('HashtagSelector: 하드코딩된 태그 선택됨 - $hashtag');
    
    // SearchProvider에 태그 추가
    final searchProvider = Provider.of<SearchProvider>(context, listen: false);
    print('HashtagSelector: 기존 태그 목록 - ${searchProvider.selectedTags}');
    
    // 태그가 이미 목록에 있으면 추가하지 않음
    if (!searchProvider.selectedTags.contains(hashtag)) {
      searchProvider.addTag(hashtag);
      print('HashtagSelector: 업데이트된 태그 목록 - ${searchProvider.selectedTags}');
    }
    
    // 태그 선택 콜백이 있으면 호출
    if (widget.onTagSelected != null) {
      widget.onTagSelected!(hashtag);
    }
  }

  // 카테고리 아이콘 가져오기
  IconData _getCategoryIcon(String categoryName) {
    final category = categoriesWithIcons.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => {'name': categoryName, 'icon': Icons.tag, 'color': Colors.grey},
    );
    return category['icon'];
  }
  
  // 카테고리 색상 가져오기
  Color _getCategoryColor(String categoryName) {
    final category = categoriesWithIcons.firstWhere(
      (category) => category['name'] == categoryName,
      orElse: () => {'name': categoryName, 'icon': Icons.tag, 'color': Colors.grey},
    );
    return category['color'];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin 요구사항
    
    return Consumer2<SearchProvider, TagProvider>(
      builder: (context, searchProvider, tagProvider, child) {
        final selectedTags = searchProvider.selectedTags;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 대분류 카테고리 Wrap
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // 초기에는 3개만 표시, 확장 시 전체 표시
                  ...isExpanded
                      ? categoriesWithIcons.map((category) => _buildCategoryItem(category['name'], category['icon']))
                      : categoriesWithIcons.take(initialCategoryCount).map((category) => _buildCategoryItem(category['name'], category['icon'])),
    
                  // 확장/축소 버튼
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGray),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        size: 16,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
    
              // 선택된 카테고리가 있으면 해당 카테고리의 태그 표시
              if (selectedCategory != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 구분선 추가
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(color: AppColors.lightGray, thickness: 1),
                    ),
    
                    // 카테고리 제목 표시 (아이콘 포함)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Icon(
                            _getCategoryIcon(selectedCategory!),
                            size: 16,
                            color: _getCategoryColor(selectedCategory!),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${selectedCategory} 태그',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
    
                    // API 로딩 중인 경우 로딩 스피너 표시
                    if (tagProvider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CloverLoadingSpinner(size: 24),
                        ),
                      )
                    // API 에러가 있는 경우 에러 메시지와 하드코딩된 태그 표시
                    else if (tagProvider.error != null)
                      _buildHardcodedTagsSection(selectedCategory!, selectedTags)
                    // API에서 가져온 태그 표시
                    else if (tagProvider.tags.isNotEmpty)
                      _buildApiTagsSection(tagProvider, selectedCategory!, selectedTags)
                    // API 응답은 성공했으나 태그가 없는 경우 하드코딩된 태그 표시
                    else
                      _buildHardcodedTagsSection(selectedCategory!, selectedTags),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  // API에서 가져온 태그 목록 표시 (카테고리별)
  Widget _buildApiTagsSection(TagProvider tagProvider, String category, List<String> selectedTags) {
    // 선택된 카테고리에 해당하는 태그만 필터링
    final categoryTags = tagProvider.tagsByCategory[category] ?? [];
    
    // 이미 선택된 태그와 충돌하지 않도록 해시태그(#) 접두사를 포함해 비교
    final filteredTags = categoryTags
        .where((tag) => !selectedTags.contains('#${tag.name}'))
        .toList();
    
    if (filteredTags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          '이 카테고리에 표시할 태그가 없습니다',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredTags
          .map((tag) => _buildApiTagItem(tag))
          .toList(),
    );
  }

  // 하드코딩된 태그 목록 표시 (API 실패 시 폴백)
  Widget _buildHardcodedTagsSection(String category, List<String> selectedTags) {
    // 하드코딩된 카테고리별 태그 맵
    final Map<String, List<String>> hardcodedTags = {
      '맛': ['#매운맛', '#단맛', '#짠맛', '#고소한', '#양많이', '#담백한', '#새콤한', '#진한', '#신선한'],
      '분위기': [
        '#조용한', '#아늑한', '#활기찬', '#모던한', '#전통적인', '#이색적인', '#낭만적인',
        '#분위기좋은', '#데이트코스', '#노포감성', '#데이트맛집', '#캐주얼한', '#세련된',
      ],
      '서비스': [
        '#친절한', '#세심한', '#빠른', '#프로페셔널한', '#웨이팅', '#재방문많은곳',
        '#정확한', '#따뜻한', '#개인맞춤형',
      ],
      '인테리어/공간': [
        '#모던', '#빈티지', '#인더스트리얼', '#심플', '#감각적인', '#넓은', '#아담한',
        '#프라이빗한', '#오픈스페이스', '#넓은매장', '#사진명당', '#깨끗한화장실', '#뷰맛집',
      ],
      '가격/가성비': [
        '#고급', '#중간', '#저렴한', '#가성비좋은', '#점심특선', '#특가메뉴', '#프리미엄', '#할인이벤트',
      ],
      '음식종류/스타일': [
        '#한식', '#양식', '#중식', '#일식', '#퓨전', '#건강식', '#채식', '#해산물전문',
        '#구워주는고기집', '#인당주문', '#파인다이닝', '#이자카야', '#무한리필', '#야식',
      ],
      '편의/서비스': [
        '#주차가능', '#혼밥', '#단체모임', '#가족과함께', '#회식가능', '#24시운영',
        '#이벤트가능', '#예약가능', '#키즈존', '#혼술',
      ],
      '작업': [
        '#모각코가능', '#조용한분위기', '#편안한책상', '#와이파이완비', '#전기콘센트풍부',
        '#작업하기좋은', '#공유오피스느낌', '#커피맛집', '#집중력UP', '#공부하기좋은',
      ],
    };
    
    // 현재 카테고리의 태그 목록 가져오기 (없으면 빈 목록)
    final tags = hardcodedTags[category] ?? [];
    
    // 이미 선택된 태그 제외
    final filteredTags = tags.where((tag) => !selectedTags.contains(tag)).toList();
    
    if (filteredTags.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text(
          '더 이상 선택할 수 있는 태그가 없습니다',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.mediumGray,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: filteredTags
          .map((tag) => _buildHardcodedTagItem(tag))
          .toList(),
    );
  }

  Widget _buildCategoryItem(String category, IconData icon) {
    final isSelected = selectedCategory == category;
    final Color iconColor = _getCategoryColor(category);

    return GestureDetector(
      onTap: () => _handleCategorySelection(category),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGray,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Row의 크기를 내용물에 맞게 조정
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : iconColor,
            ),
            const SizedBox(width: 4), // 아이콘과 텍스트 사이 간격
            Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiTagItem(TagModel tag) {
    return GestureDetector(
      onTap: () => _handleTagSelection(tag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Text(
          '#${tag.name}',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildHardcodedTagItem(String hashtag) {
    return GestureDetector(
      onTap: () => _handleHardcodedTagSelection(hashtag),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.lightGray),
        ),
        child: Text(
          hashtag,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.darkGray,
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
    );
  }
}