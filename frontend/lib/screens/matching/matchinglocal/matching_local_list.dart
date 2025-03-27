import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';
import 'matching_local_resist.dart';

class MatchingLocalListScreen extends StatefulWidget {
  const MatchingLocalListScreen({Key? key}) : super(key: key);

  @override
  State<MatchingLocalListScreen> createState() =>
      _MatchingLocalListScreenState();
}

class _MatchingLocalListScreenState extends State<MatchingLocalListScreen> {
  final List<Map<String, dynamic>> acceptedRequests = [
    {
      'name': '대충 김아무개',
      'startDate': '25-04-15',
      'endDate': '25-04-17',
      'tip': '2,000',
      'hasProposal': false, // 기획서 작성 여부
    },
  ];

  final List<Map<String, dynamic>> pendingRequests = [
    {
      'name': '대충 김아무개',
      'startDate': '25-04-15',
      'endDate': '25-04-17',
      'tip': '2,000',
    },
    {
      'name': '대충 김아무개',
      'startDate': '25-04-15',
      'endDate': '25-04-17',
      'tip': '2,000',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text('가이드 기획서'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 접수 목록 섹션
          _buildSectionHeader('접수 목록', acceptedRequests.length),
          Expanded(
            flex: 1,
            child:
                acceptedRequests.isEmpty
                    ? _buildEmptyState('접수된 요청이 없습니다')
                    : _buildAcceptedList(),
          ),

          // 신청 목록 섹션
          _buildSectionHeader('나에게 온 신청목록', pendingRequests.length),
          Expanded(
            flex: 2,
            child:
                pendingRequests.isEmpty
                    ? _buildEmptyState('새로운 신청이 없습니다')
                    : ListView.builder(
                      itemCount: pendingRequests.length,
                      itemBuilder:
                          (context, index) =>
                              _buildPendingCard(pendingRequests[index]),
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(message, style: const TextStyle(color: AppColors.mediumGray)),
    );
  }

  Widget _buildAcceptedList() {
    return Column(
      children: [
        Expanded(
          child: ShaderMask(
            shaderCallback: (Rect rect) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.purple,
                  Colors.transparent,
                  Colors.transparent,
                  Colors.purple,
                ],
                stops: [0.0, 0.05, 0.95, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstOut,
            child: ListView.builder(
              padding: const EdgeInsets.only(bottom: 8),
              itemCount: acceptedRequests.length,
              itemBuilder:
                  (context, index) =>
                      _buildAcceptedCard(acceptedRequests[index]),
            ),
          ),
        ),
        if (acceptedRequests.length > 1)
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.mediumGray,
                  size: 20,
                ),
                Text(
                  '스크롤하여 더 보기',
                  style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAcceptedCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request['name'],
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '시작 일시: ${request['startDate']}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 4),
            Text(
              '종료 일시: ${request['endDate']}',
              style: const TextStyle(fontSize: 14, color: AppColors.mediumGray),
            ),
            const SizedBox(height: 8),
            Text(
              '팁: ${request['tip']}원',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            if (request['hasProposal'] == true)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => MatchingLocalResistScreen(
                                  request: request,
                                  isEditing: true,
                                ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '기획서 수정',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: 대화방으로 이동
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        '대화방',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => MatchingLocalResistScreen(
                              request: request,
                              isEditing: false,
                            ),
                      ),
                    ).then((submitted) {
                      if (submitted == true) {
                        setState(() {
                          request['hasProposal'] = true;
                        });
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '기획서 작성',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> request) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    request['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '시작 일시: ${request['startDate']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '종료 일시: ${request['endDate']}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.mediumGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '팁: ${request['tip']}원',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                _buildActionButton(
                  onPressed: () {
                    setState(() {
                      pendingRequests.remove(request);
                    });
                  },
                  icon: Icons.close,
                  color: AppColors.red,
                ),
                const SizedBox(height: 8),
                _buildActionButton(
                  onPressed: () {
                    setState(() {
                      request['hasProposal'] = false;
                      acceptedRequests.add(request);
                      pendingRequests.remove(request);
                    });
                  },
                  icon: Icons.check,
                  color: AppColors.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required Color color,
  }) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}
