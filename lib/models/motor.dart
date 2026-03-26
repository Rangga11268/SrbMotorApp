import '../services/api_config.dart';

class Motor {
  final int id;
  final String name;
  final String brand;
  final String? type;
  final double price;
  final String? imagePath;
  final String? details;
  final String? transmission;
  final int? engine;
  final int? weight;
  final dynamic colors;
  final int year;
  final bool tersedia;

  Motor({
    required this.id,
    required this.name,
    required this.brand,
    this.type,
    required this.price,
    this.imagePath,
    this.details,
    this.transmission,
    this.engine,
    this.weight,
    this.colors,
    required this.year,
    this.tersedia = true,
  });

  factory Motor.fromJson(Map<String, dynamic> json) {
    // Build the correct image URL from whatever the API returns
    String? imagePath;
    final rawImg = (json['image']?.toString().isNotEmpty == true)
        ? json['image'].toString()
        : json['image_path']?.toString();

    if (rawImg != null && rawImg.isNotEmpty) {
      if (rawImg.startsWith('http')) {
        imagePath = ApiConfig.sanitizeUrl(rawImg);
      } else if (rawImg.startsWith('assets/')) {
        imagePath = 'http://10.0.2.2:8000/$rawImg';
      } else {
        String cleanPath = rawImg;
        if (cleanPath.startsWith('/')) cleanPath = cleanPath.substring(1);
        if (cleanPath.startsWith('storage/')) cleanPath = cleanPath.replaceFirst('storage/', '');
        imagePath = ApiConfig.sanitizeUrl('http://10.0.2.2:8000/storage/$cleanPath');
      }
    }

    return Motor(
      id: json['id'],
      name: json['name'],
      brand: json['brand'] ?? 'Unknown',
      type: json['type'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      imagePath: imagePath,
      details: json['details'],
      transmission: json['transmission'],
      engine: json['engine'],
      weight: json['weight'],
      colors: json['colors'],
      year: json['year'] ?? 0,
      tersedia: json['tersedia'] == 1 || json['tersedia'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'type': type,
      'price': price,
      'image_path': imagePath,
      'details': details,
      'transmission': transmission,
      'engine': engine,
      'weight': weight,
      'colors': colors,
      'year': year,
      'tersedia': tersedia ? 1 : 0,
    };
  }
}
