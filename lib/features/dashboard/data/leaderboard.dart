import 'package:read_unlock_app/features/auth/models/user_model.dart';

import '../models/user.dart';

List<User> leaderboard = [
  User(name: 'Ali', score: 10),
  User(name: 'Sara', score: 20),
  User(name: 'John', score: 5),
];

const String currentUserName = 'You';

String _normalizeName(String name) => name.trim();

/// Upsert the current user entry (prevents duplicates) and keep ordering stable.
///
/// - Removes all existing entries matching the current user name (after trimming)
/// - Adds the updated entry
/// - Sorts by score DESC, and keeps original order for ties (stable)
void upsertCurrentUserScore(int score) {
  final normalizedCurrent = _normalizeName(currentUserName);

  final before = List<User>.from(leaderboard);
  leaderboard.removeWhere((u) => _normalizeName(u.name) == normalizedCurrent);
  leaderboard.add(User(name: currentUserName, score: score));

  _stableSortLeaderboard(beforeOrder: before);
}

void _stableSortLeaderboard({required List<User> beforeOrder}) {
  final indexByIdentity = <User, int>{
    for (var i = 0; i < beforeOrder.length; i++) beforeOrder[i]: i,
  };

  // Since we rebuild the list (removing/adding "You"), identity-based indices
  // won't exist for new objects. Fall back to end-of-list ordering.
  int tieBreaker(User u) => indexByIdentity[u] ?? beforeOrder.length;

  leaderboard.sort((a, b) {
    final byScore = b.score.compareTo(a.score);
    if (byScore != 0) return byScore;
    return tieBreaker(a).compareTo(tieBreaker(b));
  });
}
