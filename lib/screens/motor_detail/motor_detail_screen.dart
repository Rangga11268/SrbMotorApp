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
import '../order_form/credit_order_form_screen.dart';

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
      'Halo SRB Motor, saya tertarik dengan unit ${widget.motor.name} (${currencyFormat.format(widget.motor.price)}). Bisa minta info lebih lanjut?',
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
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitlePrice(),
                      const SizedBox(height: 32),
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
                      const SizedBox(height: 140),
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
      expandedHeight: 400,
      pinned: true,
      backgroundColor: const Color(0xFF0F2249),
      leading: Padding(
        padding: const EdgeInsets.all(12),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 18),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFFF1F5F9)),
            if (widget.motor.imagePath != null)
              CachedNetworkImage(
                imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                httpHeaders: ApiConfig.ngrokHeaders,
                fit: BoxFit.contain,
                errorWidget: (c, u, e) => _buildPlaceholder(),
              )
            else
              _buildPlaceholder(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.1),
                    Colors.transparent,
                    Colors.black.withOpacity(0.05),
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
    return Center(child: Opacity(opacity: 0.1, child: Image.asset('assets/images/logos/logo_srb.webp', width: 200)));
  }

  Widget _buildTitlePrice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                widget.motor.brand.toUpperCase(),
                style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB)),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: widget.motor.tersedia 
                    ? const Color(0xFF22C55E).withValues(alpha: 0.1) 
                    : const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: widget.motor.tersedia ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: widget.motor.tersedia ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.motor.tersedia ? 'READY STOCK' : 'SOLD OUT',
                    style: GoogleFonts.outfit(
                      fontSize: 10, 
                      fontWeight: FontWeight.w900, 
                      color: widget.motor.tersedia ? const Color(0xFF166534) : const Color(0xFF991B1B),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          widget.motor.name,
          style: GoogleFonts.outfit(fontSize: 34, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), height: 1.1),
        ),
        const SizedBox(height: 8),
        Text(
          currencyFormat.format(widget.motor.price),
          style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
    );
  }

  Widget _buildSpecBento() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.6,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildSpecCard(Icons.calendar_today_rounded, 'Tahun', widget.motor.year.toString()),
        _buildSpecCard(Icons.bolt_rounded, 'Mesin', '${widget.motor.engine ?? 155} cc'),
        _buildSpecCard(Icons.palette_rounded, 'Warna', _getColorsDisplay()),
        _buildSpecCard(Icons.settings_suggest_rounded, 'Tipe', widget.motor.type ?? 'Standard'),
        _buildSpecCard(Icons.location_on_rounded, 'Lokasi', (widget.motor.branch ?? widget.motor.branchCode ?? 'Jakarta')
            .replaceAll('_', ' ')
            .split(' ')
            .map((str) => str.isNotEmpty 
                ? '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}' 
                : '')
            .join(' ')),
      ],
    );
  }

  Widget _buildSpecCard(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF2563EB)),
          const SizedBox(height: 8),
          Text(
            label, 
            style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              value, 
              style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)), 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis
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
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('SIMULASI KREDIT', style: GoogleFonts.outfit(color: Colors.blue[300], fontWeight: FontWeight.w900, letterSpacing: 1.5)),
              const Icon(Icons.calculate_outlined, color: Colors.white24),
            ],
          ),
          const SizedBox(height: 24),
          _buildSliderSection(),
          const SizedBox(height: 24),
          _buildTenorSection(),
          const SizedBox(height: 32),
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
            Text('Uang Muka (DP)', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
            Text(currencyFormat.format(_dpAmount), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF2563EB),
            inactiveTrackColor: Colors.white10,
            thumbColor: Colors.white,
            overlayColor: const Color(0xFF2563EB).withOpacity(0.2),
          ),
          child: Slider(
            value: _dpAmount,
            min: widget.motor.price * 0.1,
            max: widget.motor.price * 0.8,
            onChanged: (val) => setState(() => _dpAmount = val),
          ),
        ),
      ],
    );
  }

  Widget _buildTenorSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pilih Tenor', style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text('$t bln', style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Text('ESTIMASI ANGSURAN', style: GoogleFonts.outfit(color: Colors.blue[300], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text(currencyFormat.format(_monthlyInstallment), style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
          Text('*Flat 1.5% - OTR Bekasi', style: GoogleFonts.outfit(fontSize: 10, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _buildCreditEntry() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.assignment_ind_rounded, color: Colors.blueAccent, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajukan Kredit Sekarang',
                  style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  'Proses cepat & syarat mudah langsung dari aplikasi.',
                  style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
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
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: Text(
                      'MULAI PENGAJUAN',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
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
    return HtmlWidget(
      widget.motor.details ?? 'Unit motor premium dengan kondisi terbaik.',
      textStyle: GoogleFonts.outfit(fontSize: 15, color: const Color(0xFF64748B), height: 1.6),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10))],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _launchWhatsApp,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFF22C55E).withOpacity(0.1), borderRadius: BorderRadius.circular(18)),
              child: const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFF22C55E)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: widget.motor.tersedia ? () => Navigator.push(context, MaterialPageRoute(builder: (c) => OrderFormScreen(motor: widget.motor))) : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
              child: Text(widget.motor.tersedia ? 'BELI CASH SEKARANG' : 'STOK HABIS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1)),
            ),
          ),
        ],
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
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: providers.length,
            itemBuilder: (c, i) => Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Image.asset(providers[i]['logoUrl']!, fit: BoxFit.contain, width: 80),
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
      children: benefits.map((b) => Expanded(
        child: Container(
          margin: EdgeInsets.only(right: b == benefits.first ? 12 : 0),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFF1F5F9))),
          child: Column(
            children: [
              Icon(b['icon'] as IconData, color: const Color(0xFF2563EB)),
              const SizedBox(height: 8),
              Text(b['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(b['desc'] as String, style: GoogleFonts.outfit(color: Colors.grey, fontSize: 10)),
            ],
          ),
        ),
      )).toList(),
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
          height: 220,
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
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFF1F5F9))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: CachedNetworkImage(imageUrl: ApiConfig.sanitizeUrl(m.imagePath!)!, fit: BoxFit.contain, width: double.infinity),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(m.name, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(currencyFormat.format(m.price), style: GoogleFonts.outfit(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
