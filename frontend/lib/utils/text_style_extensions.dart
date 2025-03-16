import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  // 강조 버전 - Anemone 폰트 사용
  TextStyle get emphasized => copyWith(fontFamily: 'Anemone');
  
  // 사이즈 변형
  TextStyle get large => copyWith(fontSize: 24);
  TextStyle get medium => copyWith(fontSize: 18);
  TextStyle get small => copyWith(fontSize: 14);
}