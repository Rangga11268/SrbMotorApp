import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../models/motor.dart';
import '../../widgets/custom_app_bar.dart';
import '../motor_detail/motor_detail_screen.dart';
import '../menu/order_history_screen.dart';
import '../menu/profile_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Pesanan'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
          selectedItemColor: const Color(0xFF2563EB),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<MotorProvider>().initializeData();
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final motorProvider = context.watch<MotorProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(),
      body: RefreshIndicator(
        onRefresh: () => context.read<MotorProvider>().fetchMotors(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${user?.name ?? 'Pengguna'} 👋',
                      style: GoogleFonts.outfit(fontSize: 16, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Mau motor apa hari ini?',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) => motorProvider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Cari motor impian Anda...',
                          hintStyle: GoogleFonts.outfit(color: Colors.grey, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF2563EB)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Single Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 5)),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/banner/banner.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Categories
            SliverToBoxAdapter(
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: motorProvider.categories.length + 1,
                  itemBuilder: (context, index) {
                    final String categoryName;
                    final bool isSelected;
                    
                    if (index == 0) {
                      categoryName = 'All';
                      isSelected = motorProvider.selectedCategory == null;
                    } else {
                      final category = motorProvider.categories[index - 1];
                      categoryName = category.name;
                      isSelected = motorProvider.selectedCategory == category.name;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          _getIconData(index == 0 ? 'all' : (motorProvider.categories[index - 1].icon ?? 'motorcycle')),
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF2563EB),
                        ),
                        label: Text(categoryName),
                        selected: isSelected,
                        onSelected: (selected) {
                          motorProvider.setCategory(index == 0 ? null : categoryName);
                        },
                        selectedColor: const Color(0xFF2563EB),
                        labelStyle: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.grey.withValues(alpha: 0.1),
                          ),
                        ),
                        elevation: isSelected ? 4 : 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Motor Grid
            if (motorProvider.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (motorProvider.errorMessage != null)
              SliverFillRemaining(child: Center(child: Text(motorProvider.errorMessage!)))
            else if (motorProvider.motors.isEmpty)
              const SliverFillRemaining(child: Center(child: Text('Tidak ada motor ditemukan')))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final motor = motorProvider.motors[index];
                      return _buildMotorCard(motor, currencyFormat);
                    },
                    childCount: motorProvider.motors.length,
                  ),
                ),
              ),

            // Partners Section
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner Pembiayaan Kami',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildPartnerLogo('assets/images/logo_adira.png'),
                        _buildPartnerLogo('assets/images/logo_baf.png'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'all': return Icons.grid_view_outlined;
      case 'motorcycle': return Icons.motorcycle_outlined;
      case 'speed': return Icons.speed_outlined;
      case 'electric_bolt': return Icons.electric_bolt_outlined;
      case 'pedal_bike': return Icons.pedal_bike_outlined;
      case 'settings_input_component': return Icons.settings_input_component_outlined;
      default: return Icons.motorcycle_outlined;
    }
  }

  Widget _buildPartnerLogo(String path) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5),
        ],
      ),
      child: Image.asset(path, height: 40, errorBuilder: (c, e, s) => const Icon(Icons.business, color: Colors.grey)),
    );
  }

  Widget _buildMotorCard(Motor motor, NumberFormat format) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MotorDetailScreen(motor: motor),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  image: motor.imagePath != null
                      ? DecorationImage(
                          image: NetworkImage(motor.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : DecorationImage(
                          image: const AssetImage('assets/images/logo_srb.png'),
                          fit: BoxFit.contain,
                          opacity: 0.1, // Subtle watermark look
                        ),
                ),
                child: motor.imagePath == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.motorcycle, size: 40, color: Colors.blueGrey.withValues(alpha: 0.3)),
                            const SizedBox(height: 8),
                            Text(
                              'Foto Belum Tersedia',
                              style: GoogleFonts.outfit(fontSize: 10, color: Colors.blueGrey.withValues(alpha: 0.5)),
                            ),
                          ],
                        ),
                      )
                    : null,
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle),
                      child: const Icon(Icons.favorite_border, size: 18, color: Colors.red),
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      motor.brand.toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF0369A1), fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    motor.name,
                    style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.sell_outlined, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          format.format(motor.price),
                          style: GoogleFonts.outfit(fontSize: 14, color: Colors.green, fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis,
                        ),
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
