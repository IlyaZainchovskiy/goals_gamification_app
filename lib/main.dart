import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/core/services/firebase_auth_service.dart';
import 'package:goals_gamification_app/data/datasources/firebase_datasource.dart';
import 'package:goals_gamification_app/data/repositories/achievement_repository.dart';
import 'package:goals_gamification_app/data/repositories/goal_repository.dart';
import 'package:goals_gamification_app/data/repositories/task_repository.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_event.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:goals_gamification_app/features/goals/presentation/bloc/goals_bloc.dart';
import 'package:goals_gamification_app/features/tasks/presentation/bloc/tasks_bloc.dart';
import 'package:goals_gamification_app/navigation/app_router.dart';
import 'package:goals_gamification_app/theme/app_theme.dart';

import 'data/repositories/achievement_repository_impl.dart';
import 'data/repositories/goal_repository_impl.dart';
import 'data/repositories/task_repository_impl.dart';
import 'data/repositories/user_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // Datasource
        RepositoryProvider<FirebaseDatasource>(
          create: (context) => FirebaseDatasource(),
        ),
        
        // Repositories
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepositoryImpl(
            context.read<FirebaseDatasource>(),
          ),
        ),
        RepositoryProvider<GoalRepository>(
          create: (context) => GoalRepositoryImpl(
            context.read<FirebaseDatasource>(),
             context.read<UserRepository>(),
          ),
        ),
        RepositoryProvider<TaskRepository>(
          create: (context) => TaskRepositoryImpl(
            context.read<FirebaseDatasource>(),
          ),
        ),
        RepositoryProvider<AchievementRepository>(
          create: (context) => AchievementRepositoryImpl(
            context.read<FirebaseDatasource>(),
            context.read<UserRepository>(),
          ),
        ),
        
        // Services
        RepositoryProvider<FirebaseAuthService>(
          create: (context) => FirebaseAuthService(
            context.read<UserRepository>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<FirebaseAuthService>(),
              userRepository: context.read<UserRepository>(),
            )..add(AuthCheckRequested()),
          ),
          BlocProvider<DashboardBloc>(
            create: (context) => DashboardBloc(
              userRepository: context.read<UserRepository>(),
              goalRepository: context.read<GoalRepository>(),
              taskRepository: context.read<TaskRepository>(),
            ),
          ),
          BlocProvider<GoalsBloc>(
            create: (context) => GoalsBloc(
              goalRepository: context.read<GoalRepository>(),
            ),
          ),
          BlocProvider<TasksBloc>(
            create: (context) => TasksBloc(
              context.read<AchievementRepository>(), 
              taskRepository: context.read<TaskRepository>(),
              goalRepository: context.read<GoalRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            final appRouter = AppRouter();
            
            return MaterialApp.router(
              title: 'Цілі і Завдання',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              routerConfig: appRouter.router,
            );
          },
        ),
      ),
    );
  }
}