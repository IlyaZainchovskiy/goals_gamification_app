import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum TaskPriority {
  low,
  medium,
  high
}

class Task {
  final String id;
  final String userId;
  final String goalId;
  final String title;
  final String description;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isCompleted;
  final TaskPriority priority;
  
  Task({
    required this.id, 
    required this.userId,
    required this.goalId,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      userId: json['userId'] as String,
      goalId: json['goalId'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      deadline: json['deadline'] != null ? (json['deadline'] as Timestamp).toDate() : null,
      isCompleted: json['isCompleted'] as bool? ?? false,
      priority: TaskPriority.values[(json['priority'] as int?) ?? 1],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'goalId': goalId,
      'title': title,
      'description': description,
      'createdAt': createdAt,
      'deadline': deadline,
      'isCompleted': isCompleted,
      'priority': priority.index,
    };
  }

  Task copyWith({
    String? id,
    String? userId,
    String? goalId,
    String? title,
    String? description,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isCompleted,
    TaskPriority? priority,
  }) {
    return Task(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      deadline: deadline ?? this.deadline,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
    );
  }

  Color get priorityColor {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red;
      case TaskPriority.medium:
        return Colors.orange;
      case TaskPriority.low:
        return Colors.green;
    }
  }
}