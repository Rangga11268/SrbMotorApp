import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

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
    final message = Uri.encodeComponent(
      'Halo SRB Motors, saya tertarik dengan unit ${widget.motor.name} (${currencyFormat.format(widget.motor.price)}). Bisa minta info lebih lanjut?',
    );
    final url = Uri.parse('https://wa.me/628978638849?text=$message');
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
                      Image.network(
                        widget.motor.imagePath!,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => _buildPlaceholder(),
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
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.motor.brand.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0369A1),
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (widget.motor.type != null)
                        Text(
                          widget.motor.type!,
                          style: GoogleFonts.outfit(color: Colors.blueGrey, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.motor.name,
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(widget.motor.price),
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Specifications Grid
                  Text(
                    'Spesifikasi Utama',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 16),
                  _buildSpecGrid(),

                  const SizedBox(height: 32),

                  // Credit Simulation
                  _buildCreditSimulator(),

                  const SizedBox(height: 32),

                  // Description
                  Text(
                    'Deskripsi Unit',
                    style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.motor.details ?? 'Unit motor premium dengan kondisi terbaik. Sudah melalui pengecekan menyeluruh oleh teknisi ahli SRB Motor.',
                    style: GoogleFonts.outfit(fontSize: 16, color: const Color(0xFF64748B), height: 1.6),
                  ),

                  const SizedBox(height: 32),

                  // Benefits
                  _buildBenefits(),

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
        child: Image.asset('assets/images/logo_srb.png', width: 200),
      ),
    );
  }

  Widget _buildSpecGrid() {
    final specs = [
      {'icon': Icons.bolt, 'label': 'Engine', 'value': '${widget.motor.engine ?? '-'} cc'},
      {'icon': Icons.settings_outlined, 'label': 'Transmisi', 'value': widget.motor.transmission ?? 'Matic'},
      {'icon': Icons.fitness_center, 'label': 'Berat', 'value': '${widget.motor.weight ?? '-'} kg'},
      {'icon': Icons.category_outlined, 'label': 'Tipe', 'value': widget.motor.type ?? 'Sport'},
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
              Icon(specs[index]['icon'] as IconData, size: 20, color: const Color(0xFF2563EB)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    specs[index]['label'] as String,
                    style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                  ),
                  Text(
                    specs[index]['value'] as String,
                    style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                ],
              )
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
          BoxShadow(color: const Color(0xFF2563EB).withAlpha(51), blurRadius: 20, offset: const Offset(0, 10)),
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
                style: GoogleFonts.outfit(color: Colors.blue[100], fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.blue[500]!.withAlpha(51), borderRadius: BorderRadius.circular(20)),
                child: Text('ESTIMASI', style: GoogleFonts.outfit(color: Colors.blue[200], fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Uang Muka (DP)',
            style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
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
              Text(currencyFormat.format(_dpAmount), style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
              Text('Min 10%', style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 10)),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Tenor (Bulan)',
            style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold),
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
                        color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: isSelected ? [BoxShadow(color: const Color(0xFF2563EB).withAlpha(102), blurRadius: 10)] : null,
                      ),
                      child: Center(
                        child: Text(
                          '$tenor bln',
                          style: GoogleFonts.outfit(
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
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
                  style: GoogleFonts.outfit(color: Colors.blue[200], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 8),
                Text(
                  currencyFormat.format(_monthlyInstallment),
                  style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '*Bunga Flat 1.5% - OTR Bekasi',
                  style: GoogleFonts.outfit(fontSize: 10, color: const Color(0xFF64748B)),
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
      {'icon': Icons.verified_user_outlined, 'title': 'Garansi Mesin', 'desc': 'Jaminan 1 tahun unit'},
      {'icon': Icons.description_outlined, 'title': 'Surat Lengkap', 'desc': 'STNK & BPKB ready'},
      {'icon': Icons.build_outlined, 'title': 'Full Service', 'desc': 'Gratis servis pertama'},
    ];

    return Column(
      children: benefits.map((b) => Container(
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
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(12)),
              child: Icon(b['icon'] as IconData, color: const Color(0xFF2563EB), size: 24),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(b['title'] as String, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(b['desc'] as String, style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 12)),
              ],
            )
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(13), blurRadius: 20, offset: const Offset(0, -10)),
        ],
      ),
      child: Row(
        children: [
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
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderFormScreen(motor: widget.motor),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'PESAN SEKARANG',
                style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
