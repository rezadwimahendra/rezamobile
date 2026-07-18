import 'dart:io';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import '../models/professional_model.dart';

abstract class ProfessionalRemoteDataSource {
  Future<ProfessionalModel?> getProfessionalData(String userId, String role);
  Future<void> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    int? nonMemberPrice,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
    List<String>? existingGallery,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    String? openDays,
  });
  Future<RecordModel> subscribeProfessional(String userId, String roleType);
  Future<List<ProfessionalModel>> getAllTrainers();
  Future<List<ProfessionalModel>> getAllGyms();
}

class ProfessionalRemoteDataSourceImpl implements ProfessionalRemoteDataSource {
  final PocketBase pb;

  ProfessionalRemoteDataSourceImpl({required this.pb});

  @override
  Future<ProfessionalModel?> getProfessionalData(String userId, String role) async {
    final collection = role == 'trainer' ? 'trainers' : 'gyms';
    try {
      final result = await pb.collection(collection).getFirstListItem('user = "$userId"');
      return ProfessionalModel.fromRecord(result);
    } on ClientException catch (e) {
      if (e.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  @override
  Future<void> registerProfessional({
    required String userId,
    required String role,
    required String name,
    required String description,
    required int price,
    int? nonMemberPrice,
    String? specialty,
    String? location,
    File? avatarFile,
    List<File>? galleryFiles,
    List<String>? existingGallery,
    double? latitude,
    double? longitude,
    String? openTime,
    String? closeTime,
    String? openDays,
  }) async {
    final collection = role == 'trainer' ? 'trainers' : 'gyms';
    
    // Siapkan body data
    final Map<String, dynamic> body = {
      'user': userId,
      'name': name,
      'description': description,
      'price': price,
    };
    if (nonMemberPrice != null) body['non_member_price'] = nonMemberPrice;
    if (specialty != null) body['specialty'] = specialty;
    if (location != null) body['location'] = location;
    if (latitude != null) body['latitude'] = latitude;
    if (longitude != null) body['longitude'] = longitude;
    if (openTime != null) body['open_time'] = openTime;
    if (closeTime != null) body['close_time'] = closeTime;
    if (openDays != null) body['open_days'] = openDays;
    if (existingGallery != null) body['gallery'] = existingGallery;

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
      body = {
        'is_trainer': true,
        'subscription_expires': null, // Permanen/Lifetime
      };
    } else if (roleType == 'gym') {
      body = {
        'is_gym': true,
        'subscription_expires': null, // Permanen/Lifetime
      };
    } else {
      final expiryDate = DateTime.now().add(const Duration(days: 30)).toUtc().toIso8601String();
      body = {
        'role': 'pro',
        'subscription_expires': expiryDate, // Hanya Pro yang dibatasi 30 hari
      };
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
