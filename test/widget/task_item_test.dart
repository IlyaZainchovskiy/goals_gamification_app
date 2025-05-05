import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goals_gamification_app/core/models/task.dart';
import 'package:goals_gamification_app/features/tasks/widgets/task_item.dart';

void main() {
  testWidgets('TaskItem відображає інформацію про завдання', (WidgetTester tester) async {
    final task = Task(
      id: '1',
      userId: 'user1',
      goalId: 'goal1',
      title: 'Тестове завдання',
      description: 'Опис завдання',
      createdAt: DateTime.now(),
      priority: TaskPriority.high,
    );
    
    bool onTapCalled = false;
    bool onCheckboxChangedCalled = false;
    bool onDeleteCalled = false;
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskItem(
            task: task,
            onTap: () {
              onTapCalled = true;
            },
            onCheckboxChanged: (value) {
              onCheckboxChangedCalled = true;
            },
            onDelete: () {
              onDeleteCalled = true;
            },
          ),
        ),
      ),
    );
    
    expect(find.text('Тестове завдання'), findsOneWidget);
    expect(find.text('Опис завдання'), findsOneWidget);
    
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(onCheckboxChangedCalled, isTrue);
    
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pump();
    expect(onDeleteCalled, isTrue);
    
    await tester.tap(find.byType(InkWell));
    await tester.pump();
    expect(onTapCalled, isTrue);
  });
  
  testWidgets('TaskItem відображає завершене завдання коректно', (WidgetTester tester) async {
    final task = Task(
      id: '1',
      userId: 'user1',
      goalId: 'goal1',
      title: 'Тестове завдання',
      createdAt: DateTime.now(),
      isCompleted: true,
    );
    
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: TaskItem(
            task: task,
            onTap: () {},
            onCheckboxChanged: (value) {},
          ),
        ),
      ),
    );
    
    final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
    expect(checkbox.value, isTrue);
    
    final titleText = tester.widget<Text>(find.text('Тестове завдання'));
    expect(titleText.style?.decoration, equals(TextDecoration.lineThrough));
  });
}