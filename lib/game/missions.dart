/// The kinds of always-on, auto-advancing missions.
enum MissionType { floor, perfect, games }

/// A read-only snapshot of one mission for display (label, progress, reward).
class MissionView {
  const MissionView({
    required this.type,
    required this.label,
    required this.progress,
    required this.target,
    required this.reward,
  });

  final MissionType type;
  final String label;
  final int progress;
  final int target;
  final int reward;

  bool get done => progress >= target;
  double get fraction => target == 0 ? 0 : (progress / target).clamp(0.0, 1.0);
}

/// Reward + step config per mission type. Targets climb by [step] on completion.
class MissionConfig {
  static const floorReward = 20;
  static const floorStep = 10;
  static const perfectReward = 15;
  static const perfectStep = 3;
  static const gamesReward = 10;
  static const gamesStep = 5;
}
