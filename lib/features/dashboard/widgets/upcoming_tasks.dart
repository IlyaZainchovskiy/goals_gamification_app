import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:intl/intl.dart';

class UpcomingTasks extends StatelessWidget {
  final List<Task> tasks;
  final Function(Task) onTaskTap;

  const UpcomingTasks({
    super.key,
    required this.tasks,
    required this.onTaskTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Завдання на сьогодні',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (tasks.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('На сьогодні немає завдань'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskListItem(
                task: task,
                onTap: () => onTaskTap(task),
              );
            },
          ),
      ],
    );
  }
}

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  const TaskListItem({
    super.key,
    required this.task,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final deadlineText = task.deadline != null
        ? DateFormat('HH:mm').format(task.deadline!)
        : 'Без терміну';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 12,
          height: double.infinity,
          color: task.priorityColor,
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: task.description.isNotEmpty
            ? Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              deadlineText,
              style: TextStyle(
                color: task.deadline != null &&
                        task.deadline!.isBefore(DateTime.now()) &&
                        !task.isCompleted
                    ? Colors.red
                    : null,
              ),
            ),
            if (task.isCompleted)
              const Icon(Icons.check_circle, color: Colors.green)
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}