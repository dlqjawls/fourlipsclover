import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../config/theme.dart';
import '../../../models/plan_model.dart';
import '../../../providers/plan_provider.dart';

class PlanCreateDialog extends StatefulWidget {
  final int groupId;
  
  const PlanCreateDialog({
    Key? key,
    required this.groupId,
  }) : super(key: key);
  
  @override
  State<PlanCreateDialog> createState() => _PlanCreateDialogState();
}

class _PlanCreateDialogState extends State<PlanCreateDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 1));
  bool _isTitleEmpty = false;
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        '새 여행 계획 만들기',
        style: TextStyle(
          fontFamily: 'Anemone_air',
          color: AppColors.darkGray,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 제목 입력
            TextField(
              controller: _titleController,
              style: const TextStyle(fontFamily: 'Anemone_air'),
              decoration: InputDecoration(
                labelText: '여행 제목',
                hintText: '여행 제목을 입력하세요',
                errorText: _isTitleEmpty ? '제목을 입력해주세요' : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLength: 30,
            ),
            const SizedBox(height: 16),
            
            // 설명 입력
            TextField(
              controller: _descriptionController,
              style: const TextStyle(fontFamily: 'Anemone_air'),
              decoration: InputDecoration(
                labelText: '여행 설명',
                hintText: '여행에 대한 설명을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
              maxLength: 100,
            ),
            const SizedBox(height: 16),
            
            // 날짜 선택 - 시작일
            InkWell(
              onTap: () => _selectDate(context, true),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '시작일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_startDate),
                      style: const TextStyle(fontFamily: 'Anemone_air'),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 날짜 선택 - 종료일
            InkWell(
              onTap: () => _selectDate(context, false),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: '종료일',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('yyyy년 MM월 dd일').format(_endDate),
                      style: const TextStyle(fontFamily: 'Anemone_air'),
                    ),
                    Icon(
                      Icons.calendar_today,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            '취소',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              color: AppColors.mediumGray,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          onPressed: () {
            final title = _titleController.text.trim();
            
            if (title.isEmpty) {
              setState(() {
                _isTitleEmpty = true;
              });
            } else if (_endDate.isBefore(_startDate)) {
              // 종료일이 시작일보다 이전인 경우 알림
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('종료일은 시작일 이후로 설정해주세요'),
                ),
              );
            } else {
              // 임시 ID 생성 (실제로는 API 응답에서 받아야 함)
              final planId = DateTime.now().millisecondsSinceEpoch;
              
              // 여행 계획 생성
              final newPlan = Plan(
                planId: planId,
                groupId: widget.groupId,
                title: title,
                description: _descriptionController.text.trim(),
                startDate: _startDate,
                endDate: _endDate,
                createdAt: DateTime.now(),
                planPlaces: [],
              );
              
              // Provider에 추가
              Provider.of<PlanProvider>(context, listen: false).addPlan(newPlan);
              
              Navigator.of(context).pop();
            }
          },
          child: Text(
            '생성',
            style: TextStyle(
              fontFamily: 'Anemone_air',
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
  
  // 날짜 선택 다이얼로그 표시
  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final initialDate = isStartDate ? _startDate : _endDate;
    final firstDate = isStartDate 
        ? DateTime.now() 
        : _startDate; // 종료일은 시작일 이후로만 선택 가능
    
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppColors.darkGray,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (pickedDate != null) {
      setState(() {
        if (isStartDate) {
          _startDate = pickedDate;
          // 시작일이 종료일보다 나중이면 종료일도 함께 조정
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }
}