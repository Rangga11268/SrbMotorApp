class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? nik;
  final String? alamat;
  final String? occupation;
  final String? profilePhotoPath;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.nik,
    this.alamat,
    this.occupation,
    this.profilePhotoPath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone']?.toString(),
      role: json['role'],
      nik: json['nik']?.toString(),
      alamat: json['alamat']?.toString(),
      occupation: json['occupation']?.toString(),
      profilePhotoPath: json['profile_photo_path'] ?? json['profile_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'nik': nik,
      'alamat': alamat,
      'occupation': occupation,
      'profile_photo_path': profilePhotoPath,
    };
  }
}
