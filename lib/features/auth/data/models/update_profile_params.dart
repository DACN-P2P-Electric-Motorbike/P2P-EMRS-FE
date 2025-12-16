import 'dart:io';

class UpdateProfileParams {
  final String? fullName;
  final String? phone;
  final String? address;
  final File? avatarFile; // File ảnh mới (nếu có)

  UpdateProfileParams({
    this.fullName,
    this.phone,
    this.address,
    this.avatarFile,
  });
}
