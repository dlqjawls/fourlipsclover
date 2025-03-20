/// 좋아요/싫어요 상태를 나타내는 열거형
enum LikeStatus {
  LIKE('LIKE'),
  DISLIKE('DISLIKE');

  final String status;
  
  const LikeStatus(this.status);
  
  /// 문자열 표현으로부터 LikeStatus 열거형 값을 반환
  static LikeStatus fromString(String value) {
    return LikeStatus.values.firstWhere(
      (status) => status.status == value,
      orElse: () => LikeStatus.LIKE,
    );
  }
  
  /// 열거형 값의 이름 반환 (백엔드 통신용)
  String get name => toString().split('.').last;
}