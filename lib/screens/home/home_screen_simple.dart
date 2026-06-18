import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController searchController;
  String selectedBrand = 'Semua';
  String selectedType = 'Semua';
  List<Motor> filteredMotors = motorList;
  int selectedTab = 0; // 0: Catalog, 1: Wishlist, 2: Profile

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterMotors() {
    List<Motor> filtered = motorList;

    // Filter by search query
    if (searchController.text.isNotEmpty) {
      filtered = filtered
          .where((motor) =>
          motor.name.toLowerCase().contains(searchController.text.toLowerCase()) ||
          motor.brand.toLowerCase().contains(searchController.text.toLowerCase()))
          .toList();
    }

    // Filter by brand
    if (selectedBrand != 'Semua') {
      filtered = filtered.where((motor) => motor.brand == selectedBrand).toList();
    }

    // Filter by type
    if (selectedType != 'Semua') {
      filtered = filtered.where((motor) => motor.type == selectedType).toList();
    }

    setState(() {
      filteredMotors = filtered;
    });
  }

  void resetFilters() {
    searchController.clear();
    setState(() {
      selectedBrand = 'Semua';
      selectedType = 'Semua';
      filteredMotors = motorList;
    });
  }

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SRB Motor Catalog'),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                widget.appState.currentUser?.name ?? 'User',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: selectedTab == 0
          ? buildCatalogTab()
          : selectedTab == 1
          ? buildWishlistTab()
          : buildProfileTab(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedTab,
        onTap: (index) {
          setState(() {
            selectedTab = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.two_wheeler),
            label: 'Katalog',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }

  Widget buildCatalogTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: searchController,
            onChanged: (value) => filterMotors(),
            decoration: InputDecoration(
              hintText: 'Cari motor...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        // Filter chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Brand', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Semua',
                    ...getBrands(),
                  ]
                      .map((brand) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(brand),
                      selected: selectedBrand == brand,
                      onSelected: (selected) {
                        setState(() {
                          selectedBrand = brand;
                        });
                        filterMotors();
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: selectedBrand == brand ? Colors.white : Colors.black,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Text('Tipe', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'Semua',
                    ...getTypes(),
                  ]
                      .map((type) => Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: FilterChip(
                      label: Text(type),
                      selected: selectedType == type,
                      onSelected: (selected) {
                        setState(() {
                          selectedType = type;
                        });
                        filterMotors();
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: const Color(0xFF2563EB),
                      labelStyle: TextStyle(
                        color: selectedType == type ? Colors.white : Colors.black,
                      ),
                    ),
                  ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ditemukan: ${filteredMotors.length} motor',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  TextButton(
                    onPressed: resetFilters,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        // Motor list
        Expanded(
          child: filteredMotors.isEmpty
              ? Center(
            child: Text(
              'Motor tidak ditemukan',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: filteredMotors.length,
            itemBuilder: (context, index) {
              final motor = filteredMotors[index];
              final isWishlisted = widget.appState.isInWishlist(motor.id);

              return MotorCard(
                motor: motor,
                isWishlisted: isWishlisted,
                onWishlistToggle: () {
                  widget.appState.toggleWishlist(motor.id);
                  setState(() {});
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MotorDetailScreen(
                        motor: motor,
                        appState: widget.appState,
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget buildWishlistTab() {
    final wishlistMotors =
    motorList.where((m) => widget.appState.isInWishlist(m.id)).toList();

    return wishlistMotors.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.favorite_border, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            'Wishlist kosong',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan motor favorit Anda',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: wishlistMotors.length,
      itemBuilder: (context, index) {
        final motor = wishlistMotors[index];

        return MotorCard(
          motor: motor,
          isWishlisted: true,
          onWishlistToggle: () {
            widget.appState.toggleWishlist(motor.id);
            setState(() {});
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MotorDetailScreen(
                  motor: motor,
                  appState: widget.appState,
                ),
              ),
            ).then((_) {
              setState(() {});
            });
          },
        );
      },
    );
  }

  Widget buildProfileTab() {
    final user = widget.appState.currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  user?.email ?? '',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            'Informasi Akun',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildInfoTile('Email', user?.email ?? '-'),
          _buildInfoTile('Telepon', user?.phone ?? '-'),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                await widget.appState.logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed('/');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value, style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            )),
          ],
        ),
      ),
    );
  }
}

class MotorCard extends StatelessWidget {
  final Motor motor;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;

  const MotorCard({
    super.key,
    required this.motor,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
  });

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.two_wheeler,
                      size: 80,
                      color: Colors.grey[400],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlistToggle,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              motor.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              motor.brand,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.blue[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          motor.type,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[900],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    formatPrice(motor.price),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${motor.engineCC} cc',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        motor.transmission,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${motor.weight} kg',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MotorDetailScreen extends StatelessWidget {
  final Motor motor;
  final AppState appState;

  const MotorDetailScreen({
    super.key,
    required this.motor,
    required this.appState,
  });

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)}jt';
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = appState.isInWishlist(motor.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Motor'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            Container(
              height: 250,
              width: double.infinity,
              color: Colors.grey[300],
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.two_wheeler,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: GestureDetector(
                      onTap: () {
                        appState.toggleWishlist(motor.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isWishlisted
                                  ? 'Dihapus dari wishlist'
                                  : 'Ditambahkan ke wishlist',
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and brand
                  Text(
                    motor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    motor.brand,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      formatPrice(motor.price),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: const Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    motor.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  Text(
                    'Spesifikasi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSpecRow('Merek', motor.brand),
                  _buildSpecRow('Tipe', motor.type),
                  _buildSpecRow('Tahun', motor.year.toString()),
                  _buildSpecRow('Transmisi', motor.transmission),
                  _buildSpecRow('Mesin', '${motor.engineCC} cc'),
                  _buildSpecRow('Berat', '${motor.weight} kg'),
                  const SizedBox(height: 16),

                  // Colors
                  Text(
                    'Warna Tersedia',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: motor.colors
                        .map((color) => Chip(label: Text(color)))
                        .toList(),
                  ),
                  const SizedBox(height: 24),

                  // Action button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hubungi dealer untuk informasi lebih lanjut'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                      ),
                      child: const Text(
                        'Hubungi Dealer',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
