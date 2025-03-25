import 'package:flutter/material.dart';

class MatchingLocalListScreen extends StatelessWidget {
  const MatchingLocalListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('현지인 전용 매칭 화면', style: TextStyle(fontSize: 24))),
    );
  }
}
