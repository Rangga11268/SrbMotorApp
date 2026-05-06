import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class OnboardingData {
  final String title;
  final String description;
  final String? image;
  final String? motorImage;
  final bool isLogo;
  final bool showLeasingLogos;

  OnboardingData({
    required this.title,
    required this.description,
    this.image,
    this.motorImage,
    required this.isLogo,
    required this.showLeasingLogos,
  });
}

class SplashScreen extends StatefulWidget {
  final VoidCallback onGetStarted;
  const SplashScreen({super.key, required this.onGetStarted});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isShowingSplash = true; 

  AnimationController? _mainController;
  Animation<double> _fadeAnimation = const AlwaysStoppedAnimation(0.0);
  Animation<double> _scaleAnimation = const AlwaysStoppedAnimation(0.8);

  final List<OnboardingData> _onboardingData = [
    OnboardingData(
      title: 'Premium\nMotorcycle\nExperience.',
      description: 'Nikmati layanan eksklusif jual beli motor premium dengan standar kualitas tertinggi di Indonesia.',
      image: 'assets/images/logos/logo_srb.webp',
      motorImage: 'assets/images/yamaha/nmax_turbo.webp',
      isLogo: true,
      showLeasingLogos: false,
    ),
    OnboardingData(
      title: 'Koleksi\nTerpilih &\nTerverifikasi.',
      description: 'Setiap unit melalui inspeksi ketat untuk menjamin kepuasan dan keamanan berkendara Anda.',
      motorImage: 'assets/images/yamaha/grand_filano.webp',
      isLogo: false,
      showLeasingLogos: false,
    ),
    OnboardingData(
      title: 'Kemudahan\nTransaksi &\nKredit.',
      description: 'Proses administrasi yang cepat didukung oleh mitra pembiayaan resmi dan terpercaya.',
      motorImage: 'assets/images/yamaha/fazzio.webp',
      isLogo: false,
      showLeasingLogos: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!, 
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn)
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController!, 
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutBack)
      ),
    );

    _startSplashSequence();
  }

  void _startSplashSequence() {
    _mainController?.forward();
    Timer(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _isShowingSplash = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _mainController?.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 800),
        child: _isShowingSplash ? _buildTrueSplash() : _buildOnboarding(),
      ),
    );
  }

  Widget _buildTrueSplash() {
    return Container(
      key: const ValueKey('true_splash'),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F172A), Color(0xFF1E1B4B)],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logos/logo_srb.webp',
                    width: 140,
                    errorBuilder: (c, e, s) => const Icon(Icons.motorcycle, size: 80, color: Colors.white),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'SRB MOTOR',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          Positioned(
            bottom: 40,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  Text(
                    'AUTHORIZED DEALER OF',
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.5),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/logos/yamaha.webp', height: 22, color: Colors.white.withOpacity(0.8)),
                      const SizedBox(width: 24),
                      Image.asset('assets/images/logos/Honda.webp', height: 22, color: Colors.white.withOpacity(0.8)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'FINANCING PARTNERS',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.w800,
                      color: Colors.white.withOpacity(0.3),
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildMiniLeasingLogo('assets/images/logos/adira.webp'),
                      const SizedBox(width: 12),
                      _buildMiniLeasingLogo('assets/images/logos/fif.webp'),
                      const SizedBox(width: 12),
                      _buildMiniLeasingLogo('assets/images/logos/baf.webp'),
                      const SizedBox(width: 12),
                      _buildMiniLeasingLogo('assets/images/logos/oto.webp'),
                      const SizedBox(width: 12),
                      _buildMiniLeasingLogo('assets/images/logos/muf.webp'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniLeasingLogo(String path) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Image.asset(path, height: 10, color: Colors.white.withOpacity(0.6)),
    );
  }

  Widget _buildOnboarding() {
    return Stack(
      key: const ValueKey('onboarding'),
      children: [
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
        
        Positioned(
          top: -100,
          right: -100,
          child: _buildBackgroundCircle(400, Colors.white.withOpacity(0.05)),
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
    );
  }

  List<Color> _getBackgroundColors(int page) {
    switch (page) {
      case 0:
        return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)];
      case 1:
        return [const Color(0xFF1E3A8A), const Color(0xFF0F172A)];
      case 2:
        return [const Color(0xFF1E40AF), const Color(0xFF1E1B4B)];
      default:
        return [const Color(0xFF0F172A), const Color(0xFF1E1B4B)];
    }
  }

  Widget _buildBackgroundCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
    final screenHeight = MediaQuery.of(context).size.height;
    // Bulletproof boolean checks
    final bool isLogo = data.isLogo == true;
    final bool showLeasing = data.showLeasingLogos == true;
    
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.05),
            
            Container(
              height: screenHeight * 0.35,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: Stack(
                  children: [
                    if (data.motorImage != null)
                      Positioned.fill(
                        child: Image.asset(
                          data.motorImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(color: Colors.white10),
                        ),
                      ),
                    if (isLogo && data.image != null)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Hero(
                          tag: 'logo',
                          child: Image.asset(
                            data.image!,
                            height: 50,
                            errorBuilder: (c, e, s) => const SizedBox(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: screenHeight * 0.05),
            
            Text(
              data.title,
              style: GoogleFonts.outfit(
                fontSize: screenHeight < 700 ? 32 : 38,
                fontWeight: FontWeight.w800,
                height: 1.1,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              data.description,
              style: GoogleFonts.outfit(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                height: 1.5,
                fontWeight: FontWeight.w300,
              ),
            ),

            if (showLeasing) ...[
              const SizedBox(height: 32),
              Text(
                'MITRA PEMBIAYAAN KAMI',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _buildLeasingIcon('assets/images/logos/adira.webp'),
                  _buildLeasingIcon('assets/images/logos/fif.webp'),
                  _buildLeasingIcon('assets/images/logos/baf.webp'),
                  _buildLeasingIcon('assets/images/logos/oto.webp'),
                  _buildLeasingIcon('assets/images/logos/muf.webp'),
                ],
              ),
            ],
            
            SizedBox(height: screenHeight * 0.05),
          ],
        ),
      ),
    );
  }

  Widget _buildLeasingIcon(String path) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(path, height: 14),
    );
  }
}
