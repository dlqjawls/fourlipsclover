import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_provider.dart';

class UserScreen extends StatelessWidget {
  // USerScreen -> UserScreen 오타 수정
  const UserScreen({super.key}); // HomeScreen -> UserScreen 수정

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final user = provider.user;

        return Scaffold(
          appBar: AppBar(
            title: const Text('마이페이지'),
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  provider.logout();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 프로필 섹션
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          user?.kakaoAccount?.profile?.profileImageUrl ??
                              'https://via.placeholder.com/60',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.kakaoAccount?.profile?.nickname ?? "사용자",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            user?.kakaoAccount?.email ?? "이메일 없음",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 메뉴 리스트
                  _buildMenuItem(
                    icon: Icons.person_outline,
                    title: '프로필 편집',
                    onTap: () {
                      // 프로필 편집 페이지로 이동
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.settings_outlined,
                    title: '설정',
                    onTap: () {
                      // 설정 페이지로 이동
                    },
                  ),
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: '도움말',
                    onTap: () {
                      // 도움말 페이지로 이동
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
