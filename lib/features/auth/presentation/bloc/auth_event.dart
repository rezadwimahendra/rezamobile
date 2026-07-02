import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;

  const LoginSubmitted(this.email, this.password);

  @override
  List<Object?> get props => [email, password];
}

class RegisterSubmitted extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String role;
  final DateTime? birthDate; // Baru

  const RegisterSubmitted({
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.birthDate,
  });

  @override
  List<Object?> get props => [name, email, password, role, birthDate];
}

class LogoutRequested extends AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthUserChanged extends AuthEvent {
  final UserEntity user;
  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class UpdateAvatarRequested extends AuthEvent {
  final String imagePath;
  const UpdateAvatarRequested(this.imagePath);

  @override
  List<Object?> get props => [imagePath];
}
