/// Parameters for user registration
/// Must match the RegisterDto structure in NestJS backend
class RegisterParams {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final List<String>? roles; // default ["RENTER"]
  final String? idCardNum;
  final String? address;

  const RegisterParams({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    this.roles,
    this.idCardNum,
    this.address,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'email': email,
      'password': password,
      'fullName': fullName,
      'phone': phone,
    };

    // if (role != null) json['role'] = role;
    if (idCardNum != null) json['idCardNum'] = idCardNum;
    if (address != null) json['address'] = address;

    return json;
  }

  RegisterParams copyWith({
    String? email,
    String? password,
    String? fullName,
    String? phone,
    // String? role,
    String? idCardNum,
    String? address,
  }) {
    return RegisterParams(
      email: email ?? this.email,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      // role: role ?? this.role,
      idCardNum: idCardNum ?? this.idCardNum,
      address: address ?? this.address,
    );
  }
}

/// Parameters for user login
class LoginParams {
  final String email;
  final String password;

  const LoginParams({required this.email, required this.password});

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}
