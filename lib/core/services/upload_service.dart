import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';

class UploadResult {
  final String url;
  final String key;
  final String fileName;
  final String? evidenceReceipt;

  UploadResult({
    required this.url,
    required this.key,
    required this.fileName,
    this.evidenceReceipt,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] ?? '',
      key: json['key'] ?? '',
      fileName: json['fileName'] ?? '',
      evidenceReceipt: json['evidenceReceipt'] as String?,
    );
  }
}

class UploadService {
  final DioClient _dioClient;

  UploadService({required DioClient dioClient}) : _dioClient = dioClient;

  /// Upload a vehicle image
  Future<UploadResult> uploadVehicleImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    final response = await _dioClient.post(
      ApiConstants.uploadVehicleImage,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return UploadResult.fromJson(response.data);
  }

  /// Upload a license/document image
  Future<UploadResult> uploadLicenseImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    final response = await _dioClient.post(
      ApiConstants.uploadLicense,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return UploadResult.fromJson(response.data);
  }

  /// Upload a KYC document or selfie image
  Future<UploadResult> uploadKycImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    final response = await _dioClient.post(
      ApiConstants.uploadKyc,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return UploadResult.fromJson(response.data);
  }

  /// Upload a vehicle handover photo
  Future<UploadResult> uploadHandoverImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    try {
      final response = await _dioClient.post(
        ApiConstants.uploadHandover,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return UploadResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Máy chủ hiện chưa hỗ trợ tải ảnh bàn giao. Vui lòng cập nhật ứng dụng hoặc thử lại sau.';
      }
      rethrow;
    }
  }

  /// Upload an incident or claim evidence image
  Future<UploadResult> uploadIncidentImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
    });

    try {
      final response = await _dioClient.post(
        ApiConstants.uploadIncident,
        data: formData,
        options: Options(headers: {'Content-Type': 'multipart/form-data'}),
      );

      return UploadResult.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw 'Máy chủ hiện chưa hỗ trợ tải ảnh sự cố. Vui lòng cập nhật ứng dụng hoặc thử lại sau.';
      }
      rethrow;
    }
  }

  /// Upload multiple vehicle images
  Future<List<UploadResult>> uploadVehicleImages({
    required List<Uint8List> filesBytes,
    required List<String> fileNames,
  }) async {
    final files = <MultipartFile>[];
    for (var i = 0; i < filesBytes.length; i++) {
      files.add(MultipartFile.fromBytes(filesBytes[i], filename: fileNames[i]));
    }

    final formData = FormData.fromMap({'files': files});

    final response = await _dioClient.post(
      ApiConstants.uploadVehicleImages,
      data: formData,
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );

    return (response.data as List)
        .map((json) => UploadResult.fromJson(json))
        .toList();
  }
}
