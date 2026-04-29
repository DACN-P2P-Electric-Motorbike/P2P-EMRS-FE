import 'package:dio/dio.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/network/dio_client.dart';

class PrivacyExportResult {
  final DateTime? generatedAt;
  final Map<String, dynamic> user;

  const PrivacyExportResult({required this.generatedAt, required this.user});

  factory PrivacyExportResult.fromJson(Map<String, dynamic> json) {
    return PrivacyExportResult(
      generatedAt: DateTime.tryParse(json['generatedAt']?.toString() ?? ''),
      user: Map<String, dynamic>.from(json['user'] as Map? ?? {}),
    );
  }

  int listCount(String key) {
    final value = user[key];
    return value is List ? value.length : 0;
  }
}

class PrivacyRequestItem {
  final String id;
  final String type;
  final String status;
  final DateTime? dueAt;
  final DateTime? createdAt;
  final DateTime? completedAt;

  const PrivacyRequestItem({
    required this.id,
    required this.type,
    required this.status,
    required this.dueAt,
    required this.createdAt,
    required this.completedAt,
  });

  factory PrivacyRequestItem.fromJson(Map<String, dynamic> json) {
    return PrivacyRequestItem(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      dueAt: DateTime.tryParse(json['dueAt']?.toString() ?? ''),
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? ''),
      completedAt: DateTime.tryParse(json['completedAt']?.toString() ?? ''),
    );
  }
}

abstract class PrivacyRemoteDataSource {
  Future<PrivacyExportResult> exportPersonalData();
  Future<PrivacyRequestItem> requestAccountDeletion();
  Future<List<PrivacyRequestItem>> getMyRequests();
}

class PrivacyRemoteDataSourceImpl implements PrivacyRemoteDataSource {
  final DioClient _dioClient;

  PrivacyRemoteDataSourceImpl({required DioClient dioClient})
    : _dioClient = dioClient;

  @override
  Future<PrivacyExportResult> exportPersonalData() async {
    try {
      final response = await _dioClient.get(ApiConstants.privacyExport);
      if (response.statusCode == 200) {
        return PrivacyExportResult.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to export personal data',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<PrivacyRequestItem> requestAccountDeletion() async {
    try {
      final response = await _dioClient.post(ApiConstants.privacyDeleteRequest);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return PrivacyRequestItem.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw ServerException(
        message: 'Failed to request account deletion',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }

  @override
  Future<List<PrivacyRequestItem>> getMyRequests() async {
    try {
      final response = await _dioClient.get(ApiConstants.privacyRequests);
      if (response.statusCode == 200) {
        final data = response.data as List? ?? [];
        return data
            .whereType<Map>()
            .map(
              (item) =>
                  PrivacyRequestItem.fromJson(Map<String, dynamic>.from(item)),
            )
            .toList();
      }
      throw ServerException(
        message: 'Failed to load privacy requests',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw ServerException.fromDioException(e);
    }
  }
}
