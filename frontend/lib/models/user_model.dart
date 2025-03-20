import 'user_journey.dart';

class UserProfile {
  final String id;
  final String nickname;
  final int cloverCount;
  final int writtenPosts;
  final int receivedLikes;
  final int writtenReviews;
  final int completedJourneys; // 추가
  final List<String> achievements;
  final int currentProgress;
  final Journey? currentJourney;

  UserProfile({
    required this.id,
    required this.nickname,
    required this.cloverCount,
    required this.writtenPosts,
    required this.receivedLikes,
    required this.writtenReviews,
    required this.completedJourneys, // 추가
    required this.achievements,
    required this.currentProgress,
    this.currentJourney,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      nickname: json['nickname'],
      cloverCount: json['cloverCount'],
      writtenPosts: json['writtenPosts'],
      receivedLikes: json['receivedLikes'],
      writtenReviews: json['writtenReviews'],
      completedJourneys: json['completedJourneys'], // 추가
      achievements: List<String>.from(json['achievements']),
      currentProgress: json['currentProgress'],
      currentJourney:
          json['currentJourney'] != null
              ? Journey.fromJson(json['currentJourney'])
              : null,
    );
  }
}
