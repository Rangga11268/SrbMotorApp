import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/motor_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../models/motor.dart';
import '../order_form/order_form_screen.dart';
import '../order_form/credit_order_form_screen.dart';
import '../../utils/currency_util.dart';

class MotorDetailScreen extends StatefulWidget {
  final Motor motor;
  const MotorDetailScreen({super.key, required this.motor});

  @override
  State<MotorDetailScreen> createState() => _MotorDetailScreenState();
}

class _MotorDetailScreenState extends State<MotorDetailScreen> {
  int _selectedTenor = 36;
  late double _dpAmount;

  @override
  void initState() {
    super.initState();
    _dpAmount = widget.motor.price * 0.2;
  }

  double get _monthlyInstallment {
    final principal = widget.motor.price - _dpAmount;
    if (principal <= 0) return 0;
    const interestRate = 0.015;
    final totalInterest = principal * interestRate * _selectedTenor;
    return (principal + totalInterest) / _selectedTenor;
  }

  void _launchWhatsApp() async {
    final phone = context.read<MotorProvider>().contactPhone;
    final message = Uri.encodeComponent(
      'Halo SRB Motor, saya tertarik dengan unit ${widget.motor.name} (${CurrencyUtil.format(widget.motor.price)}). Bisa minta info lebih lanjut?',
    );
    final url = Uri.parse('https://wa.me/$phone?text=$message');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 140),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitlePrice(),
                      const SizedBox(height: 28),
                      _buildSectionTitle('Spesifikasi Utama'),
                      const SizedBox(height: 16),
                      _buildSpecBento(),
                      const SizedBox(height: 32),
                      _buildCreditSimulator(),
                      const SizedBox(height: 32),
                      _buildCreditEntry(),
                      const SizedBox(height: 32),
                      _buildSectionTitle('Deskripsi Unit'),
                      const SizedBox(height: 12),
                      _buildDescription(),
                      const SizedBox(height: 32),
                      _buildFinancingPartners(),
                      const SizedBox(height: 32),
                      _buildBenefits(),
                      const SizedBox(height: 32),
                      _buildRelatedMotors(),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: const Color(0xFF0F2249),
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      clipBehavior: Clip.antiAlias,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF0F172A), size: 16),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  colors: [Color(0xFFE2E8F0), Color(0xFFF1F5F9)],
                  center: Alignment.center,
                  radius: 0.8,
                ),
              ),
            ),
            if (widget.motor.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 40, left: 16, right: 16),
                child: CachedNetworkImage(
                  imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                  httpHeaders: ApiConfig.ngrokHeaders,
                  fit: BoxFit.contain,
                  errorWidget: (c, u, e) => _buildPlaceholder(),
                ),
              )
            else
              _buildPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.08),
                    Colors.transparent,
                    Colors.black.withOpacity(0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Opacity(
        opacity: 0.12,
        child: Image.asset('assets/images/logos/logo_srb.webp', width: 180),
      ),
    );
  }

  Widget _buildTitlePrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildBrandTag(),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.motor.name,
          style: GoogleFonts.outfit(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          CurrencyUtil.format(widget.motor.price),
          style: GoogleFonts.outfit(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Harga On The Road (OTR) Jakarta & Sekitarnya',
          style: GoogleFonts.outfit(
            fontSize: 12,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildPromoPill(Icons.local_shipping_outlined, 'Gratis Kirim'),
            const SizedBox(width: 8),
            _buildPromoPill(Icons.security_outlined, 'Garansi Mesin'),
            const SizedBox(width: 8),
            _buildPromoPill(Icons.history_edu_outlined, 'Surat Lengkap'),
          ],
        ),
      ],
    );
  }

  Widget _buildBrandTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Text(
        widget.motor.brand.toUpperCase(),
        style: GoogleFonts.outfit(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1D4ED8),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    final isReady = widget.motor.tersedia;
    final primaryColor = isReady ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bgColor = isReady ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: primaryColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 2,
                )
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isReady ? 'READY STOCK' : 'SOLD OUT',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isReady ? const Color(0xFF047857) : const Color(0xFFB91C1C),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoPill(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: const Color(0xFF64748B)),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF0F172A),
      ),
    );
  }

  Widget _buildSpecBento() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildSpecCard(Icons.calendar_today_rounded, 'Tahun', widget.motor.year.toString())),
            const SizedBox(width: 12),
            Expanded(child: _buildSpecCard(Icons.bolt_rounded, 'Mesin', '${widget.motor.engine ?? 155} cc')),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildSpecCard(Icons.settings_suggest_rounded, 'Tipe', widget.motor.type ?? 'Standard')),
            const SizedBox(width: 12),
            Expanded(child: _buildSpecCard(Icons.palette_rounded, 'Warna', _getColorsDisplay())),
          ],
        ),
        const SizedBox(height: 12),
        _buildSpecCard(
          Icons.location_on_rounded,
          'Lokasi Unit',
          (widget.motor.branch ?? widget.motor.branchCode ?? 'Jakarta')
              .replaceAll('_', ' ')
              .split(' ')
              .map((str) => str.isNotEmpty
                  ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}'
                  : '')
              .join(' '),
        ),
      ],
    );
  }

  Widget _buildSpecCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
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
  }

  String _getColorsDisplay() {
    if (widget.motor.colors == null) return 'Beragam';
    if (widget.motor.colors is List) {
      if ((widget.motor.colors as List).isEmpty) return 'Beragam';
      return (widget.motor.colors as List).join(', ');
    }
    return widget.motor.colors.toString();
  }

  Widget _buildCreditSimulator() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F1F40), Color(0xFF071026)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F1F40).withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
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
                    'SIMULASI KREDIT',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF3B82F6),
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Atur skema pembiayaan unit',
                    style: GoogleFonts.outfit(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.calculate_outlined, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildSliderSection(),
          const SizedBox(height: 24),
          _buildTenorSection(),
          const SizedBox(height: 28),
          _buildInstallmentResult(),
        ],
      ),
    );
  }

  Widget _buildSliderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Uang Muka (DP)',
              style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3), width: 1),
              ),
              child: Text(
                CurrencyUtil.format(_dpAmount),
                style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF3B82F6),
            inactiveTrackColor: Colors.white.withOpacity(0.1),
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF3B82F6).withOpacity(0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
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
              'Min: ${CurrencyUtil.format(widget.motor.price * 0.1)}',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
            ),
            Text(
              'Max: ${CurrencyUtil.format(widget.motor.price * 0.8)}',
              style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTenorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pilih Tenor (Bulan)',
          style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 12),
        Row(
          children: [12, 24, 36].map((t) {
            final isSelected = _selectedTenor == t;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedTenor = t),
                child: Container(
                  margin: EdgeInsets.only(right: t == 36 ? 0 : 8),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF3B82F6) : Colors.white.withOpacity(0.05),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '$t Bulan',
                      style: GoogleFonts.outfit(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInstallmentResult() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(
            'ESTIMASI ANGSURAN',
            style: GoogleFonts.outfit(
              color: const Color(0xFF3B82F6),
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyUtil.format(_monthlyInstallment),
            style: GoogleFonts.outfit(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '*Bunga Flat 1.5% - Simulasi Estimasi',
            style: GoogleFonts.outfit(fontSize: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  Widget _buildCreditEntry() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajukan Kredit Sekarang',
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Proses cepat & syarat mudah langsung dari aplikasi.',
                  style: GoogleFonts.outfit(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.motor.tersedia
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (c) => CreditOrderFormScreen(motor: widget.motor),
                              ),
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF2563EB),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'MULAI PENGAJUAN',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: HtmlWidget(
        widget.motor.details ?? 'Unit motor premium dengan kondisi terbaik.',
        textStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: const Color(0xFF475569),
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildFinancingPartners() {
    final providers = context.watch<MotorProvider>().leasingProviders;
    if (providers.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Partner Leasing'),
        const SizedBox(height: 16),
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            itemBuilder: (c, i) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withOpacity(0.01),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(providers[i]['logoUrl']!, fit: BoxFit.contain, width: 80),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefits() {
    final benefits = [
      {'icon': Icons.verified_rounded, 'title': 'Garansi Resmi', 'desc': 'Jaminan 1 tahun unit'},
      {'icon': Icons.description_rounded, 'title': 'Dokumen Ready', 'desc': 'STNK & BPKB aman'},
    ];
    return Row(
      children: benefits.map((b) {
        final isFirst = b == benefits.first;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: isFirst ? 12 : 0),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.01),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: Color(0xFFEFF6FF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(b['icon'] as IconData, color: const Color(0xFF2563EB), size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  b['title'] as String,
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  b['desc'] as String,
                  style: GoogleFonts.outfit(
                    color: const Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRelatedMotors() {
    final motors = context.watch<MotorProvider>().motors.where((m) => m.id != widget.motor.id).take(4).toList();
    if (motors.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Unit Serupa'),
        const SizedBox(height: 16),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: motors.length,
            itemBuilder: (c, i) => _buildRelatedCard(motors[i]),
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedCard(Motor m) {
    return GestureDetector(
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => MotorDetailScreen(motor: m))),
      child: Container(
        width: 170,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFF1F5F9)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withOpacity(0.02),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  color: const Color(0xFFF8FAFC),
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: ApiConfig.sanitizeUrl(m.imagePath!)!,
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: const Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyUtil.format(m.price),
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
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

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            GestureDetector(
              onTap: _launchWhatsApp,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2), width: 1),
                ),
                child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF10B981)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: widget.motor.tersedia
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (c) => OrderFormScreen(motor: widget.motor),
                          ),
                        )
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 0,
                ),
                child: Text(
                  widget.motor.tersedia ? 'BELI CASH' : 'STOK HABIS',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            if (widget.motor.tersedia) ...[
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (c) => CreditOrderFormScreen(motor: widget.motor),
                        ),
                      ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                  child: Text(
                    'AJUKAN KREDIT',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
