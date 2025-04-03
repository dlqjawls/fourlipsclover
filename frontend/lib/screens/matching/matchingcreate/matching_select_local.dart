import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_resist.dart';
import 'package:frontend/widgets/skeleton_loading.dart';
import 'package:frontend/models/matching/matching_region.dart';
import 'package:frontend/models/matching/matching_tag_model.dart';
import 'package:frontend/models/matching/matching_guide_model.dart';
import 'package:frontend/services/matching/matching_guide.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MatchingSelectLocalScreen extends StatefulWidget {
  final Region selectedRegion;
  final List<Tag> selectedTags;

  const MatchingSelectLocalScreen({
    Key? key,
    required this.selectedRegion,
    required this.selectedTags,
  }) : super(key: key);

  @override
  State<MatchingSelectLocalScreen> createState() =>
      _MatchingSelectLocalScreenState();
}

class _MatchingSelectLocalScreenState extends State<MatchingSelectLocalScreen> {
  final LocalGuideService _guideService = LocalGuideService();
  List<LocalGuide> _guides = [];
  String _selectedFilter = '전체';
  String? _selectedSort;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadGuides();
  }

  Future<void> _loadGuides() async {
    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) {
        throw Exception('사용자 ID를 찾을 수 없습니다.');
      }

      debugPrint('현재 사용자 ID: $userId');
      debugPrint('선택된 지역 ID: ${widget.selectedRegion.regionId}');

      final guides = await _guideService.getLocalGuides(
        int.parse(userId),
        widget.selectedRegion.regionId,
      );

      // 가이드 정보 검증
      for (var guide in guides) {
        debugPrint(
          '가이드 정보: id=${guide.id}, memberId=${guide.memberId}, nickname=${guide.nickname}',
        );
      }

      if (!mounted) return;

      setState(() {
        _guides = guides;
        _error = '';
      });
    } catch (e) {
      if (!mounted) return;
      debugPrint('가이드 정보 로드 중 오류: $e');
      setState(() => _error = '가이드 정보를 불러오는데 실패했습니다: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<LocalGuide> get _filteredGuides {
    var filtered = List<LocalGuide>.from(_guides);

    if (_selectedFilter == '인기') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedFilter == '신규') {
      filtered.sort((a, b) => a.reviews.compareTo(b.reviews));
    }

    if (_selectedSort == '평점순') {
      filtered.sort((a, b) => b.rating.compareTo(a.rating));
    } else if (_selectedSort == '리뷰순') {
      filtered.sort((a, b) => b.reviews.compareTo(a.reviews));
    }

    return filtered;
  }

  void _showConfirmationDialog(LocalGuide guide) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text('가이드 선택', style: MatchingStyles.dialogTitleStyle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(guide.profileUrl),
                radius: 30,
                onBackgroundImageError: (e, s) {
                  debugPrint('이미지 로딩 실패: $e');
                },
              ),
              SizedBox(height: 16),
              Text(
                '${guide.nickname}님과 함께',
                style: MatchingStyles.dialogContentStyle,
              ),
              Text(
                '맛집 탐방을 떠나시겠습니까?',
                style: MatchingStyles.dialogContentBoldStyle,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('취소', style: TextStyle(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _navigateToMatchingResist(guide);
              },
              style: MatchingStyles.dialogButtonStyle,
              child: Text('확인', style: MatchingStyles.dialogButtonTextStyle),
            ),
          ],
        );
      },
    );
  }

  void _navigateToMatchingResist(LocalGuide guide) {
    try {
      debugPrint('가이드 정보 전달: id=${guide.id}, memberId=${guide.memberId}');

      final guideInfo = {
        'id': guide.id, // 서버에서 기대하는 실제 가이드 ID
        'memberId': guide.memberId, // 멤버 ID
        'name': guide.nickname,
        'profileUrl': guide.profileUrl,
        'regionId': widget.selectedRegion.regionId,
        'tagIds': widget.selectedTags.map((tag) => tag.tagId).toList(),
      };

      debugPrint('전달할 가이드 정보: $guideInfo');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MatchingResistScreen(guide: guideInfo),
        ),
      );
    } catch (e) {
      debugPrint('매칭 화면 이동 중 오류: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('매칭 신청 화면으로 이동하는데 실패했습니다.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '가이드 선택'),
      body: Column(
        children: [
          MatchingStyles.buildProgressIndicator(0.9),
          _buildHeader(),
          _buildFilterSection(),
          _buildGuideList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: MatchingStyles.defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('나를 위한 가이드님을 선택해주세요.', style: MatchingStyles.titleStyle),
          SizedBox(height: 8),
          Text('선택한 지역의 맛집 전문 가이드님들이에요!', style: MatchingStyles.subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Wrap(
            spacing: 8,
            children:
                ['전체', '인기', '신규'].map((filter) {
                  return FilterChip(
                    selected: _selectedFilter == filter,
                    label: Text(filter),
                    onSelected: (bool selected) {
                      setState(
                        () => _selectedFilter = selected ? filter : '전체',
                      );
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withOpacity(0.1),
                    labelStyle: TextStyle(
                      color:
                          _selectedFilter == filter
                              ? AppColors.primary
                              : AppColors.darkGray,
                    ),
                    shape: StadiumBorder(
                      side: BorderSide(
                        color:
                            _selectedFilter == filter
                                ? AppColors.primary
                                : AppColors.lightGray,
                      ),
                    ),
                  );
                }).toList(),
          ),
          Spacer(),
          DropdownButton<String>(
            value: _selectedSort,
            hint: Text('정렬'),
            items:
                ['평점순', '리뷰순'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() => _selectedSort = newValue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuideList() {
    return Expanded(
      child:
          _isLoading
              ? const SkeletonLoading()
              : _error.isNotEmpty
              ? _buildErrorView()
              : _guides.isEmpty
              ? _buildEmptyView()
              : ListView.builder(
                itemCount: _filteredGuides.length,
                itemBuilder: (context, index) {
                  return GuideCard(
                    guide: _filteredGuides[index],
                    onTap:
                        () => _showConfirmationDialog(_filteredGuides[index]),
                  );
                },
              ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(_error),
          ElevatedButton(onPressed: _loadGuides, child: Text('새로고침')),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('아직 등록된 가이드가 없어요.'),
          SizedBox(height: 8),
          Text('나중에 다시 확인해주세요!'),
        ],
      ),
    );
  }
}

class GuideCard extends StatelessWidget {
  final LocalGuide guide;
  final VoidCallback onTap;

  const GuideCard({Key? key, required this.guide, required this.onTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGuideAvatar(),
                SizedBox(width: 16),
                Expanded(child: _buildGuideInfo()),
                Icon(Icons.navigate_next, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuideAvatar() {
    return CircleAvatar(
      backgroundImage: NetworkImage(guide.profileUrl),
      radius: 25,
      onBackgroundImageError: (e, s) {
        debugPrint('이미지 로딩 실패: $e');
      },
      // 이미지 로드 실패시에만 기본 아이콘 표시되도록 수정
      child:
          (guide.profileUrl.isEmpty)
              ? Icon(Icons.account_circle, size: 50, color: Colors.grey)
              : null,
    );
  }

  Widget _buildGuideInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              guide.nickname,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (guide.rating > 0) ...[
              SizedBox(width: 8),
              Icon(Icons.star, size: 16, color: Colors.amber),
              Text(
                guide.rating.toStringAsFixed(1),
                style: TextStyle(fontSize: 14, color: AppColors.darkGray),
              ),
            ],
          ],
        ),
        SizedBox(height: 8),
        Wrap(
          spacing: 4,
          children:
              guide.tags
                  .map(
                    (tag) => Text(
                      '#${tag.tagName}',
                      style: TextStyle(
                        color: AppColors.mediumGray,
                        fontSize: 14,
                      ),
                    ),
                  )
                  .toList(),
        ),
        if (guide.reviews > 0) ...[
          SizedBox(height: 4),
          Text(
            '${guide.reviews}개의 리뷰',
            style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
          ),
        ],
      ],
    );
  }
}
