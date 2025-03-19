import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../home/home_screen.dart';
import '../journal/journal.dart';
import '../ai/ai_plan.dart';
import '../user/user.dart';
import '../user/user_screen.dart';
import '../group/group_screen.dart';
import '../review/restaurant_detail.dart';



class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _screens.addAll([
      const HomeScreen(),
      RestaurantDetailScreen(restaurantId: "1"),
      const AIPlanScreen(),
      const GroupScreen(),
      const UserScreen(),
    ]);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  /// ✅ 가게 상세 페이지로 이동하는 함수
  void navigateToRestaurant(BuildContext context, String restaurantId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurantId: restaurantId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
