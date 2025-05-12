import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class DailyProgress extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final int xp;
  final int level;

  const DailyProgress({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.xp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final double progressPercent = totalTasks > 0 
        ? completedTasks / totalTasks 
        : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сьогоднішній прогрес',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircularPercentIndicator(
                radius: 45.0,
                lineWidth: 8.0,
                percent: progressPercent.clamp(0.0, 1.0),
                center: Text(
                  '${(progressPercent * 100).round()}%',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                progressColor: Theme.of(context).colorScheme.primary,
                backgroundColor: Theme.of(context).colorScheme.surface,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Завдань виконано: $completedTasks/$totalTasks',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Рівень: $level',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'XP: $xp',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}