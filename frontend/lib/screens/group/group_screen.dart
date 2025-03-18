import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/group_provider.dart';
import 'widgets/empty_group_view.dart';
import 'widgets/group_list_view.dart';
import 'widgets/group_create_dialog.dart';

class GroupScreen extends StatelessWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final groups = groupProvider.groups;

    return Scaffold(
      body: Stack(
        children: [
          // 우측 하단에 배경 이미지
          Positioned(
            bottom: -250,
            right: -280,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset(
                'assets/images/logo.png',
                width: 800,
                height: 800,
                fit: BoxFit.cover,
              ),
            ),
          ),

          // 콘텐츠
          groups.isEmpty
              ? EmptyGroupView(
                onCreateGroup: () => _showGroupCreateDialog(context),
              )
              : GroupListView(
                groups: groups,
                groupProvider: groupProvider,
                onCreateGroup: () => _showGroupCreateDialog(context),
              ),
        ],
      ),
    );
  }

  // 그룹 생성 다이얼로그
  void _showGroupCreateDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GroupCreateDialog();
      },
    );
  }
}
