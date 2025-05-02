import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/login_screen.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/register_screen.dart';
import 'package:goals_gamification_app/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:goals_gamification_app/features/goals/presentation/screens/completed_goals_screen.dart';
import 'package:goals_gamification_app/features/goals/presentation/screens/goals_screen.dart';
import 'package:goals_gamification_app/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:goals_gamification_app/features/profile/presentation/screens/profile_screen.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (BuildContext context, GoRouterState state) => 
            const WelcomeScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (BuildContext context, GoRouterState state) => 
            const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (BuildContext context, GoRouterState state) => 
            const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (BuildContext context, GoRouterState state) => 
            const DashboardScreen(),
      ),
      GoRoute(
        path: '/goals',
        builder: (BuildContext context, GoRouterState state) => 
            const GoalsScreen(),
      ),
      GoRoute(
        path: '/tasks',
        builder: (BuildContext context, GoRouterState state) => 
            const TasksScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (BuildContext context, GoRouterState state) => 
            const ProfileScreen(),
      ),
      GoRoute(
        path: '/completed-goals',
        builder: (BuildContext context, GoRouterState state) => 
            const CompletedGoalsScreen(),
      ),
    ],
  );
}