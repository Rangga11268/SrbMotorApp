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
  });

  factory Motor.fromJson(Map<String, dynamic> json) {
    return Motor(
      id: json['id'],
      name: json['name'],
      brand: json['brand'] ?? 'Unknown',
      type: json['type'],
      price: (json['price'] ?? 0).toDouble(),
      imagePath: json['image_path'],
      details: json['details'],
      transmission: json['transmission'],
      engine: json['engine'],
      weight: json['weight'],
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
    };
  }
}
