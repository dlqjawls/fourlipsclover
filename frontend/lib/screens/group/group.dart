import 'package:flutter/material.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          '그룹·매칭 화면',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
