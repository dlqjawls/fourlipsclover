// 🍀 네잎 클로버 테마 기반 UI/UX 최적화 (최종 수정)

import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/matching/matching_tag_model.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_location.dart';
import 'package:frontend/services/matching/tag_service.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/widgets/loading_overlay.dart';

class MatchingCreateHashtagScreen extends StatefulWidget {
  const MatchingCreateHashtagScreen({Key? key}) : super(key: key);

  @override
  State<MatchingCreateHashtagScreen> createState() =>
      _MatchingCreateHashtagScreenState();
}

class _MatchingCreateHashtagScreenState
    extends State<MatchingCreateHashtagScreen> {
  final TagService _tagService = TagService();
  List<Tag> tags = [];
  String? selectedCategory;
  bool isLoading = true;
  bool isNetworkError = false;
  final Set<String> selectedHashtags = {};

  final List<Map<String, dynamic>> categoriesWithIcons = [
    {'name': '맛', 'icon': Icons.restaurant, 'color': Color(0xFFE53935)},
    {'name': '분위기', 'icon': Icons.mood, 'color': Color(0xFF8E24AA)},
    {'name': '서비스', 'icon': Icons.room_service, 'color': Color(0xFF43A047)},
    {'name': '인테리어/공간', 'icon': Icons.chair, 'color': Color(0xFF1E88E5)},
    {
      'name': '가격/가성비',
      'icon': Icons.monetization_on,
      'color': Color(0xFFFFB300),
    },
    {'name': '음식종류/스타일', 'icon': Icons.fastfood, 'color': Color(0xFFFF6F00)},
    {
      'name': '편의/서비스',
      'icon': Icons.emoji_transportation,
      'color': Color(0xFF00897B),
    },
    {'name': '작업', 'icon': Icons.laptop, 'color': Color(0xFF5E35B1)},
  ];

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      isLoading = true;
      isNetworkError = false;
    });

    try {
      final loadedTags = await _tagService.getTags();
      if (!mounted) return;
      setState(() {
        tags = loadedTags;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isNetworkError = true;
      });
      _showErrorSnackbar();
    }
  }

  void _showErrorSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('네트워크 연결을 확인해주세요'),
          ],
        ),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: '재시도',
          textColor: Colors.white,
          onPressed: _loadTags,
        ),
      ),
    );
  }

  void _handleCategorySelection(String category) {
    setState(() {
      selectedCategory = selectedCategory == category ? null : category;
    });
  }

  IconData _getCategoryIcon(String categoryName) =>
      categoriesWithIcons.firstWhere(
        (c) => c['name'] == categoryName,
        orElse: () => {'icon': Icons.tag},
      )['icon'];

  Color _getCategoryColor(String categoryName) =>
      categoriesWithIcons.firstWhere(
        (c) => c['name'] == categoryName,
        orElse: () => {'color': Colors.grey},
      )['color'];

  @override
  Widget build(BuildContext context) {
    if (isNetworkError) return _buildErrorScreen();

    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '선호하는 맛집 스타일'),
      body: LoadingOverlay(
        isLoading: isLoading,
        overlayColor: Colors.white.withOpacity(0.7),
        minDisplayTime: const Duration(milliseconds: 1200),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MatchingStyles.buildProgressIndicator(0.3),
              const SizedBox(height: 12),
              _buildCategories(),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  '최대 3개 선택 가능 (선택됨: ${selectedHashtags.length})',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.mediumGray,
                  ),
                ),
              ),
              if (selectedHashtags.isNotEmpty) _buildSelectedTagsList(),
              if (selectedCategory != null) _buildTagsForCategory(),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildNextButton(),
    );
  }

  Widget _buildErrorScreen() => Scaffold(
    body: Center(
      child: ElevatedButton(onPressed: _loadTags, child: const Text('다시 시도')),
    ),
  );

  Widget _buildCategories() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Wrap(
      spacing: 12,
      runSpacing: 12,
      children:
          categoriesWithIcons
              .map((category) => _buildCategoryChip(category['name']))
              .toList(),
    ),
  );

  Widget _buildCategoryChip(String category) {
    final isSelected = selectedCategory == category;
    return AnimatedScale(
      scale: isSelected ? 1.05 : 1.0,
      duration: const Duration(milliseconds: 200),
      child: GestureDetector(
        onTap: () => _handleCategorySelection(category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isSelected ? AppColors.primaryDark : AppColors.lightGray,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.25),
                        offset: Offset(0, 2),
                        blurRadius: 6,
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getCategoryIcon(category),
                size: 16,
                color: isSelected ? Colors.white : _getCategoryColor(category),
              ),
              const SizedBox(width: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTagsForCategory() {
    final categoryTags =
        tags.where((tag) => tag.category == selectedCategory).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getCategoryIcon(selectedCategory!),
                size: 16,
                color: _getCategoryColor(selectedCategory!),
              ),
              const SizedBox(width: 4),
              Text(
                '$selectedCategory 태그',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: categoryTags.map((tag) => _buildTagChip(tag)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip(Tag tag) {
    final isSelected = selectedHashtags.contains(tag.name);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap:
            () => setState(() {
              if (isSelected) {
                selectedHashtags.remove(tag.name);
              } else if (selectedHashtags.length < 3) {
                selectedHashtags.add(tag.name);
              }
            }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGray,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.2),
                        blurRadius: 4,
                      ),
                    ]
                    : [],
          ),
          child: Text(
            '#${tag.name}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.darkGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedTagsList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children:
            selectedHashtags
                .map(
                  (tag) => GestureDetector(
                    onTap: () => setState(() => selectedHashtags.remove(tag)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.lightGray),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        '#$tag',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
      ),
    );
  }

  Widget _buildNextButton() {
    final isEnabled = selectedHashtags.isNotEmpty;
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: ElevatedButton(
          onPressed:
              isEnabled
                  ? () {
                    final selectedTagObjects =
                        tags
                            .where((tag) => selectedHashtags.contains(tag.name))
                            .toList();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MatchingLocationScreen(
                              selectedTags: selectedTagObjects,
                            ),
                      ),
                    );
                  }
                  : null,
          style: MatchingStyles.buttonStyle.copyWith(
            backgroundColor: MaterialStateProperty.all(
              isEnabled ? AppColors.primary : AppColors.lightGray,
            ),
            elevation: MaterialStateProperty.all(isEnabled ? 2 : 0),
          ),
          child: const Text('다음', style: MatchingStyles.buttonTextStyle),
        ),
      ),
    );
  }
}
