import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon or Logo
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 32),
              // Welcome Title
              Text(
                'Цілі та Завдання',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Welcome Description
              Text(
                'Відстежуйте свої цілі, розбивайте їх на завдання і отримуйте винагороди за досягнення успіху',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Login Button
              AuthButton(
                text: 'Увійти',
                onPressed: () => context.go('/login'),
              ),
              const SizedBox(height: 16),
              // Register Button
              AuthButton(
                text: 'Зареєструватися',
                onPressed: () => context.go('/register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}