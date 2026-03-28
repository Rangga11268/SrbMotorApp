import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/leasing_provider.dart';
import '../../services/api_config.dart';
import '../../models/motor.dart';
import '../../providers/main_provider.dart';
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

  final List<Widget> _pages = [
    const HomeContent(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final mainProvider = context.watch<MainProvider>();
    return Scaffold(
      body: _pages[mainProvider.selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 0),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: mainProvider.selectedIndex,
          onTap: (index) {
            mainProvider.setSelectedIndex(index);
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
        context.read<NotificationProvider>().fetchNotifications();
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
        onRefresh: () => context.read<MotorProvider>().initializeData(),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang, ${user?.name ?? 'Pengguna'}',
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

            // Brand Category Chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 45,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: motorProvider.brands.length + 1,
                  itemBuilder: (context, index) {
                    final String brandName;
                    final bool isSelected;
                    
                    if (index == 0) {
                      brandName = 'All';
                      isSelected = motorProvider.selectedBrand == null;
                    } else {
                      brandName = motorProvider.brands[index - 1];
                      isSelected = motorProvider.selectedBrand == brandName;
                    }

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        avatar: Icon(
                          _getIconData(index == 0 ? 'all' : brandName),
                          size: 18,
                          color: isSelected ? Colors.white : const Color(0xFF2563EB),
                        ),
                        label: Text(brandName),
                        selected: isSelected,
                        onSelected: (selected) {
                          motorProvider.setBrand(index == 0 ? null : brandName);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Padding(
                    padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Partner Pembiayaan',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          'Resmi',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: motorProvider.leasingProviders.length,
                      itemBuilder: (context, index) {
                        final provider = motorProvider.leasingProviders[index];
                        return _buildPartnerLogo(provider);
                      },
                    ),
                  ),
                ],
              ),
            ),
            
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'all': return Icons.grid_view_outlined;
      case 'honda': return Icons.motorcycle;
      case 'yamaha': return Icons.speed;
      case 'kawasaki': return Icons.directions_run; // Ninja vibe?
      case 'suzuki': return Icons.electric_bike;
      default: return Icons.two_wheeler_outlined;
    }
  }

  Widget _buildPartnerLogo(LeasingProvider provider) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12, bottom: 8, top: 2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Center(
        child: provider.logoUrl != null
            ? CachedNetworkImage(
                imageUrl: ApiConfig.sanitizeUrl(provider.logoUrl!)!,
                height: 32,
                fit: BoxFit.contain,
                placeholder: (context, url) => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2)),
                errorWidget: (c, e, s) => Text(
                  provider.name,
                  style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: const Color(0xFF64748B)),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_outlined,
                      size: 16, color: Color(0xFF2563EB)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.name,
                      style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: const Color(0xFF1E293B)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
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
                          image: CachedNetworkImageProvider(ApiConfig.sanitizeUrl(motor.imagePath!)!),
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
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: motor.tersedia ? Colors.green.withValues(alpha: 0.9) : Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        motor.tersedia ? 'Tersedia' : 'Habis',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), shape: BoxShape.circle),
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
