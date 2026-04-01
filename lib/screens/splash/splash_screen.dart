import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const SplashScreen({super.key, required this.onGetStarted});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Premium\nMotorcycle\nExperience.',
      description: 'Layanan jual beli motor premium dengan kualitas terbaik dan terpercaya di Indonesia.',
      image: 'assets/images/logos/logo_srb.png',
      isLogo: true,
    ),
    OnboardingData(
      title: 'Koleksi\nTerlengkap & Terpilih.',
      description: 'Temukan berbagai pilihan motor dari brand ternama dengan kondisi yang sudah terverifikasi.',
      icon: Icons.motorcycle_rounded,
      isLogo: false,
    ),
    OnboardingData(
      title: 'Proses\nKredit Cepat & Mudah.',
      description: 'Bekerjasama dengan partner leasing terpercaya untuk kemudahan transaksi Anda.',
      icon: Icons.verified_user_rounded,
      isLogo: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Dynamic Gradient Background
          Positioned.fill(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getBackgroundColors(_currentPage),
                ),
              ),
            ),
          ),
          
          // Floating background elements for "life"
          Positioned(
            top: -100,
            right: -100,
            child: _buildBackgroundCircle(200, Colors.white.withValues(alpha: 0.05)),
          ),
          Positioned(
            bottom: 100,
            left: -50,
            child: _buildBackgroundCircle(150, Colors.blue.withValues(alpha: 0.1)),
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return OnboardingPage(data: _onboardingData[index]);
                    },
                  ),
                ),
                
                // Bottom Section: Indicators and Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildIndicator(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Action Button
                      _buildActionButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _getBackgroundColors(int page) {
    switch (page) {
      case 0:
        return [const Color(0xFF0F172A), const Color(0xFF1E293B)];
      case 1:
        return [const Color(0xFF1E3A8A), const Color(0xFF0F172A)];
      case 2:
        return [const Color(0xFF1E40AF), const Color(0xFF1E293B)];
      default:
        return [const Color(0xFF0F172A), const Color(0xFF1E293B)];
    }
  }

  Widget _buildBackgroundCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 32 : 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildActionButton() {
    bool isLastPage = _currentPage == _onboardingData.length - 1;
    
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            widget.onGetStarted();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'Mulai Sekarang' : 'Lanjutkan',
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isLastPage ? Icons.check_circle_outline : Icons.arrow_forward_rounded,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingData data;

  const OnboardingPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          
          // Image or Icon
          if (data.isLogo)
            Image.asset(
              data.image!,
              height: 120,
              errorBuilder: (context, error, stackTrace) => const Icon(
                Icons.motorcycle,
                size: 100,
                color: Colors.white,
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                data.icon,
                size: 80,
                color: Colors.white,
              ),
            ),
          
          const SizedBox(height: 48),
          
          // Text Content
          Text(
            data.title,
            style: GoogleFonts.outfit(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              height: 1.1,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.description,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: Colors.white.withValues(alpha: 0.7),
              height: 1.6,
            ),
          ),
          
          const Spacer(),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String description;
  final String? image;
  final IconData? icon;
  final bool isLogo;

  OnboardingData({
    required this.title,
    required this.description,
    this.image,
    this.icon,
    required this.isLogo,
  });
}
