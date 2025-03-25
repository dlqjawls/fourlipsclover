import 'package:flutter/material.dart';

class MatchingResistScreen extends StatelessWidget {
  const MatchingResistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('사용자 신청서 작성 페이지', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
