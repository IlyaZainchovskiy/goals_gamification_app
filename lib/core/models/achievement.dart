enum AchievementType {
  completeTasks,
  createGoals,
  dailyStreak,
  specialEvent
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final String iconName;
  final AchievementType type;
  final int threshold; 
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.iconName,
    required this.type,
    required this.threshold,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      xpReward: json['xpReward'] as int,
      iconName: json['iconName'] as String,
      type: AchievementType.values[(json['type'] as int?) ?? 0],
      threshold: json['threshold'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'xpReward': xpReward,
      'iconName': iconName,
      'type': type.index,
      'threshold': threshold,
    };
  }

  static List<Achievement> predefinedAchievements = [
    Achievement(
      id: 'triple-daily',
      title: 'Трійка ударників',
      description: 'Виконати 3 завдання за один день',
      xpReward: 15,
      iconName: 'trophy',
      type: AchievementType.dailyStreak,
      threshold: 3,
    ),
    Achievement(
      id: 'first-success',
      title: 'Старт успіху',
      description: 'Виконати перше завдання',
      xpReward: 5,
      iconName: 'star',
      type: AchievementType.completeTasks,
      threshold: 1,
    ),
    Achievement(
      id: 'marathoner',
      title: 'Марафонець',
      description: 'Завершити 50 завдань',
      xpReward: 50,
      iconName: 'run',
      type: AchievementType.completeTasks,
      threshold: 50,
    ),
    Achievement(
      id: 'dreamer',
      title: 'Мрійник',
      description: 'Створити 10 цілей',
      xpReward: 20,
      iconName: 'lightbulb',
      type: AchievementType.createGoals,
      threshold: 10,
    ),
  ];
}