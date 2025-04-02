import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/models/matching/matching_tag_model.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_location.dart';
import 'package:frontend/services/matching/tag_service.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_location.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';

class MatchingCreateHashtagScreen extends StatefulWidget {
  const MatchingCreateHashtagScreen({Key? key}) : super(key: key);

  @override
  State<MatchingCreateHashtagScreen> createState() =>
      _MatchingCreateHashtagScreenState();
}

class _MatchingCreateHashtagScreenState
    extends State<MatchingCreateHashtagScreen>
    with TickerProviderStateMixin {
  final TagService _tagService = TagService();
  List<Tag> tags = [];
  List<String> categories = [];
  late TabController _tabController;
  bool isLoading = true;

  final Set<String> selectedHashtags = {};

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    try {
      final loadedTags = await _tagService.getTags();
      setState(() {
        tags = loadedTags;
        categories = loadedTags.map((tag) => tag.category).toSet().toList();
        _tabController = TabController(length: categories.length, vsync: this);
        isLoading = false;
      });
    } catch (e) {
      print('태그 로드 실패: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget _buildSelectedTag(String tag) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0, top: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tag,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: () {
                setState(() {
                  selectedHashtags.remove(tag);
                });
              },
              child: const Icon(Icons.close, color: Colors.white, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        appBar: MatchingStyles.buildAppBar(context, '선호하는 맛집 스타일'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '선호하는 맛집 스타일'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(0.3),

          // 카테고리 탭바
          TabBar(
            controller: _tabController,
            isScrollable: true,
            tabs: categories.map((category) => Tab(text: category)).toList(),
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.mediumGray,
            indicatorColor: AppColors.primary,
          ),

          // Selected tags preview
          if (selectedHashtags.isNotEmpty)
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children:
                    selectedHashtags
                        .map((tag) => _buildSelectedTag(tag))
                        .toList(),
              ),
            ),

          // Tag grid by category
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children:
                  categories.map((category) {
                    final categoryTags =
                        tags.where((tag) => tag.category == category).toList();
                    return _buildTagGrid(categoryTags);
                  }).toList(),
            ),
          ),

          // Next button
          Padding(
            padding: MatchingStyles.defaultPadding,
            child: ElevatedButton(
              onPressed:
                  selectedHashtags.isNotEmpty
                      ? () {
                        final selectedTagObjects =
                            tags
                                .where(
                                  (tag) => selectedHashtags.contains(tag.name),
                                )
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
              style: MatchingStyles.buttonStyle,
              child: Text('다음', style: MatchingStyles.buttonTextStyle),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagGrid(List<Tag> categoryTags) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 2.5,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: categoryTags.length,
        itemBuilder: (context, index) {
          final tag = categoryTags[index];
          final isSelected = selectedHashtags.contains(tag.name);

          return _buildTagButton(tag, isSelected);
        },
      ),
    );
  }

  Widget _buildTagButton(Tag tag, bool isSelected) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            if (isSelected) {
              selectedHashtags.remove(tag.name);
            } else if (selectedHashtags.length < 3) {
              selectedHashtags.add(tag.name);
            }
          });
        },
        borderRadius: BorderRadius.circular(25),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGray,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Center(
            child: Text(
              tag.name,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGray,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
