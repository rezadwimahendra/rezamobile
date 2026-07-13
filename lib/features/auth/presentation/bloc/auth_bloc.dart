import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../../domain/usecases/login_usecase.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final PocketBase pb;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.pb,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
    on<UpdateAvatarRequested>(_onUpdateAvatarRequested);
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    emit(state.copyWith(user: event.user));
  }

  Future<void> _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) async {
    if (pb.authStore.isValid && pb.authStore.model != null) {
      final model = pb.authStore.model!;
      final cachedUser = UserModel.fromRecord(model);
      emit(state.copyWith(status: AuthStatus.authenticated, user: cachedUser));
      
      // Jika ini bukan superadmin, ambil record segar dari koleksi 'users'
      final isSuperAdmin = model.getStringValue('email') == 'superadmin@fitmotion.com' || model.collectionName == '_superusers';
      if (!isSuperAdmin) {
        try {
          final freshlyFetchedRecord = await pb.collection('users').getOne(model.id);
          final freshUser = UserModel.fromRecord(freshlyFetchedRecord);
          pb.authStore.save(pb.authStore.token, freshlyFetchedRecord);
          emit(state.copyWith(status: AuthStatus.authenticated, user: freshUser));
        } catch (e) {
          print('DEBUG: Auth check network refresh failed: $e');
        }
      }
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
    }
  }

  Future<void> _onLoginSubmitted(LoginSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await loginUseCase(event.email, event.password);
    result.fold(
      (failure) => emit(state.copyWith(status: AuthStatus.error, errorMessage: failure)),
      (user) => emit(state.copyWith(status: AuthStatus.authenticated, user: user)),
    );
  }

  Future<void> _onRegisterSubmitted(RegisterSubmitted event, Emitter<AuthState> emit) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await registerUseCase(
      name: event.name,
      email: event.email,
      password: event.password,
      role: event.role,
      birthDate: event.birthDate,
    );
    
    await result.fold(
      (failure) async {
        emit(state.copyWith(status: AuthStatus.error, errorMessage: failure));
      },
      (user) async {
        // Registrasi sukses! Lakukan auto-login menggunakan kredensial pendaftaran
        final loginResult = await loginUseCase(event.email, event.password);
        loginResult.fold(
          (loginFailure) {
            emit(state.copyWith(
              status: AuthStatus.error, 
              errorMessage: 'Registrasi berhasil, tapi gagal masuk otomatis: $loginFailure',
            ));
          },
          (loggedInUser) {
            emit(state.copyWith(
              status: AuthStatus.authenticated, 
              user: loggedInUser as UserModel,
            ));
          },
        );
      },
    );
  }

  Future<void> _onLogoutRequested(LogoutRequested event, Emitter<AuthState> emit) async {
    await logoutUseCase();
    emit(state.copyWith(status: AuthStatus.unauthenticated, user: null));
  }

  Future<void> _onUpdateAvatarRequested(UpdateAvatarRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(isUploadingAvatar: true, avatarErrorMessage: null));
    try {
      final userId = pb.authStore.model?.id;
      if (userId == null) {
        emit(state.copyWith(isUploadingAvatar: false, avatarErrorMessage: 'Sesi tidak ditemukan'));
        return;
      }

      final record = await pb.collection('users').update(
        userId,
        files: [
          await http.MultipartFile.fromPath('avatar', event.imagePath),
        ],
      );

      // Simpan perubahan ke storage local PocketBase
      pb.authStore.save(pb.authStore.token, record);

      final updatedUser = UserModel.fromRecord(record);
      emit(state.copyWith(
        isUploadingAvatar: false,
        user: updatedUser,
      ));
    } catch (e) {
      print('ERROR: Gagal memperbarui avatar: $e');
      emit(state.copyWith(
        isUploadingAvatar: false,
        avatarErrorMessage: e.toString(),
      ));
    }
  }
}
