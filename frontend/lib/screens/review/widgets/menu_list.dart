import 'package:flutter/material.dart';
import '../../../config/theme.dart';

class MenuList extends StatelessWidget {
  final List<String> menu;

  const MenuList({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: menu.take(4).map((item) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.background,
              border: Border.all(color: AppColors.mediumGray),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(item, style: TextStyle(color: AppColors.darkGray)),
          );
        }).toList(),
      ),
    );
  }
}
