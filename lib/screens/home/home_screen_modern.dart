import 'dart:async';

import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';

const _brandBlue = Color(0xFF2563EB);
const _surfaceBg = Color(0xFFF5F7FB);
const _textDark = Color(0xFF0F172A);

class HomeScreen extends StatefulWidget {
  final AppState appState;

  const HomeScreen({super.key, required this.appState});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  final PageController bannerController = PageController();
  String selectedBrand = 'Semua';
  String selectedType = 'Semua';
  List<Motor> filteredMotors = motorList;
  int selectedTab = 0;
  int bannerIndex = 0;
  Timer? bannerTimer;
  final List<String> bannerAssets = const [
    'assets/images/banner/srb_motors_dealer_banner_1.png',
    'assets/images/banner/srb_motors_dealer_banner_2.png',
    'assets/images/banner/srb_motors_dealer_banner_3.png',
    'assets/images/banner/banner.webp',
    'assets/images/banner/banner_promo_1.png',
    'assets/images/banner/banner_service.png',
  ];

  @override
  void initState() {
    super.initState();
    bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) {
        return;
      }

      final nextIndex = (bannerIndex + 1) % bannerAssets.length;
      bannerController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
      setState(() {
        bannerIndex = nextIndex;
      });
    });
  }

  @override
  void dispose() {
    bannerTimer?.cancel();
    bannerController.dispose();
    searchController.dispose();
    super.dispose();
  }

  void filterMotors() {
    List<Motor> filtered = motorList;
    final query = searchController.text.toLowerCase().trim();

    if (query.isNotEmpty) {
      filtered = filtered.where((motor) {
        return motor.name.toLowerCase().contains(query) ||
            motor.brand.toLowerCase().contains(query) ||
            motor.type.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedBrand != 'Semua') {
      filtered = filtered.where((motor) => motor.brand == selectedBrand).toList();
    }

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
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  List<Motor> get wishlistMotors {
    return motorList.where((motor) => widget.appState.isInWishlist(motor.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _surfaceBg,
      bottomNavigationBar: _modernNavBar(),
      body: SafeArea(
        child: IndexedStack(
          index: selectedTab,
          children: [
            _buildHomeTab(),
            _buildCatalogTab(),
            _buildWishlistTab(),
            _buildProfileTab(),
          ],
        ),
      ),
    );
  }

  Widget _homePromoCard() {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF0EA5E9)],
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Promo hari ini',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'DP ringan, cicilan aman, dan banyak pilihan motor.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: const [
                      _PromoPill(text: 'Honda'),
                      _PromoPill(text: 'Yamaha'),
                      _PromoPill(text: 'Leasing'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/banner/banner_service.png',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _homeBrandCards() {
    return Row(
      children: [
        Expanded(
          child: _brandSummaryCard(
            title: 'Honda',
            subtitle: '5 motor',
            logoPath: 'assets/images/logos/Honda.webp',
            tint: const Color(0xFFFEE2E2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _brandSummaryCard(
            title: 'Yamaha',
            subtitle: '5 motor',
            logoPath: 'assets/images/logos/yamaha.webp',
            tint: const Color(0xFFE0F2FE),
          ),
        ),
      ],
    );
  }

  Widget _brandSummaryCard({
    required String title,
    required String subtitle,
    required String logoPath,
    required Color tint,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tint, Colors.white],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(logoPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[700],
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

  Widget _buildHomeTab() {
    final user = widget.appState.currentUser;
    final featuredMotors = motorList.take(4).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _compactHeader(
          title: 'SRB Motor',
          subtitle: 'Halo, ${user?.name ?? 'User'}',
          logoPath: 'assets/images/logos/logo_srb.webp',
        ),
        const SizedBox(height: 16),
        _bannerSlider(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _statCard(
                title: 'Katalog',
                value: '${motorList.length}',
                icon: Icons.two_wheeler_outlined,
                tint: const Color(0xFFDBEAFE),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Wishlist',
                value: '${widget.appState.wishlist.length}',
                icon: Icons.favorite_border,
                tint: const Color(0xFFFCE7F3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _statCard(
                title: 'Brand',
                value: '${getBrands().length}',
                icon: Icons.category_outlined,
                tint: const Color(0xFFE0E7FF),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _homePromoCard(),
        const SizedBox(height: 12),
        _homeBrandCards(),
        const SizedBox(height: 12),
        _sectionHeader(
          title: 'Akses cepat',
          subtitle: 'Buka fitur utama dengan satu tap.',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _quickAction(
                title: 'Katalog',
                iconPath: 'assets/images/icon_nav_catalog.png',
                onTap: () => setState(() => selectedTab = 1),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                title: 'Wishlist',
                icon: Icons.favorite,
                onTap: () => setState(() => selectedTab = 2),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _quickAction(
                title: 'Profil',
                iconPath: 'assets/images/icon_nav_profile.png',
                onTap: () => setState(() => selectedTab = 3),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          title: 'Rekomendasi',
          subtitle: 'Pilihan motor yang tampil enak dilihat.',
          actionLabel: 'Lihat semua',
          onActionTap: () => setState(() => selectedTab = 1),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 260,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: featuredMotors.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final motor = featuredMotors[index];
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
                onTap: () => _openDetail(motor),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCatalogTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _compactHeader(
          title: 'Katalog',
          subtitle: 'Honda dan Yamaha dalam satu tampilan.',
          logoPath: 'assets/images/logos/logo_srb.webp',
        ),
        const SizedBox(height: 16),
        _filterPanel(),
        const SizedBox(height: 8),
        if (filteredMotors.isEmpty)
          _emptyState(
            icon: Icons.search_off,
            title: 'Motor tidak ditemukan',
            subtitle: 'Coba ganti kata pencarian atau filter yang dipakai.',
          )
        else
          ...filteredMotors.map((motor) {
            final isWishlisted = widget.appState.isInWishlist(motor.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: MotorCard(
                motor: motor,
                isWishlisted: isWishlisted,
                formatPrice: formatPrice,
                onWishlistToggle: () async {
                  await widget.appState.toggleWishlist(motor.id);
                  if (mounted) {
                    setState(() {});
                  }
                },
                onTap: () => _openDetail(motor),
              ),
            );
          }),
      ],
    );
  }

  Widget _buildWishlistTab() {
    if (wishlistMotors.isEmpty) {
      return _emptyState(
        icon: Icons.favorite_border,
        title: 'Wishlist kosong',
        subtitle: 'Simpan motor favorit supaya gampang dibuka lagi.',
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _compactHeader(
          title: 'Wishlist',
          subtitle: 'Simpan motor favorit Anda.',
          logoPath: 'assets/images/logos/logo_srb.webp',
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          title: 'Wishlist',
          subtitle: 'Motor yang sudah Anda simpan.',
        ),
        const SizedBox(height: 12),
        ...wishlistMotors.map((motor) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MotorCard(
              motor: motor,
              isWishlisted: true,
              formatPrice: formatPrice,
              onWishlistToggle: () async {
                await widget.appState.toggleWishlist(motor.id);
                if (mounted) {
                  setState(() {});
                }
              },
              onTap: () => _openDetail(motor),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildProfileTab() {
    final user = widget.appState.currentUser;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _compactHeader(
          title: 'Profil',
          subtitle: 'Akun dan pengaturan singkat.',
          logoPath: 'assets/images/logos/logo_srb.webp',
        ),
        const SizedBox(height: 16),
        _sectionHeader(
          title: 'Profil',
          subtitle: 'Data akun dan aksi utama.',
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: const Color(0xFFDBEAFE),
                  child: Text(
                    (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _brandBlue,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  user?.name ?? 'User',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '-',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _infoTile('Email', user?.email ?? '-'),
        _infoTile('Telepon', user?.phone ?? '-'),
        _infoTile('Wishlist', '${widget.appState.wishlist.length} motor'),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () async {
              await widget.appState.logout();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color tint,
  }) {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [tint, Colors.white],
          ),
        ),
        child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: _brandBlue, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _quickAction({
    required String title,
    IconData? icon,
    String? iconPath,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Card(
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FAFC), Color(0xFFEFF6FF)],
            ),
          ),
          child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
          child: Column(
            children: [
              if (iconPath != null)
                Image.asset(iconPath, width: 28, height: 28)
              else
                Icon(icon, color: _brandBlue),
              const SizedBox(height: 10),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }

  Widget _sectionHeader({
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
        if (actionLabel != null && onActionTap != null)
          TextButton(
            onPressed: onActionTap,
            child: Text(actionLabel),
          ),
      ],
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodyMedium),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: const Color(0xFFDBEAFE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: _brandBlue, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _compactHeader({
    required String title,
    required String subtitle,
    required String logoPath,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Image.asset(logoPath, fit: BoxFit.contain),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _textDark,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
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

  Widget _bannerSlider() {
    return Card(
      child: SizedBox(
        height: 180,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              PageView.builder(
                controller: bannerController,
                itemCount: bannerAssets.length,
                onPageChanged: (index) {
                  setState(() {
                    bannerIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Image.asset(
                    bannerAssets[index],
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.40),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Promo & pilihan terbaik',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: List.generate(bannerAssets.length, (index) {
                        final active = bannerIndex == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(left: 4),
                          width: active ? 16 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: active ? Colors.white : Colors.white54,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterPanel() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFFFFF), Color(0xFFEFF6FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tune, color: _brandBlue, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter katalog',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'Honda dan Yamaha',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: searchController,
              onChanged: (_) => filterMotors(),
              decoration: const InputDecoration(
                hintText: 'Cari motor, brand, atau tipe',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Semua', 'Honda', 'Yamaha'].map((brand) {
                return ChoiceChip(
                  label: Text(brand),
                  selected: selectedBrand == brand,
                  selectedColor: const Color(0xFF2563EB),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedBrand == brand ? Colors.white : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedBrand = brand;
                    });
                    filterMotors();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['Semua', ...getTypes()].map((type) {
                return ChoiceChip(
                  label: Text(type),
                  selected: selectedType == type,
                  selectedColor: const Color(0xFF1D4ED8),
                  backgroundColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selectedType == type ? Colors.white : Colors.grey[800],
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedType = type;
                    });
                    filterMotors();
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Ditemukan ${filteredMotors.length} motor',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                      ),
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
    ),
  );
}

  Widget _modernNavBar() {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A0F172A),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _navItem(
                index: 0,
                label: 'Home',
                iconPath: 'assets/images/logos/logo_srb.webp',
              ),
            ),
            Expanded(
              child: _navItem(
                index: 1,
                label: 'Katalog',
                iconPath: 'assets/images/icon_nav_catalog.png',
              ),
            ),
            Expanded(
              child: _navItem(
                index: 2,
                label: 'Wishlist',
                iconPath: 'assets/images/icon_nav_service.png',
              ),
            ),
            Expanded(
              child: _navItem(
                index: 3,
                label: 'Profil',
                iconPath: 'assets/images/icon_nav_profile.png',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required String label,
    required String iconPath,
  }) {
    final active = selectedTab == index;
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFEFF6FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 34,
              height: 34,
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: active ? _brandBlue : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Image.asset(
                iconPath,
                fit: BoxFit.contain,
                color: active && iconPath != 'assets/images/logos/logo_srb.webp'
                    ? Colors.white
                    : null,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: active ? _brandBlue : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetail(Motor motor) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MotorDetailScreen(
          motor: motor,
          appState: widget.appState,
          formatPrice: formatPrice,
        ),
      ),
    );
    if (mounted) {
      setState(() {});
    }
  }
}

class MotorCard extends StatelessWidget {
  final Motor motor;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  final String Function(double price) formatPrice;

  const MotorCard({
    super.key,
    required this.motor,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _motorImage(height: 110, width: 110),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                motor.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${motor.brand} • ${motor.type}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey[600],
                                    ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: onWishlistToggle,
                          icon: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? Colors.red : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatPrice(motor.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _brandBlue,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _miniChip('${motor.engineCC} cc'),
                        const SizedBox(width: 8),
                        _miniChip(motor.transmission),
                        const SizedBox(width: 8),
                        _miniChip('${motor.weight} kg'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _motorImage({required double height, required double width}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFF1F5F9),
        child: Image.asset(
          motor.imagePath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Icon(Icons.two_wheeler, size: 42, color: Colors.grey),
            );
          },
        ),
      ),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _brandBlue),
      ),
    );
  }
}

class FeaturedMotorCard extends StatelessWidget {
  final Motor motor;
  final bool isWishlisted;
  final VoidCallback onWishlistToggle;
  final VoidCallback onTap;
  final String Function(double price) formatPrice;

  const FeaturedMotorCard({
    super.key,
    required this.motor,
    required this.isWishlisted,
    required this.onWishlistToggle,
    required this.onTap,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: SizedBox(
        width: 220,
        child: Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    child: Image.asset(
                      motor.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Center(
                            child: Icon(Icons.two_wheeler, size: 48, color: Colors.grey),
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: onWishlistToggle,
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      motor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      motor.type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      formatPrice(motor.price),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _brandBlue,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MotorDetailScreen extends StatelessWidget {
  final Motor motor;
  final AppState appState;
  final String Function(double price) formatPrice;

  const MotorDetailScreen({
    super.key,
    required this.motor,
    required this.appState,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isWishlisted = appState.isInWishlist(motor.id);

    return Scaffold(
      backgroundColor: _surfaceBg,
      appBar: AppBar(
        title: const Text('Detail Motor'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SizedBox(
              height: 260,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Image.asset(
                        motor.imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Center(
                              child: Icon(Icons.two_wheeler, size: 84, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    right: 14,
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      child: IconButton(
                        onPressed: () async {
                          await appState.toggleWishlist(motor.id);
                        },
                        icon: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          color: isWishlisted ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${motor.brand} • ${motor.type}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    formatPrice(motor.price),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: _brandBlue,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Deskripsi'),
                  const SizedBox(height: 8),
                  Text(motor.description),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Spesifikasi'),
                  const SizedBox(height: 12),
                  _specRow('Tahun', motor.year.toString()),
                  _specRow('Transmisi', motor.transmission),
                  _specRow('Mesin', '${motor.engineCC} cc'),
                  _specRow('Berat', '${motor.weight} kg'),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Warna'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: motor.colors
                        .map(
                          (color) => Chip(
                            label: Text(color),
                            backgroundColor: const Color(0xFFEFF6FF),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Hubungi dealer untuk info lebih lanjut'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brandBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                      child: const Text(
                        'Hubungi Dealer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
    );
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PromoPill extends StatelessWidget {
  final String text;

  const _PromoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
