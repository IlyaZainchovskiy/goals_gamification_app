import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/task.dart';

abstract class TasksEvent extends Equatable {
  const TasksEvent();

  @override
  List<Object?> get props => [];
}

class LoadTasks extends TasksEvent {
  final String userId;
  final String? goalId;

  const LoadTasks(this.userId, {this.goalId});

  @override
  List<Object?> get props => [userId, goalId];
}

class AddTask extends TasksEvent {
  final Task task;

  const AddTask(this.task);

  @override
  List<Object> get props => [task];
}

class UpdateTask extends TasksEvent {
  final Task task;

  const UpdateTask(this.task);

  @override
  List<Object> get props => [task];
}

class DeleteTask extends TasksEvent {
  final String taskId;

  const DeleteTask(this.taskId);

  @override
  List<Object> get props => [taskId];
}

class CompleteTask extends TasksEvent {
  final String taskId;
  final BuildContext? context;

  const CompleteTask(this.taskId, {this.context});

  @override
  List<Object> get props => [taskId,];
}

class FilterTasksByStatus extends TasksEvent {
  final bool? isCompleted;

  const FilterTasksByStatus(this.isCompleted);

  @override
  List<Object?> get props => [isCompleted];
}