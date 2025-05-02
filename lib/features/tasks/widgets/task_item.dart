import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:intl/intl.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final Function(bool) onCheckboxChanged;
  final VoidCallback? onDelete;

  const TaskItem({
    Key? key,
    required this.task,
    required this.onTap,
    required this.onCheckboxChanged,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deadlineText = task.deadline != null
        ? DateFormat('dd.MM.yyyy HH:mm').format(task.deadline!)
        : 'Без терміну';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 40,
                color: task.priorityColor,
              ),
              const SizedBox(width: 8),
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) {
                  if (value != null) {
                    onCheckboxChanged(value);
                  }
                },
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        decoration: task.isCompleted 
                            ? TextDecoration.lineThrough 
                            : null,
                      ),
                    ),
                    if (task.description.isNotEmpty)
                      Text(
                        task.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : null,
                        ),
                      ),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          deadlineText,
                          style: TextStyle(
                            fontSize: 12,
                            color: task.deadline != null &&
                                    task.deadline!.isBefore(DateTime.now()) &&
                                    !task.isCompleted
                                ? Colors.red
                                : Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: onDelete,
                ),
            ],
          ),
        ),
      ),
    );
  }
}