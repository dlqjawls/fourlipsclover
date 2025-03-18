import 'package:flutter/material.dart';
import '../../widgets/common_widgets.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/journal/journal.dart';
import '../../screens/ai/ai_plan.dart';
import '../../screens/group/group.dart';
import '../user/user_screen.dart';

class BaseScreen extends StatefulWidget {
  const BaseScreen({Key? key}) : super(key: key);

  @override
  _BaseScreenState createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  int _selectedIndex = 2;

  final List<Widget> _screens = [
    const HomeScreen(),
    const JournalScreen(),
    const AIPlanScreen(),
    const GroupScreen(),
    const UserScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
