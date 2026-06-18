class Motor {
  final int id;
  final String name;
  final String brand;
  final String type;
  final double price;
  final String imagePath;
  final int year;
  final String transmission;
  final int engineCC;
  final int weight;
  final List<String> colors;
  final String description;

  Motor({
    required this.id,
    required this.name,
    required this.brand,
    required this.type,
    required this.price,
    required this.imagePath,
    required this.year,
    required this.transmission,
    required this.engineCC,
    required this.weight,
    required this.colors,
    required this.description,
  });
}

// Static motorcycle data
final List<Motor> motorList = [
  // Honda Motorcycles
  Motor(
    id: 1,
    name: 'Honda CB150R',
    brand: 'Honda',
    type: 'Sport',
    price: 24500000,
    imagePath: 'assets/images/honda/cb150r.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 150,
    weight: 130,
    colors: ['Black', 'Red', 'White'],
    description: 'Desain sporty dengan performa tinggi, sempurna untuk pengendara muda yang menginginkan kecepatan dan gaya.',
  ),
  Motor(
    id: 2,
    name: 'Honda CB500F',
    brand: 'Honda',
    type: 'Naked Bike',
    price: 89000000,
    imagePath: 'assets/images/honda/cb500f.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 500,
    weight: 189,
    colors: ['Black', 'Red', 'Blue'],
    description: 'Naked bike dengan mesin 500cc yang powerful, cocok untuk touring dan harian dengan performa balance.',
  ),
  Motor(
    id: 3,
    name: 'Honda PCX 160',
    brand: 'Honda',
    type: 'Skuter Matic',
    price: 29500000,
    imagePath: 'assets/images/honda/pcx160.webp',
    year: 2024,
    transmission: 'Automatic',
    engineCC: 160,
    weight: 130,
    colors: ['White', 'Blue', 'Black'],
    description: 'Skuter premium dengan fitur canggih, hemat bahan bakar, dan desain stylish untuk mobilitas sehari-hari.',
  ),
  Motor(
    id: 4,
    name: 'Honda CB Shine',
    brand: 'Honda',
    type: 'Commuter',
    price: 15000000,
    imagePath: 'assets/images/honda/cb_shine.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 125,
    weight: 130,
    colors: ['Black', 'Silver', 'Red'],
    description: 'Motor commuter terjangkau dengan teknologi fuel-efficient, ideal untuk pengguna harian dengan budget terbatas.',
  ),
  Motor(
    id: 5,
    name: 'Honda CRF300L',
    brand: 'Honda',
    type: 'Adventure',
    price: 75000000,
    imagePath: 'assets/images/honda/crf300l.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 286,
    weight: 168,
    colors: ['Orange', 'White', 'Black'],
    description: 'Adventure bike dengan kemampuan off-road yang handal, suspension empuk, cocok untuk petualangan ekstrim.',
  ),

  // Yamaha Motorcycles
  Motor(
    id: 6,
    name: 'Yamaha YZF-R15',
    brand: 'Yamaha',
    type: 'Sport',
    price: 32500000,
    imagePath: 'assets/images/yamaha/yzf_r15.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 155,
    weight: 142,
    colors: ['Blue', 'Black', 'White'],
    description: 'Motor sport super advanced dengan teknologi VVA, aerodynamics mulus, dan desain futuristik untuk performa maksimal.',
  ),
  Motor(
    id: 7,
    name: 'Yamaha MT-15',
    brand: 'Yamaha',
    type: 'Naked Bike',
    price: 28000000,
    imagePath: 'assets/images/yamaha/mt15.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 155,
    weight: 142,
    colors: ['Dark Gray', 'Blue', 'Red'],
    description: 'Naked bike agresif dengan mesin berteknologi tinggi, desain gahar, perfect untuk pengguna yang mencari performa dan gaya.',
  ),
  Motor(
    id: 8,
    name: 'Yamaha NMAX 155',
    brand: 'Yamaha',
    type: 'Skuter Matic',
    price: 36000000,
    imagePath: 'assets/images/yamaha/nmax155.webp',
    year: 2024,
    transmission: 'Automatic',
    engineCC: 155,
    weight: 142,
    colors: ['White', 'Black', 'Blue'],
    description: 'Premium scooter dengan fitur smart tech, mesin bertenaga, dan kenyamanan maksimal untuk urban commuting.',
  ),
  Motor(
    id: 9,
    name: 'Yamaha Mio M3 125',
    brand: 'Yamaha',
    type: 'Commuter',
    price: 18000000,
    imagePath: 'assets/images/yamaha/mio_m3.webp',
    year: 2024,
    transmission: 'Automatic',
    engineCC: 125,
    weight: 115,
    colors: ['Black', 'White', 'Red'],
    description: 'Scooter ekonomis dengan konsumsi bahan bakar sangat efisien, cocok untuk transportasi sehari-hari dengan harga terjangkau.',
  ),
  Motor(
    id: 10,
    name: 'Yamaha TW200',
    brand: 'Yamaha',
    type: 'Adventure',
    price: 55000000,
    imagePath: 'assets/images/yamaha/tw200.webp',
    year: 2024,
    transmission: 'Manual',
    engineCC: 198,
    weight: 138,
    colors: ['White', 'Black'],
    description: 'Adventure bike entry-level yang tangguh, single cylinder engine yang reliable, sempurna untuk petualangan off-road.',
  ),
];

// Get distinct brands
List<String> getBrands() {
  return motorList.map((m) => m.brand).toSet().toList();
}

// Get distinct types
List<String> getTypes() {
  return motorList.map((m) => m.type).toSet().toList();
}
