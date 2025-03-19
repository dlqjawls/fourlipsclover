import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/user/user_authorization.dart';
import 'package:frontend/providers/auth_provider.dart';

class CloverProfileSection extends StatefulWidget {
  const CloverProfileSection({super.key});

  @override
  State<CloverProfileSection> createState() => _CloverProfileSectionState();
}

class _CloverProfileSectionState extends State<CloverProfileSection> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder:
          (context, auth, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                '나의 클로버',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.thumb_up, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '현지 마스터',
                    style: TextStyle(color: AppColors.darkGray, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.lightGray,
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 600,
                    height: 600,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '누군가',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              InkWell(
                onTap:
                    auth.isAuthorized
                        ? null
                        : () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => const UserAuthorizationScreen(),
                            ),
                          );
                          // Provider가 자동으로 상태를 관리하므로 setState 불필요
                        },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color:
                        auth.isAuthorized
                            ? Colors.transparent
                            : AppColors.verylightGray,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    auth.isAuthorized ? '현지인 인증 완료!' : '현지인 인증 하실래요?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }
}
