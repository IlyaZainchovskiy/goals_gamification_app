import 'package:flutter/material.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:intl/intl.dart';

class GoalItem extends StatelessWidget {
  final Goal goal;
  final VoidCallback onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onDelete;

  const GoalItem({
    Key? key,
    required this.goal,
    required this.onTap,
    this.onComplete,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deadlineText = goal.deadline != null
        ? DateFormat('dd.MM.yyyy').format(goal.deadline!)
        : 'Без терміну';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        goal.categoryIcon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          decoration: goal.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: goal.priorityColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (goal.isCompleted)
                        const Icon(Icons.check_circle, color: Colors.green)
                      else
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (value) {
                            if (value == 'complete' && onComplete != null) {
                              onComplete!();
                            } else if (value == 'delete' && onDelete != null) {
                              onDelete!();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'complete',
                              child: Text('Завершити'),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Text('Видалити'),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ),
              if (goal.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  goal.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    deadlineText,
                    style: TextStyle(
                      color: goal.deadline != null &&
                              goal.deadline!.isBefore(DateTime.now()) &&
                              !goal.isCompleted
                          ? Colors.red
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearPercentIndicator(
                percent: goal.progress / 100,
                lineHeight: 8,
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                barRadius: const Radius.circular(4),
                trailing: Text('${goal.progress}%'),
                padding: const EdgeInsets.only(right: 8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}