/// Application constants for badminton player skill levels
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  /// Total number of level ticks in the range slider
  static const int totalLevelTicks = 21;

  /// Main level names displayed on the top row of labels
  static const List<String> levelNames = [
    'Beginners',
    'Int',
    'Level G',
    'Level F',
    'Level E',
    'Level D',
    'Open Player',
  ];

  /// Transition level names displayed on the bottom row of labels
  static const List<String> levelTransitions = [
    '',
    'Int-G',
    'Level G-F',
    'Level F-E',
    'Level E-D',
    'Level D-Open',
    '',
  ];

  /// Sub-level names for each position within a level
  static const List<String> subLevels = ['Weak', 'Mid', 'Strong'];

  /// Shorter level names for display in constrained spaces
  static const List<String> shortLevelNames = [
    'Beginners',
    'Int',
    'Level G',
    'Level F',
    'Level E',
    'Level D',
    'Open Player',
  ];

  /// Gets the short level name for a given tick value (for constrained displays)
  static String getShortLevelName(int value) {
    final index = (value ~/ 3).clamp(0, shortLevelNames.length - 1);
    return shortLevelNames[index];
  }

  /// Gets the level name for a given tick value
  static String getLevelName(int value) {
    final index = (value ~/ 3).clamp(0, levelNames.length - 1);
    return levelNames[index];
  }

  /// Gets the sub-level name for a given tick value
  static String getSubLevel(int value) {
    final position = value % 3;
    return subLevels[position];
  }

  /// Gets the full level label in format "Level/SubLevel"
  static String getFullLevelLabel(int value) {
    return '${getLevelName(value)}/${getSubLevel(value)}';
  }

  /// Gets a level range string for start and end values
  static String getLevelRange(int start, int end) {
    return '${getFullLevelLabel(start)} - ${getFullLevelLabel(end)}';
  }

  /// Gets a short level range string for start and end values (for constrained displays)
  static String getShortLevelRange(int start, int end) {
    String shortLabelFor(int value) {
      final levelName = getShortLevelName(value);
      final subLevel = getSubLevel(value);
      return '$levelName/$subLevel';
    }

    return '${shortLabelFor(start)} - ${shortLabelFor(end)}';
  }
}
