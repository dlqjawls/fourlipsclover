// lib/utils/list_extensions.dart
import 'dart:core';

// List 확장 메서드
extension SortedListExtension<T> on List<T> {
  List<T> sorted(int Function(T a, T b) compare) {
    final List<T> copy = List<T>.from(this);
    copy.sort(compare);
    return copy;
  }
}