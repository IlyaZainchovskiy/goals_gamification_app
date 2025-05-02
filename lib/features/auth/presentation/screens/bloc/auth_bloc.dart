import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:goals_gamification_app/core/services/firebase_auth_service.dart';
import 'package:goals_gamification_app/data/repositories/user_repository.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_event.dart';
import 'package:goals_gamification_app/features/auth/presentation/screens/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuthService _authService;
  final UserRepository _userRepository;

  AuthBloc({
    required FirebaseAuthService authService,
    required UserRepository userRepository,
  })  : _authService = authService,
        _userRepository = userRepository,
        super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<SignUpRequested>(_onSignUpRequested);
    on<SignInRequested>(_onSignInRequested);
    on<SignOutRequested>(_onSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _userRepository.getUser(currentUser.uid);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    SignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.registerWithEmailAndPassword(
        event.email,
        event.password,
        event.username,
      );
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _userRepository.getUser(currentUser.uid);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInRequested(
    SignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signInWithEmailAndPassword(
        event.email,
        event.password,
      );
      
      final currentUser = _authService.currentUser;
      if (currentUser != null) {
        final user = await _userRepository.getUser(currentUser.uid);
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOutRequested(
    SignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await _authService.signOut();
      emit(Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}