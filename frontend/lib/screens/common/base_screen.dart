import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../home/home_screen.dart';
import '../journal/journal.dart';
import '../ai/ai_plan.dart';
import '../user/user_screen.dart';
import '../group_plan/group_screen.dart';
import '../matching/matching.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 2;
  String restaurantId = "1808376805";
  
  // 페이지 상태 저장을 위한 PageStorageBucket 추가
  final PageStorageBucket _bucket = PageStorageBucket();

  // 각 화면을 위한 Key 생성
  final List<Key> _screenKeys = [
    const PageStorageKey('groupScreen'),
    const PageStorageKey('matchingScreen'),
    const PageStorageKey('homeScreen'),
    const PageStorageKey('aiPlanScreen'),
    const PageStorageKey('userScreen'),
  ];

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    // 각 화면을 고유 키와 함께 추가
    _screens.addAll([
      GroupScreen(key: _screenKeys[0]),
      MatchingScreen(key: _screenKeys[1]),
      HomeScreen(key: _screenKeys[2]),
      AIPlanScreen(key: _screenKeys[3]),
      UserScreen(key: _screenKeys[4]),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _selectedIndex, 
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}