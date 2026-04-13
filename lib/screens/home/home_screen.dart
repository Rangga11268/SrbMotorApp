import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/api_config.dart';
import '../../models/motor.dart';
import '../../providers/main_provider.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../motor_detail/motor_detail_screen.dart';
import '../menu/order_history_screen.dart';
import '../menu/profile_screen.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchGlobalWhatsApp(context),
        backgroundColor: const Color(0xFF25D366),
        mini: true,
        child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 20),
      ),
      bottomNavigationBar: CustomBottomNav(
        selectedIndex: mainProvider.selectedIndex,
        onTap: (index) => mainProvider.setSelectedIndex(index),
      ),
    );
  }

  void _launchGlobalWhatsApp(BuildContext context) async {
    final phone = context.read<MotorProvider>().contactPhone;
    final message = Uri.encodeComponent(
      'Halo Admin SRB Motor, saya ingin bertanya mengenai layanan Dealer SSM.',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
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
        // initializeIfNeeded: skip fetch jika data sudah ada di memori
        // sehingga kembali dari OrderForm/MotorDetail tidak loading ulang
        context.read<MotorProvider>().initializeIfNeeded();
        context.read<NotificationProvider>().fetchNotifications();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final motorProvider = context.watch<MotorProvider>();
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Selamat Datang, ${user?.name ?? 'Pengguna'}',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                color: Colors.blueGrey,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Mau motor apa hari ini?',
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        if (user?.profilePhotoPath != null)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFF2563EB).withOpacity(0.1),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 25,
                              backgroundImage: NetworkImage(user!.profilePhotoPath!),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Search Bar
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: TextField(
                        onChanged: (value) =>
                            motorProvider.setSearchQuery(value),
                        decoration: InputDecoration(
                          hintText: 'Cari motor impian Anda...',
                          hintStyle: GoogleFonts.outfit(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF2563EB),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
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
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    image: const DecorationImage(
                      image: AssetImage('assets/images/banner/banner.webp'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Brand Category Custom Selector
            SliverToBoxAdapter(
              child: SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: motorProvider.brands.length + 1,
                  itemBuilder: (context, index) {
                    final String brandName;
                    final bool isSelected;
                    final IconData brandIcon;

                    if (index == 0) {
                      brandName = 'All';
                      isSelected = motorProvider.selectedBrand == null;
                      brandIcon = _getIconData('all');
                    } else {
                      brandName = motorProvider.brands[index - 1];
                      isSelected = motorProvider.selectedBrand == brandName;
                      brandIcon = _getIconData(brandName);
                    }

                    final bool hasLogo = _getBrandLogo(brandName) != null;

                    return GestureDetector(
                      onTap: () => motorProvider.setBrand(index == 0 ? null : brandName),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 75,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected 
                                  ? const Color(0xFF2563EB).withValues(alpha: 0.3)
                                  : Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                          border: Border.all(
                            color: isSelected 
                                ? const Color(0xFF2563EB) 
                                : const Color(0xFFE2E8F0),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isSelected && hasLogo
                                ? Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Image.asset(
                                      _getBrandLogo(brandName)!,
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.contain,
                                    ),
                                  )
                                : hasLogo
                                    ? Image.asset(
                                        _getBrandLogo(brandName)!,
                                        height: 32,
                                        width: 32,
                                        fit: BoxFit.contain,
                                      )
                                    : Icon(
                                        brandIcon,
                                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                                        size: 28,
                                      ),
                            const SizedBox(height: 8),
                            Text(
                              brandName,
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
                                color: isSelected ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // Motor Grid
            if (motorProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (motorProvider.errorMessage != null)
              SliverFillRemaining(
                child: Center(child: Text(motorProvider.errorMessage!)),
              )
            else if (motorProvider.motors.isEmpty)
              const SliverFillRemaining(
                child: Center(child: Text('Tidak ada motor ditemukan')),
              )
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
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final motor = motorProvider.motors[index];
                    return _buildMotorCard(motor, currencyFormat);
                  }, childCount: motorProvider.motors.length),
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

  String? _getBrandLogo(String name) {
    switch (name.toLowerCase()) {
      case 'honda':
        return 'assets/images/logos/Honda.webp';
      case 'yamaha':
        return 'assets/images/logos/yamaha.webp';
      default:
        return null;
    }
  }

  IconData _getIconData(String name) {
    switch (name.toLowerCase()) {
      case 'all':
        return Icons.grid_view_outlined;
      case 'honda':
        return Icons.motorcycle;
      case 'yamaha':
        return Icons.speed;
      case 'kawasaki':
        return Icons.directions_run; // Ninja vibe?
      case 'suzuki':
        return Icons.electric_bike;
      default:
        return Icons.two_wheeler_outlined;
    }
  }

  Widget _buildPartnerLogo(Map<String, String> provider) {
    return Container(
      width: 120,
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
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Image.asset(
          provider['logoUrl']!,
          height: 32,
          fit: BoxFit.contain,
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
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
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
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      image: motor.imagePath != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(
                                ApiConfig.sanitizeUrl(motor.imagePath!)!,
                                headers: ApiConfig.ngrokHeaders,
                              ),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: const AssetImage(
                                'assets/images/logos/logo_srb.webp',
                              ),
                              fit: BoxFit.contain,
                              opacity: 0.1, // Subtle watermark look
                            ),
                    ),
                    child: motor.imagePath == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.motorcycle,
                                  size: 40,
                                  color: Colors.blueGrey.withValues(alpha: 0.3),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Foto Belum Tersedia',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    color: Colors.blueGrey.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: motor.tersedia
                            ? Colors.green.withValues(alpha: 0.9)
                            : Colors.red.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        motor.tersedia ? 'Tersedia' : 'Habis',
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 18,
                        color: Colors.red,
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
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0F2FE),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      motor.brand.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        color: const Color(0xFF0369A1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    motor.name,
                    style: GoogleFonts.outfit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.sell_outlined,
                        size: 14,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          format.format(motor.price),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w700,
                          ),
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
