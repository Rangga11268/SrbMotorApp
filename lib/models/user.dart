class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? role;
  final String? nik;
  final String? alamat;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.role,
    this.nik,
    this.alamat,
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
    };
  }
}
