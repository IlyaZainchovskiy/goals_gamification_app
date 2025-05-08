import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:goals_gamification_app/core/utils/validators.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_bloc.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_event.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_button.dart';
import 'package:goals_gamification_app/features/auth/presentation/widgets/auth_input_field.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            SignUpRequested(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
              username: _usernameController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Реєстрація'),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
             ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Реєстрація успішна!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(microseconds: 300), () {
              context.go('/dashboard');
            });
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
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Створити новий акаунт',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Заповніть поля нижче, щоб зареєструватися',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 32),
                      // Username Field
                      AuthInputField(
                        controller: _usernameController,
                        hintText: 'Введіть ваше ім\'я користувача',
                        labelText: 'Ім\'я користувача',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Введіть ім\'я користувача';
                          }
                          if (value.length < 3) {
                            return 'Ім\'я користувача має бути не менше 3 символів';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
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
                        validator: (value) => Validators.validatePassword(value),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: _togglePasswordVisibility,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Register Button
                      AuthButton(
                        text: 'Зареєструватися',
                        onPressed: _register,
                        isLoading: state is AuthLoading,
                      ),
                      const SizedBox(height: 16),
                      // Sign In Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Вже маєте акаунт?'),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text('Увійти'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}