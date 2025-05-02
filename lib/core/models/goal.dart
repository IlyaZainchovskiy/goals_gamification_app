import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum GoalPriority {
  low,
  medium,
  high
}

enum GoalCategory {
  personal,
  work,
  education,
  health,
  finance,
  other
}

class Goal {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isCompleted;
  final GoalPriority priority;
  final GoalCategory category;
  final List<String> taskIds;
  final int progress; // 0-100 percent

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
    this.priority = GoalPriority.medium,
    this.category = GoalCategory.other,
    this.taskIds = const [],
    this.progress = 0,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deadline: json['deadline'] != null ? (json['deadline'] as Timestamp).toDate() : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: GoalPriority.values[(json['priority'] as int?) ?? 1],
      category: GoalCategory.values[(json['category'] as int?) ?? 5],
      taskIds: (json['taskIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      progress: json['progress'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'deadline': deadline,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'category': category.index,
      'taskIds': taskIds,
      'progress': progress,
    };
  }

  Goal copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isCompleted,
    GoalPriority? priority,
    GoalCategory? category,
    List<String>? taskIds,
    int? progress,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      taskIds: taskIds ?? this.taskIds,
      progress: progress ?? this.progress,
    );
  }

  // Helper method to get color based on priority
  Color get priorityColor {
    switch (priority) {
      case GoalPriority.high:
        return Colors.red;
      case GoalPriority.medium:
        return Colors.orange;
      case GoalPriority.low:
        return Colors.green;
    }
  }

  // Helper method to get icon based on category
  IconData get categoryIcon {
    switch (category) {
      case GoalCategory.personal:
        return Icons.person;
      case GoalCategory.work:
        return Icons.work;
      case GoalCategory.education:
        return Icons.school;
      case GoalCategory.health:
        return Icons.favorite;
      case GoalCategory.finance:
        return Icons.attach_money;
      case GoalCategory.other:
        return Icons.category;
    }
  }
}