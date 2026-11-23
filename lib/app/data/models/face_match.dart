import 'person.dart';

/// Result of a successful face identification.
class FaceMatch {
  const FaceMatch({required this.person, required this.score});

  final Person person;

  /// Match score in percent.
  final int score;
}
