import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/core/utils/validators.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_event.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_input_field.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignInRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Вхід'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            context.go('/dashboard');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'З поверненням!',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Увійдіть, щоб продовжити',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    // Email Field
                    AuthInputField(
                      controller: _emailController,
                      hintText: 'Введіть вашу електронну адресу',
                      labelText: 'Електронна адреса',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => Validators.validateEmail(value),
                    ),
                    const SizedBox(height: 16),
                    // Password Field
                    AuthInputField(
                      controller: _passwordController,
                      hintText: 'Введіть ваш пароль',
                      labelText: 'Пароль',
                      obscureText: _obscurePassword,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Введіть пароль';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: _togglePasswordVisibility,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // Implement password reset functionality
                        },
                        child: const Text('Забули пароль?'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Login Button
                    AuthButton(
                      text: 'Увійти',
                      onPressed: _login,
                      isLoading: state is AuthLoading,
                    ),
                    const SizedBox(height: 16),
                    // Register Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Не маєте акаунту?'),
                        TextButton(
                          onPressed: () => context.go('/register'),
                          child: const Text('Зареєструватися'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}