import 'package:flutter/material.dart';
import 'package:frontend/models/matching/matching_region.dart';
import 'package:frontend/services/matching/region_service.dart';
import 'package:frontend/screens/matching/matchingcreate/matching_select_local.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchingcreate/styles/matching_styles.dart';
import 'package:frontend/models/matching/matching_tag_model.dart';
// import 'package:frontend/widgets/clover_loading_spinner.dart';
import 'package:frontend/widgets/loading_overlay.dart';

class MatchingLocationScreen extends StatefulWidget {
  final List<Tag> selectedTags;

  const MatchingLocationScreen({Key? key, required this.selectedTags})
    : super(key: key);

  @override
  _MatchingLocationScreenState createState() => _MatchingLocationScreenState();
}

class _MatchingLocationScreenState extends State<MatchingLocationScreen> {
  final RegionService _regionService = RegionService();
  List<Region> regions = [];
  Region? selectedRegion;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRegions();
  }

  Future<void> _loadRegions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final fetchedRegions = await _regionService.getRegions();
      setState(() {
        regions = fetchedRegions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRegionSelected(Region region) {
    setState(() {
      selectedRegion = region;
    });
  }

  void _onNextPressed() {
    if (selectedRegion != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => MatchingSelectLocalScreen(
                selectedRegion: selectedRegion!,
                selectedTags: widget.selectedTags,
              ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MatchingStyles.buildAppBar(context, '여행 지역 선택'),
      body: LoadingOverlay(
        isLoading: _isLoading,
        overlayColor: Colors.white.withOpacity(0.7),
        minDisplayTime: const Duration(milliseconds: 1200),
        child: Column(
          children: [
            MatchingStyles.buildProgressIndicator(0.6),
            _buildHeader(),
            _buildContent(),
            _buildNextButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: MatchingStyles.defaultPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('어디로 여행을 떠나시나요?', style: MatchingStyles.titleStyle),
          SizedBox(height: 8),
          Text('맛집 탐방을 위한 지역을 선택해주세요', style: MatchingStyles.subtitleStyle),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_error != null) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              SizedBox(height: 16),
              ElevatedButton(onPressed: _loadRegions, child: Text('다시 시도')),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: MatchingStyles.defaultPadding,
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: regions.length,
          itemBuilder: _buildRegionItem,
        ),
      ),
    );
  }

  Widget _buildRegionItem(BuildContext context, int index) {
    final region = regions[index];
    final isSelected = selectedRegion?.regionId == region.regionId;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _onRegionSelected(region),
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.lightGray,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_on,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 24,
              ),
              SizedBox(height: 4),
              Text(
                region.name,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.darkGray,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return Padding(
      padding: MatchingStyles.defaultPadding,
      child: ElevatedButton(
        onPressed: selectedRegion != null ? _onNextPressed : null,
        style: MatchingStyles.buttonStyle,
        child: Text('다음', style: MatchingStyles.buttonTextStyle),
      ),
    );
  }
}
