import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class InfoTile extends StatelessWidget {
  final String label;
  final String info;

  const InfoTile({super.key, required this.label, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(info, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
