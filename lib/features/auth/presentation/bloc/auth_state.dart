import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading, error, verificationRequired }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserEntity? user;
  final String? errorMessage;
  final bool isUploadingAvatar;
  final String? avatarErrorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.isUploadingAvatar = false,
    this.avatarErrorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserEntity? user,
    String? errorMessage,
    bool? isUploadingAvatar,
    String? avatarErrorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploadingAvatar: isUploadingAvatar ?? this.isUploadingAvatar ?? false,
      avatarErrorMessage: avatarErrorMessage, // Custom reset/set
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, isUploadingAvatar, avatarErrorMessage];
}
