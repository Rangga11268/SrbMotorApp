import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/motor_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_config.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../models/motor.dart';
import '../order_form/order_form_screen.dart';

class MotorDetailScreen extends StatefulWidget {
  final Motor motor;
  const MotorDetailScreen({super.key, required this.motor});

  @override
  State<MotorDetailScreen> createState() => _MotorDetailScreenState();
}

class _MotorDetailScreenState extends State<MotorDetailScreen> {
  int _selectedTenor = 36;
  late double _dpAmount;
  final currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    // Default DP is 20% of price
    _dpAmount = widget.motor.price * 0.2;
  }

  double get _monthlyInstallment {
    final principal = widget.motor.price - _dpAmount;
    if (principal <= 0) return 0;

    const interestRate = 0.015; // 1.5% Flat
    final totalInterest = principal * interestRate * _selectedTenor;
    return (principal + totalInterest) / _selectedTenor;
  }

  void _launchWhatsApp() async {
    final phone = context.read<MotorProvider>().contactPhone;
    final message = Uri.encodeComponent(
      'Halo SRB Motor (Dealer SSM), saya tertarik dengan unit ${widget.motor.name} (${currencyFormat.format(widget.motor.price)}). Bisa minta info lebih lanjut?',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchWhatsAppCredit() async {
    final phone = context.read<MotorProvider>().contactPhone;
    final message = Uri.encodeComponent(
      'Halo SRB Motor, saya ingin tanya info pengajuan KREDIT untuk unit ${widget.motor.name} (${currencyFormat.format(widget.motor.price)}). Boleh dibantu?',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _launchWebCredit() async {
    final url = Uri.parse('https://srbmotor.test/motors/${widget.motor.id}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // Header with Image
          SliverAppBar(
            expandedHeight: 350,
            pinned: true,
            backgroundColor: const Color(0xFF2563EB),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withAlpha(230),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black87),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withAlpha(230),
                  child: IconButton(
                    icon: const Icon(Icons.favorite_border, color: Colors.red),
                    onPressed: () {},
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: const Color(0xFFF1F5F9),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (widget.motor.imagePath != null)
                      CachedNetworkImage(
                        imageUrl: ApiConfig.sanitizeUrl(
                          widget.motor.imagePath!,
                        )!,
                        httpHeaders: ApiConfig.ngrokHeaders,
                        fit: BoxFit.cover,
                        errorWidget: (context, url, error) =>
                            _buildPlaceholder(),
                      )
                    else
                      _buildPlaceholder(),
                    // Gradient overlay for better text contrast
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(102),
                            Colors.transparent,
                            Colors.black.withAlpha(13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & Price
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.motor.brand.toUpperCase(),
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: widget.motor.tersedia
                              ? const Color(0xFFDCFCE7)
                              : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.motor.tersedia ? 'Tersedia' : 'Sudah Dipesan',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: widget.motor.tersedia
                                ? const Color(0xFF166534)
                                : const Color(0xFF991B1B),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.motor.type != null)
                        Text(
                          widget.motor.type!,
                          style: GoogleFonts.inter(
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.motor.name,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(widget.motor.price),
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Specifications Grid
                  Text(
                    'Spesifikasi Utama',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecGrid(),

                  const SizedBox(height: 32),

                  // Credit Simulation
                  _buildCreditSimulator(),

                  const SizedBox(height: 16),

                  // ── Banner Kredit Coming Soon ──
                  _buildCreditComingSoonBanner(),

                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'Deskripsi Unit',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  HtmlWidget(
                    widget.motor.details ??
                        'Unit motor premium dengan kondisi terbaik.',
                    textStyle: GoogleFonts.inter(
                      fontSize: 16,
                      color: const Color(0xFF64748B),
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Financing Partners (from DB)
                  _buildFinancingPartners(),

                  const SizedBox(height: 32),

                  // Benefits
                  _buildBenefits(),

                  const SizedBox(height: 32),

                  // Related Motors
                  _buildRelatedMotors(),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Opacity(
        opacity: 0.1,
        child: Image.asset('assets/images/logos/logo_srb.webp', width: 200),
      ),
    );
  }

  String _getColorsDisplay() {
    if (widget.motor.colors == null) return 'Beragam';
    if (widget.motor.colors is List) {
      if ((widget.motor.colors as List).isEmpty) return 'Beragam';
      return (widget.motor.colors as List).join(', ');
    }
    return widget.motor.colors.toString();
  }

  Widget _buildSpecGrid() {
    final specs = [
      {
        'icon': Icons.calendar_today_outlined,
        'label': 'Tahun',
        'value': widget.motor.year.toString(),
      },
      {
        'icon': Icons.palette_outlined,
        'label': 'Warna',
        'value': _getColorsDisplay(),
      },
      {
        'icon': Icons.settings_outlined,
        'label': 'Transmisi',
        'value': widget.motor.type?.toLowerCase().contains('matic') ?? false
            ? 'Matic'
            : 'Manual',
      },
      {
        'icon': Icons.verified_user_outlined,
        'label': 'Status',
        'value': widget.motor.tersedia ? 'Tersedia' : 'Terjual',
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: specs.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              Icon(
                specs[index]['icon'] as IconData,
                size: 20,
                color: const Color(0xFF2563EB),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      specs[index]['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: const Color(0xFF64748B),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      specs[index]['value'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCreditSimulator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withAlpha(51),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SIMULASI KREDIT',
                style: GoogleFonts.inter(
                  color: Colors.blue[100],
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[500]!.withAlpha(51),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ESTIMASI',
                  style: GoogleFonts.inter(
                    color: Colors.blue[200],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Uang Muka (DP)',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2563EB),
              inactiveTrackColor: const Color(0xFF334155),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF2563EB).withAlpha(51),
            ),
            child: Slider(
              value: _dpAmount,
              min: widget.motor.price * 0.1,
              max: widget.motor.price * 0.8,
              onChanged: (val) => setState(() => _dpAmount = val),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormat.format(_dpAmount),
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Min 10%',
                style: GoogleFonts.inter(
                  color: const Color(0xFF64748B),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tenor (Bulan)',
            style: GoogleFonts.inter(
              color: const Color(0xFF64748B),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [12, 24, 36].map((tenor) {
              final isSelected = _selectedTenor == tenor;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _selectedTenor = tenor),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withAlpha(102),
                                  blurRadius: 10,
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          '$tenor bln',
                          style: GoogleFonts.inter(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Column(
              children: [
                Text(
                  'ANGSURAN / BULAN',
                  style: GoogleFonts.inter(
                    color: Colors.blue[200],
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_monthlyInstallment),
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '*Bunga Flat 1.5% - OTR Bekasi',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditComingSoonBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4C1D95), Color(0xFF7C3AED)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withAlpha(60),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.description_outlined, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Cicilan Kredit',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber[400],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Web Only',
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Fitur kredit belum tersedia di App. Ajukan melalui website resmi SRB Motor.',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withAlpha(200),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    GestureDetector(
                      onTap: _launchWebCredit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.open_in_browser, size: 14, color: Color(0xFF7C3AED)),
                            const SizedBox(width: 6),
                            Text(
                              'Ajukan di Website',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF7C3AED),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _launchWhatsAppCredit,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF25D366),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white),
                            const SizedBox(width: 6),
                            Text(
                              'Tanya via WA',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {
        'icon': Icons.verified_user_outlined,
        'title': 'Garansi Mesin',
        'desc': 'Jaminan 1 tahun unit',
      },
      {
        'icon': Icons.description_outlined,
        'title': 'Surat Lengkap',
        'desc': 'STNK & BPKB ready',
      },
      {
        'icon': Icons.build_outlined,
        'title': 'Full Service',
        'desc': 'Gratis servis pertama',
      },
    ];

    return Column(
      children: benefits
          .map(
            (b) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      b['icon'] as IconData,
                      color: const Color(0xFF2563EB),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b['title'] as String,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        b['desc'] as String,
                        style: GoogleFonts.outfit(
                          color: const Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildFinancingPartners() {
    final providers = context.watch<MotorProvider>().leasingProviders;
    if (providers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Partner Pembiayaan',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: providers.map((p) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (p['logoUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Image.asset(
                        p['logoUrl']!,
                        width: 32,
                        height: 32,
                        errorBuilder: (c, e, s) => const SizedBox.shrink(),
                      ),
                    )
                  else
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_outlined,
                        size: 18,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  Text(
                    p['name']!,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // WA Button
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  onPressed: _launchWhatsApp,
                  icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
                  tooltip: 'Chat WhatsApp',
                ),
              ),
              const SizedBox(width: 12),
              // Pesan Cash Button
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.motor.tersedia
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  OrderFormScreen(motor: widget.motor),
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.motor.tersedia
                        ? const Color(0xFF2563EB)
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: Text(
                    widget.motor.tersedia ? 'BELI CASH' : 'SUDAH DIPESAN',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Tombol Kredit via Web
          if (widget.motor.tersedia) ...
            [
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _launchWebCredit,
                  icon: const Icon(Icons.open_in_browser, size: 18),
                  label: Text(
                    'AJUKAN KREDIT — Lanjut di Website',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF7C3AED),
                    side: const BorderSide(color: Color(0xFF7C3AED), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildRelatedMotors() {
    final motorProvider = context.watch<MotorProvider>();
    final related = motorProvider.motors
        .where(
          (m) =>
              m.id != widget.motor.id &&
              (m.brand == widget.motor.brand || m.type == widget.motor.type),
        )
        .take(4)
        .toList();

    if (related.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Unit Terkait',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 245, // Slightly increased for better breathability
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: related.length,
            padding: const EdgeInsets.symmetric(vertical: 4),
            itemBuilder: (context, index) {
              final motor = related[index];
              return Container(
                width: 170,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(motor.tersedia ? 13 : 5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: motor.tersedia 
                        ? const Color(0xFFF1F5F9) 
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MotorDetailScreen(motor: motor),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                                child: ColorFiltered(
                                  colorFilter: motor.tersedia
                                      ? const ColorFilter.mode(
                                          Colors.transparent,
                                          BlendMode.multiply,
                                        )
                                      : const ColorFilter.matrix([
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0.2126, 0.7152, 0.0722, 0, 0,
                                          0,      0,      0,      1, 0,
                                        ]),
                                  child: Opacity(
                                    opacity: motor.tersedia ? 1.0 : 0.7,
                                    child: motor.imagePath != null
                                        ? CachedNetworkImage(
                                            imageUrl: ApiConfig.sanitizeUrl(motor.imagePath!)!,
                                            httpHeaders: ApiConfig.ngrokHeaders,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                          )
                                        : const Center(
                                            child: Icon(
                                              Icons.motorcycle,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                            if (!motor.tersedia)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF991B1B).withAlpha(230),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withAlpha(51),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Text(
                                    'STOK HABIS',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.5,
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
                            Text(
                              motor.name,
                              style: GoogleFonts.outfit(
                                fontWeight: motor.tersedia 
                                    ? FontWeight.bold 
                                    : FontWeight.w600,
                                fontSize: 13,
                                color: motor.tersedia 
                                    ? const Color(0xFF1E293B) 
                                    : const Color(0xFF94A3B8),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              currencyFormat.format(motor.price),
                              style: GoogleFonts.outfit(
                                color: motor.tersedia
                                    ? const Color(0xFF16A34A)
                                    : const Color(0xFF94A3B8).withAlpha(128),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                decoration: motor.tersedia
                                    ? null
                                    : TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
