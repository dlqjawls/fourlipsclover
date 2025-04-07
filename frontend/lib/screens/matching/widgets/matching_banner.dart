import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'package:frontend/screens/matching/matchinglocal/matching_local_list.dart';

class MatchingBanner extends StatelessWidget {
  final int confirmedCount;
  final int pendingCount;

  const MatchingBanner({
    Key? key,
    required this.confirmedCount,
    required this.pendingCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (confirmedCount == 0) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                    const MatchingLocalListScreen(),
            transitionsBuilder: (
              context,
              animation,
              secondaryAnimation,
              child,
            ) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeInOut;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(opacity: animation, child: child),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Image.asset('assets/images/clover.png', width: 60, height: 60),
            const SizedBox(width: 16, height: 0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (confirmedCount > 0)
                    Text(
                      '진행중인 매칭 ${confirmedCount}건',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const Text(
                    '확인하러 가기',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
