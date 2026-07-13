import 'package:pocketbase/pocketbase.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    DateTime? birthDate, // Baru
  });
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final PocketBase pb;

  AuthRemoteDataSourceImpl({required this.pb});

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      // Coba login sebagai user biasa dulu
      final authData = await pb
          .collection('users')
          .authWithPassword(email, password);

      final record = authData.record!;
      final isVerified = record.data['verified'] == true;

      // if (!isVerified) {
      //   pb.authStore.clear();
      //   throw Exception('Email Anda belum diverifikasi. Silakan cek kotak masuk email Anda.');
      // }

      return UserModel.fromRecord(record);
    } catch (e) {
      // Jika gagal, coba login sebagai PocketBase Superadmin
      try {
        final superAuthData = await pb
            .collection('_superusers')
            .authWithPassword(email, password);

        final superRecord = superAuthData.record;
        final superEmail = superRecord?.getStringValue('email') ?? email;

        // Buat UserModel sementara untuk superadmin
        return UserModel(
          id: superRecord?.id ?? 'superadmin',
          email: superEmail,
          name: 'Super Admin',
          role: 'admin',
          isTrainer: false,
          isGym: false,
        );
      } catch (superError) {
        // Lempar error asli jika keduanya gagal
        throw Exception('Login gagal. Periksa email dan password Anda.');
      }
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String role,
    DateTime? birthDate, // Baru
  }) async {
    final record = await pb
        .collection('users')
        .create(
          body: {
            'name': name,
            'email': email,
            'password': password,
            'passwordConfirm': password,
            'role': role,
            'birth_date': birthDate?.toIso8601String(), // Baru
            'emailVisibility': true,
          },
        );

    return UserModel.fromRecord(record);
  }

  @override
  Future<void> logout() async {
    pb.authStore.clear();
  }
}
