import 'package:goals_gamification_app/core/models/user.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseDatasource _datasource;

  UserRepositoryImpl(this._datasource);

  @override
  Future<UserModel?> getUser(String userId) async {
    return await _datasource.getUser(userId);
  }

  @override
  Future<void> createUser(UserModel user) async {
    await _datasource.createUser(user);
  }

  @override
  Future<void> updateUser(UserModel user) async {
    await _datasource.updateUser(user);
  }

  @override
  Future<void> addXp(String userId, int xp) async {
    final user = await _datasource.getUser(userId);
    if (user != null) {
      final newXp = user.xp + xp;
      // Розрахунок нового рівня на основі XP
      final newLevel = calculateLevel(newXp);
      
      await _datasource.updateUser(
        user.copyWith(xp: newXp, level: newLevel),
      );
    }
  }

  @override
  Future<void> addAchievement(String userId, String achievementId) async {
    await _datasource.addAchievementToUser(userId, achievementId);
  }
  
  // алгоритм для розрахунку рівня на основі XP
  int calculateLevel(int xp) {
    return (xp / 100).floor() + 1; 
  }
}