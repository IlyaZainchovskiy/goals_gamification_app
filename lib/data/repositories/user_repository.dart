import 'package:flutter/src/widgets/framework.dart';
import 'package:goals_gamification_app/core/models/user.dart';

abstract class UserRepository {
  Future<UserModel?> getUser(String userId);
  Future<void> createUser(UserModel user);
  Future<void> updateUser(UserModel user);
  Future<void> addXp(String userId, int xp, {BuildContext? context});
  Future<void> addAchievement(String userId, String achievementId);
}