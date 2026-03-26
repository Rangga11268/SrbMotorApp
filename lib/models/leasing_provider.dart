class LeasingProvider {
  final int id;
  final String name;
  final String? logoUrl;

  LeasingProvider({required this.id, required this.name, this.logoUrl});

  factory LeasingProvider.fromJson(Map<String, dynamic> json) {
    return LeasingProvider(
      id: json['id'],
      name: json['name'],
      logoUrl: json['logo_url'],
    );
  }
}
