import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../models/professional_model.dart';

abstract class ProfessionalRemoteDataSource {
  Future<ProfessionalModel> getProfessionalData(String userId, String role);
  Future<void> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
  });
  Future<RecordModel> subscribeProfessional(String userId, String roleType);
  Future<List<ProfessionalModel>> getAllTrainers();
  Future<List<ProfessionalModel>> getAllGyms();
}

class ProfessionalRemoteDataSourceImpl implements ProfessionalRemoteDataSource {
  final PocketBase pb;

  ProfessionalRemoteDataSourceImpl({required this.pb});

  @override
  Future<ProfessionalModel> getProfessionalData(String userId, String role) async {
    final collection = role == 'trainer' ? 'trainers' : 'gyms';
    final result = await pb.collection(collection).getFirstListItem('user = "$userId"');
    return ProfessionalModel.fromRecord(result);
  }

  @override
  Future<void> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
  }) async {
    final collection = role == 'trainer' ? 'trainers' : 'gyms';
    
    // Siapkan body data
    final body = {
      'user': userId,
      'name': name,
      'description': description,
      'price': price,
    };
    if (specialty != null) body['specialty'] = specialty;
    if (location != null) body['location'] = location;

    // Siapkan file list
    final List<http.MultipartFile> files = [];
    
    if (avatarFile != null) {
      files.add(await http.MultipartFile.fromPath('avatar', avatarFile.path));
    }

    if (galleryFiles != null) {
      for (var f in galleryFiles) {
        files.add(await http.MultipartFile.fromPath('gallery', f.path));
      }
    }

    try {
      final existing = await pb.collection(collection).getFirstListItem('user = "$userId"');
      await pb.collection(collection).update(existing.id, body: body, files: files);
    } catch (e) {
      await pb.collection(collection).create(body: body, files: files);
    }
  }

  @override
  Future<RecordModel> subscribeProfessional(String userId, String roleType) async {
    final Map<String, dynamic> body;
    if (roleType == 'trainer') {
      body = {'is_trainer': true};
    } else if (roleType == 'gym') {
      body = {'is_gym': true};
    } else {
      body = {'role': 'pro'};
    }
    final result = await pb.collection('users').update(userId, body: body);
    pb.authStore.save(pb.authStore.token, result);
    return result;
  }

  @override
  Future<List<ProfessionalModel>> getAllTrainers() async {
    final result = await pb.collection('trainers').getFullList(sort: '-created');
    return result.map((e) => ProfessionalModel.fromRecord(e)).toList();
  }

  @override
  Future<List<ProfessionalModel>> getAllGyms() async {
    final result = await pb.collection('gyms').getFullList(sort: '-created');
    return result.map((e) => ProfessionalModel.fromRecord(e)).toList();
  }
}
