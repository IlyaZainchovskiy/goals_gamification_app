import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:goals_gamification_app/core/models/user.dart';
import 'package:goals_gamification_app/core/models/goal.dart';
import 'package:goals_gamification_app/core/models/task.dart';
// import 'package:goals_gamification_app/core/models/achievement.dart';

class FirebaseDatasource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // User methods
  Future<UserModel?> getUser(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists) {
        return UserModel.fromJson(docSnapshot.data()!..['id'] = userId);
      }
      return null;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      print('Error creating user: $e');
      throw e;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      print('Error updating user: $e');
      throw e;
    }
  }
  

  // Goal methods
  Future<List<Goal>> getGoalsByUser(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('goals')
          .where('userId', isEqualTo: userId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Goal.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      print('Error getting goals: $e');
      return [];
    }
  }

  Future<Goal?> getGoal(String goalId) async {
    try {
      final docSnapshot = await _firestore.collection('goals').doc(goalId).get();
      if (docSnapshot.exists) {
        return Goal.fromJson(docSnapshot.data()!..['id'] = goalId);
      }
      return null;
    } catch (e) {
      print('Error getting goal: $e');
      return null;
    }
  }

  Future<String> createGoal(Goal goal) async {
    try {
      final docRef = await _firestore.collection('goals').add(goal.toJson());
      return docRef.id;
    } catch (e) {
      print('Error creating goal: $e');
      throw e;
    }
  }

  Future<void> updateGoal(Goal goal) async {
    try {
      await _firestore.collection('goals').doc(goal.id).update(goal.toJson());
    } catch (e) {
      print('Error updating goal: $e');
      throw e;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    try {
      await _firestore.collection('goals').doc(goalId).delete();
    } catch (e) {
      print('Error deleting goal: $e');
      throw e;
    }
  }

  // Task methods
  Future<List<Task>> getTasksByGoal(String goalId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('goalId', isEqualTo: goalId)
          .get();
      
      return querySnapshot.docs
          .map((doc) => Task.fromJson(doc.data()..['id'] = doc.id))
          .toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }

  Future<Task?> getTask(String taskId) async {
    try {
      final docSnapshot = await _firestore.collection('tasks').doc(taskId).get();
      if (docSnapshot.exists) {
        return Task.fromJson(docSnapshot.data()!..['id'] = taskId);
      }
      return null;
    } catch (e) {
      print('Error getting task: $e');
      return null;
    }
  }

  Future<String> createTask(Task task) async {
  try {
    print('Спроба створити завдання в Firebase: ${task.title}');
    
    if (task.id.isEmpty) {
      final docRef = await _firestore.collection('tasks').add(task.toJson());
      print('Завдання  створено з ID: ${docRef.id}');
      return docRef.id;
    } else {
      await _firestore.collection('tasks').doc(task.id).set(task.toJson());
      print('Завдання  створено з наданим ID: ${task.id}');
      return task.id;
    }
  } catch (e) {
    print('Помилка при створенні завдання в Firebase: $e');
    throw e;
  }
}

  Future<void> updateTask(Task task) async {
    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toJson());
    } catch (e) {
      print('Error updating task: $e');
      throw e;
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      throw e;
    }
  }
  

  // User achievements
  Future<List<String>> getUserAchievements(String userId) async {
    try {
      final docSnapshot = await _firestore.collection('users').doc(userId).get();
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('achievements')) {
        return List<String>.from(docSnapshot.data()!['achievements']);
      }
      return [];
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

Future<void> addAchievementToUser(String userId, String achievementId) async {
  try {
    print("Firebase: додаємо досягнення $achievementId користувачу $userId");
    
    // Спочатку отримуємо поточний список досягнень
    final docSnapshot = await _firestore.collection('users').doc(userId).get();
    
    if (docSnapshot.exists) {
      List<String> currentAchievements = [];
      
      if (docSnapshot.data()!.containsKey('achievements')) {
        currentAchievements = List<String>.from(docSnapshot.data()!['achievements']);
      }
      
      // Перевірка, чи вже є це досягнення
      if (currentAchievements.contains(achievementId)) {
        print("Firebase: досягнення вже існує у списку");
        return;
      }
      
      // Додаємо нове досягнення
      currentAchievements.add(achievementId);
      
      // Оновлюємо документ з новим списком замість використання arrayUnion
      await _firestore.collection('users').doc(userId).update({
        'achievements': currentAchievements
      });
      
      print("Firebase: досягнення успішно додано");
    } else {
      print("Firebase: документ користувача не знайдено");
      throw Exception("Користувача не знайдено");
    }
  } catch (e) {
    print("Firebase: помилка при додаванні досягнення: $e");
    rethrow;
  }
}
}