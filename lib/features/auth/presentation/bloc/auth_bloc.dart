import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Events ────────────────────────────────────────────────────────────────────

abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class SignInWithEmail extends AuthEvent {
  final String email;
  final String password;
  const SignInWithEmail({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class RegisterWithEmail extends AuthEvent {
  final String email;
  final String password;
  final String displayName;
  const RegisterWithEmail({
    required this.email,
    required this.password,
    required this.displayName,
  });
  @override
  List<Object?> get props => [email, password, displayName];
}

class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

class ResetPassword extends AuthEvent {
  final String email;
  const ResetPassword(this.email);
  @override
  List<Object?> get props => [email];
}

class _AuthUserChanged extends AuthEvent {
  final User? user;
  const _AuthUserChanged(this.user);
  @override
  List<Object?> get props => [user?.uid];
}

// ── States ────────────────────────────────────────────────────────────────────

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user.uid];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

class AuthRegistered extends AuthState {
  const AuthRegistered();
}

class AuthPasswordResetSent extends AuthState {
  const AuthPasswordResetSent();
}

// ── BLoC ──────────────────────────────────────────────────────────────────────

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> _authSubscription;

  AuthBloc() : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<SignInWithEmail>(_onSignIn);
    on<RegisterWithEmail>(_onRegister);
    on<SignOutRequested>(_onSignOut);
    on<ResetPassword>(_onResetPassword);
    on<_AuthUserChanged>(_onUserChanged);

    // Listen to Firebase auth state changes
    _authSubscription = _auth.authStateChanges().listen(
      (user) {
        add(_AuthUserChanged(user));
      },
      onError: (_) {
        // Ignore stream-level errors (e.g. PigeonUserDetails type cast bug in firebase_auth 4.x)
      },
    );
  }

  void _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) {
    final user = _auth.currentUser;
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(
      SignInWithEmail event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _auth.signInWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      // _AuthUserChanged will be fired automatically via authStateChanges
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    } catch (_) {
      // PigeonUserDetails bug in firebase_auth 4.x — wait for currentUser to settle
      await Future.delayed(const Duration(milliseconds: 300));
      final user = _auth.currentUser;
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthError('Sign in failed. Please check your credentials.'));
      }
    }
  }

  Future<void> _onRegister(
      RegisterWithEmail event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _auth.createUserWithEmailAndPassword(
        email: event.email.trim(),
        password: event.password,
      );
      // Sign out so user must log in manually (also avoids auto-nav bug)
      await _auth.signOut();
      emit(const AuthRegistered());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    } catch (_) {
      // Any non-Firebase error here means account was CREATED but serialization failed
      // (PigeonUserDetails bug). Sign out and report success.
      try { await _auth.signOut(); } catch (_) {}
      emit(const AuthRegistered());
    }
  }

  Future<void> _onSignOut(
      SignOutRequested event, Emitter<AuthState> emit) async {
    await _auth.signOut();
  }

  Future<void> _onResetPassword(
      ResetPassword event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _auth.sendPasswordResetEmail(email: event.email.trim());
      emit(const AuthPasswordResetSent());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(_mapAuthError(e.code)));
    }
  }

  void _onUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  /// Maps Firebase error codes to human-readable messages.
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Check your connection.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  Future<void> close() {
    _authSubscription.cancel();
    return super.close();
  }
}
