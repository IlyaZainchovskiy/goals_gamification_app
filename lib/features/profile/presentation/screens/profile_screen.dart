import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/core/models/achievement.dart';
import 'package:goals_gamification_app/data/repositories/achievement_repository.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_event.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Achievement> _userAchievements = [];
  List<Achievement> _allAchievements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final achievementRepo = context.read<AchievementRepository>();
      
      try {
        final userAchievements = await achievementRepo.getAchievementsByUser(authState.user.id);
        final allAchievements = await achievementRepo.getAllAchievements();
        
        setState(() {
          _userAchievements = userAchievements;
          _allAchievements = allAchievements;
          _isLoading = false;
        });
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Помилка завантаження досягнень: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мій профіль'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/');
          }
        },
        builder: (context, state) {
          if (state is Authenticated) {
            return RefreshIndicator(
              onRefresh: _loadAchievements,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User profile card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              child: Text(
                                state.user.username.substring(0, 1).toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.user.username,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              state.user.email,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      'Рівень',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          state.user.level.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    Text(
                                      'Досягнення',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.secondary,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          _userAchievements.length.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'XP: ${state.user.xp}',
                                      style: Theme.of(context).textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${state.user.xp}/100',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearPercentIndicator(
                                  percent: (state.user.xp % 100) / 100,
                                  lineHeight: 10,
                                  progressColor: Theme.of(context).colorScheme.primary,
                                  backgroundColor: Theme.of(context).colorScheme.surface,
                                  barRadius: const Radius.circular(5),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Мої досягнення',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_allAchievements.isEmpty)
                      const Center(child: Text('Досягнення не знайдено'))
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _allAchievements.length,
                        itemBuilder: (context, index) {
                          final achievement = _allAchievements[index];
                          final isUnlocked = _userAchievements
                              .any((a) => a.id == achievement.id);
                              
                          return AchievementCard(
                            achievement: achievement,
                            isUnlocked: isUnlocked,
                          );
                        },
                      ),
                  ],
                ),
              ),
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final bool isUnlocked;

  const AchievementCard({
    super.key,
    required this.achievement,
    required this.isUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: isUnlocked 
          ? Theme.of(context).colorScheme.surface 
          : Colors.grey.shade200,
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isUnlocked 
                ? Theme.of(context).colorScheme.primary 
                : Colors.grey,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getAchievementIcon(achievement.iconName),
            color: Colors.white,
          ),
        ),
        title: Text(
          achievement.title,
          style: TextStyle(
            fontWeight: isUnlocked ? FontWeight.bold : null,
            color: isUnlocked ? null : Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          achievement.description,
          style: TextStyle(
            color: isUnlocked ? null : Colors.grey.shade600,
          ),
        ),
        trailing: isUnlocked
            ? Chip(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                label: Text(
                  '+${achievement.xpReward} XP',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Text(
                'Не відкрито',
                style: TextStyle(color: Colors.grey.shade600),
              ),
      ),
    );
  }

  IconData _getAchievementIcon(String iconName) {
    switch (iconName) {
      case 'trophy':
        return Icons.emoji_events;
      case 'star':
        return Icons.star;
      case 'run':
        return Icons.directions_run;
      case 'lightbulb':
        return Icons.lightbulb;
      default:
        return Icons.emoji_events;
    }
  }
}