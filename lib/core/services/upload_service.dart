import 'dart:typed_data';
import 'package:dio/dio.dart';

import '../constants/api_constants.dart';
import '../network/dio_client.dart';

class UploadResult {
  final String url;
  final String key;
  final String fileName;

  UploadResult({
    required this.url,
    required this.key,
    required this.fileName,
  });

  factory UploadResult.fromJson(Map<String, dynamic> json) {
    return UploadResult(
      url: json['url'] ?? '',
      key: json['key'] ?? '',
      fileName: json['fileName'] ?? '',
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
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });

    final response = await _dioClient.post(
      ApiConstants.uploadVehicleImage,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return UploadResult.fromJson(response.data);
  }

  /// Upload a license/document image
  Future<UploadResult> uploadLicenseImage({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });

    final response = await _dioClient.post(
      ApiConstants.uploadLicense,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return UploadResult.fromJson(response.data);
  }

  /// Upload multiple vehicle images
  Future<List<UploadResult>> uploadVehicleImages({
    required List<Uint8List> filesBytes,
    required List<String> fileNames,
  }) async {
    final files = <MultipartFile>[];
    for (var i = 0; i < filesBytes.length; i++) {
      files.add(MultipartFile.fromBytes(
        filesBytes[i],
        filename: fileNames[i],
      ));
    }

    final formData = FormData.fromMap({
      'files': files,
    });

    final response = await _dioClient.post(
      ApiConstants.uploadVehicleImages,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return (response.data as List)
        .map((json) => UploadResult.fromJson(json))
        .toList();
  }
}
