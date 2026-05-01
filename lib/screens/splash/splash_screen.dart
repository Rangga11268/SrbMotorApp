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
      description: 'Nikmati layanan eksklusif jual beli motor premium dengan standar kualitas tertinggi di Indonesia.',
      image: 'assets/images/logos/logo_srb.webp',
      isLogo: true,
    ),
    OnboardingData(
      title: 'Koleksi\nTerpilih &\nTerverifikasi.',
      description: 'Setiap unit melalui inspeksi ketat untuk menjamin kepuasan dan keamanan berkendara Anda.',
      icon: Icons.motorcycle_rounded,
      isLogo: false,
    ),
    OnboardingData(
      title: 'Kemudahan\nTransaksi &\nKredit.',
      description: 'Proses administrasi yang cepat dan transparan didukung oleh mitra pembiayaan terpercaya.',
      icon: Icons.account_balance_wallet_rounded,
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
              duration: const Duration(milliseconds: 800),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getBackgroundColors(_currentPage),
                ),
              ),
            ),
          ),
          
          // Abstract floating elements
          Positioned(
            top: -50,
            right: -50,
            child: _buildBackgroundCircle(250, Colors.white.withOpacity(0.03)),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: _buildBackgroundCircle(300, Colors.blue.withOpacity(0.05)),
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _onboardingData.length,
                          (index) => _buildIndicator(index == _currentPage),
                        ),
                      ),
                      const SizedBox(height: 48),
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
        return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)]; // Deep Slate to Dark Indigo
      case 1:
        return [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]; // Dark Blue to Slate
      case 2:
        return [const Color(0xFF1E40AF), const Color(0xFF1E1B4B)]; // Blue to Dark Indigo
      default:
        return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)];
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
      height: 6,
      width: isActive ? 40 : 12,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildActionButton() {
    bool isLastPage = _currentPage == _onboardingData.length - 1;
    
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (isLastPage) {
            widget.onGetStarted();
          } else {
            _pageController.nextPage(
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOutQuart,
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isLastPage ? 'Mulai Sekarang' : 'Lanjutkan',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            if (!isLastPage) ...[
              const SizedBox(width: 12),
              const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
            ],
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
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Spacer(flex: 2),
          
          // Image or Icon Container
          Container(
            height: 180,
            alignment: Alignment.centerLeft,
            child: data.isLogo
                ? Hero(
                    tag: 'logo',
                    child: Image.asset(
                      data.image!,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.motorcycle,
                        size: 100,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Icon(
                      data.icon,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
          ),
          
          const SizedBox(height: 60),
          
          // Text Content
          Text(
            data.title,
            style: GoogleFonts.outfit(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              height: 1.1,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            data.description,
            style: GoogleFonts.outfit(
              fontSize: 17,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
              fontWeight: FontWeight.w300,
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
