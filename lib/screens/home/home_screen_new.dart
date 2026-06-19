import 'dart:async';
import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/screens/home/widgets/featured_motor_card.dart';

class HomeScreenNew extends StatefulWidget {
  final AppState appState;
  final Function(int) onTabChange;
  final Function(Motor) onMotorTap;

  const HomeScreenNew({
    super.key,
    required this.appState,
    required this.onTabChange,
    required this.onMotorTap,
  });

  @override
  State<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends State<HomeScreenNew> {
  final searchController = TextEditingController();
  List<Motor> popularMotors = [];
  int currentSlide = 0;
  final PageController _pageController = PageController(initialPage: 0);
  Timer? _sliderTimer;

  @override
  void initState() {
    super.initState();
    // Use first 4 motors as popular ones
    popularMotors = motorList.take(4).toList();

    // Auto play slider every 4 seconds
    _sliderTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        int nextPage = currentSlide + 1;
        if (nextPage >= 4) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Top Logo Banner Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset(
              'assets/images/logos/logo_srb.webp',
              height: 40,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none, color: Color(0xFF041627)),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tidak ada notifikasi baru')),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        // User Welcome Header with Profile Photo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5F5E5E),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.appState.currentUser?.name ?? 'Pengunjung',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF041627),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                // Navigate to profile tab (index 3)
                widget.onTabChange(3);
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFEEEEEE),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFFE2E2E2),
                  child: const Icon(
                    Icons.person,
                    color: Color(0xFF041627),
                    size: 28,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Search Bar
        TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Cari model motor...',
            prefixIcon: const Icon(Icons.search, color: Color(0xFF5F5E5E)),
            filled: true,
            fillColor: const Color(0xFFF3F3F3), // bg-surface-container-low
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
          onSubmitted: (query) {
            if (query.isNotEmpty) {
              // Go to Catalog tab (tab index 1)
              widget.onTabChange(1);
            }
          },
        ),
        const SizedBox(height: 24),
        // Auto-playing Image Slider
        SizedBox(
          height: 180,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    currentSlide = index;
                  });
                },
                children: [
                  // Slide 0: Phantom X Banner
                  _buildPhantomXBanner(),
                  // Slide 1: Dealer Banner 1
                  _buildImageBanner('assets/images/banner/srb_motors_dealer_banner_1.png'),
                  // Slide 2: Service Banner
                  _buildImageBanner('assets/images/banner/banner_service.png'),
                  // Slide 3: Dealer Banner 2
                  _buildImageBanner('assets/images/banner/srb_motors_dealer_banner_2.png'),
                ],
              ),
              // Dot Indicators
              Positioned(
                bottom: 12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: currentSlide == index ? 16 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: currentSlide == index
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.5),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Categories Row
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Switch to catalog and filter by Honda
                    widget.onTabChange(1);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFF3F3F3),
                  ),
                  child: const Text(
                    'Honda',
                    style: TextStyle(
                      color: Color(0xFF041627),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 50,
                child: OutlinedButton(
                  onPressed: () {
                    // Switch to catalog and filter by Yamaha
                    widget.onTabChange(1);
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E2E2)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: const Color(0xFFF3F3F3),
                  ),
                  child: const Text(
                    'Yamaha',
                    style: TextStyle(
                      color: Color(0xFF041627),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Popular Motorcycles Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Popular Motorcycles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF041627),
              ),
            ),
            TextButton(
              onPressed: () => widget.onTabChange(1),
              child: const Text(
                'VIEW ALL',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF5F5E5E),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // Popular Motorcycles list (horizontal)
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: popularMotors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final motor = popularMotors[index];
              final isWishlisted = widget.appState.isInWishlist(motor.id);
              return FeaturedMotorCard(
                motor: motor,
                isWishlisted: isWishlisted,
                formatPrice: formatPrice,
                onWishlistToggle: () async {
                  await widget.appState.toggleWishlist(motor.id);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onTap: () => widget.onMotorTap(motor),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        // Leasing Partners Section
        const Text(
          'Mitra Pembiayaan (Leasing)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF041627),
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildLeasingCard('assets/images/logos/oto.webp', 'OTO'),
              const SizedBox(width: 12),
              _buildLeasingCard('assets/images/logos/muf.webp', 'MUF'),
              const SizedBox(width: 12),
              _buildLeasingCard('assets/images/logos/fif.webp', 'FIF'),
              const SizedBox(width: 12),
              _buildLeasingCard('assets/images/logos/baf.webp', 'BAF'),
              const SizedBox(width: 12),
              _buildLeasingCard('assets/images/logos/adira.webp', 'Adira'),
            ],
          ),
        ),
        const SizedBox(height: 32),
        // Why Choose Us Section
        const Text(
          'Keunggulan SRB Motor',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF041627),
          ),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.bolt,
          iconColor: Colors.amber[700]!,
          title: 'Proses Cepat & Mudah',
          subtitle: 'Persetujuan kredit kurang dari 24 jam dengan syarat dokumen yang simpel.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.local_offer,
          iconColor: Colors.blue[700]!,
          title: 'Diskon DP Spesial',
          subtitle: 'Potongan Down Payment (DP) hingga jutaan rupiah untuk berbagai unit motor pilihan.',
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          icon: Icons.verified,
          iconColor: Colors.green[700]!,
          title: '100% Aman & Terpercaya',
          subtitle: 'Bekerja sama secara langsung dengan dealer resmi dan leasing ternama di Indonesia.',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildLeasingCard(String assetPath, String fallbackText) {
    return Container(
      width: 120,
      height: 64,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Center(
          child: Text(
            fallbackText,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5F5E5E),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF041627),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5F5E5E),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhantomXBanner() {
    return GestureDetector(
      onTap: () {
        final phantomX = motorList.firstWhere(
          (m) => m.name.toLowerCase().contains('phantom'),
          orElse: () => motorList.first,
        );
        widget.onMotorTap(phantomX);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          image: const DecorationImage(
            image: AssetImage('assets/images/banner/banner.webp'),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF041627).withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'NEW ARRIVAL',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'The New Phantom X',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text(
                        'EXPLORE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, color: Colors.white, size: 12),
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

  Widget _buildImageBanner(String path) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: DecorationImage(
          image: AssetImage(path),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
