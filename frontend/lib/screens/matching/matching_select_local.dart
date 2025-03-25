import 'package:flutter/material.dart';

class MatchingSelectLocalScreen extends StatelessWidget {
  const MatchingSelectLocalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('원하는 현지인 선택하는 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
