import 'package:flutter/material.dart';

class AIPlanScreen extends StatelessWidget {
  const AIPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'AI 추천 화면',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
