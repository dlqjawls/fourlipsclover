import 'package:flutter/material.dart';
import 'package:frontend/config/theme.dart';

class MatchingCreateScreen extends StatefulWidget {
  const MatchingCreateScreen({Key? key}) : super(key: key);

  @override
  State<MatchingCreateScreen> createState() => _MatchingCreateScreenState();
}

class _MatchingCreateScreenState extends State<MatchingCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? startDate;
  DateTime? endDate;
  int budget = 0;
  String cityName = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '매칭 등록',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 도시 선택
              _buildSectionTitle('도시 선택'),
              DropdownButtonFormField<String>(
                decoration: _buildInputDecoration('방문할 도시를 선택해주세요'),
                items:
                    ['서울', '부산', '제주'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                onChanged: (value) {
                  setState(() {
                    cityName = value ?? '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '도시를 선택해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // 날짜 선택
              _buildSectionTitle('여행 날짜'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: _buildInputDecoration('시작일'),
                      onTap: () => _selectDate(context, true),
                      controller: TextEditingController(
                        text:
                            startDate != null
                                ? '${startDate!.year}.${startDate!.month}.${startDate!.day}'
                                : '',
                      ),
                      validator: (value) {
                        if (startDate == null) {
                          return '시작일을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      readOnly: true,
                      decoration: _buildInputDecoration('종료일'),
                      onTap: () => _selectDate(context, false),
                      controller: TextEditingController(
                        text:
                            endDate != null
                                ? '${endDate!.year}.${endDate!.month}.${endDate!.day}'
                                : '',
                      ),
                      validator: (value) {
                        if (endDate == null) {
                          return '종료일을 선택해주세요';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 예산 입력
              _buildSectionTitle('예산'),
              TextFormField(
                decoration: _buildInputDecoration('1인당 예산을 입력해주세요'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    budget = int.tryParse(value) ?? 0;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '예산을 입력해주세요';
                  }
                  if (int.tryParse(value) == null) {
                    return '숫자만 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '매칭 등록하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primary),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025, 12),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // API 호출
      final matchData = {
        'city_name': cityName,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'budget': budget,
      };

      print(matchData); // TODO: API 연동
      Navigator.pop(context); // 성공 시 이전 화면으로
    }
  }
}
