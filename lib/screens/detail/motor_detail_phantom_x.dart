import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/screens/detail/motor_compare_screen.dart';

// Mock Motor instance specifically for Phantom X as designed in Stitch
final Motor phantomXMotor = Motor(
  id: 99,
  name: 'Phantom X',
  brand: 'SRB',
  type: 'Sport Cruiser',
  price: 45000000,
  imagePath: 'assets/images/banner/banner.webp',
  year: 2024,
  transmission: '6-Speed Manual',
  engineCC: 250,
  weight: 168,
  colors: ['Black Metallic', 'Matte Grey'],
  description: 'Experience unparalleled precision engineering. The Phantom X redefines modern urban mobility with a meticulously crafted chassis, advanced aerodynamics, and a powertrain designed for both raw performance and refined control. Simplicity meets high-end capability.',
);

class MotorDetailPhantomXScreen extends StatefulWidget {
  final AppState appState;

  const MotorDetailPhantomXScreen({super.key, required this.appState});

  @override
  State<MotorDetailPhantomXScreen> createState() => _MotorDetailPhantomXScreenState();
}

class _MotorDetailPhantomXScreenState extends State<MotorDetailPhantomXScreen> {
  int activeTab = 0; // 0: Spesifikasi, 1: Fitur
  bool isCalculatorOpen = true;
  double dpPercent = 20.0;
  int selectedTenor = 23; // Default 23 months as per design
  final List<int> tenors = const [11, 23, 35, 47];

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  String formatFullCurrency(double amount) {
    // Format full rupiah currency, e.g. Rp 9.000.000
    final buffer = StringBuffer('Rp ');
    final str = amount.toInt().toString();
    int len = str.length;
    for (int i = 0; i < len; i++) {
      buffer.write(str[i]);
      if ((len - i - 1) % 3 == 0 && i != len - 1) {
        buffer.write('.');
      }
    }
    return buffer.toString();
  }

  double get monthlyInstallment {
    final price = phantomXMotor.price;
    final dpAmount = price * (dpPercent / 100);
    final loanAmount = price - dpAmount;
    const annualInterestRate = 0.08; // 8% simple interest per year
    final totalInterest = loanAmount * annualInterestRate * (selectedTenor / 12);
    final totalPayable = loanAmount + totalInterest;
    return totalPayable / selectedTenor;
  }

  void _showCompareSelection(BuildContext context) {
    final otherMotors = motorList.where((m) => m.id != phantomXMotor.id).toList();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pilih Motor Pembanding',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF041627),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: otherMotors.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final other = otherMotors[index];
                    return ListTile(
                      leading: SizedBox(
                        width: 50,
                        child: Image.asset(
                          other.imagePath,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.two_wheeler),
                        ),
                      ),
                      title: Text(
                        other.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF041627)),
                      ),
                      subtitle: Text('${other.brand} • ${formatPrice(other.price)}'),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MotorCompareScreen(
                              motor1: phantomXMotor,
                              motor2: other,
                              formatPrice: formatPrice,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWishlisted = widget.appState.isInWishlist(phantomXMotor.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // bg-background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF041627)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Detail Motor',
          style: TextStyle(color: Color(0xFF041627), fontWeight: FontWeight.w700),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 100.0),
            children: [
              // Product Image Display
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SizedBox(
                  height: 240,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            phantomXMotor.imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(Icons.two_wheeler, size: 84, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Material(
                          color: Colors.white.withValues(alpha: 0.8),
                          shape: const CircleBorder(),
                          child: IconButton(
                            icon: Icon(
                              isWishlisted ? Icons.favorite : Icons.favorite_border,
                              color: isWishlisted ? Colors.red : const Color(0xFF5F5E5E),
                            ),
                            onPressed: () async {
                              await widget.appState.toggleWishlist(phantomXMotor.id);
                              if (mounted) {
                                setState(() {});
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Brand & Name & Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          phantomXMotor.type.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF041627),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      Text(
                        formatFullCurrency(phantomXMotor.price),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF041627),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        phantomXMotor.name,
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF041627),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _showCompareSelection(context),
                        icon: const Icon(Icons.compare_arrows, size: 18),
                        label: const Text(
                          'BANDINGKAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF2563EB),
                          side: const BorderSide(color: Color(0xFF2563EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Description
                  Text(
                    phantomXMotor.description,
                    style: const TextStyle(
                      fontFamily: 'Work Sans',
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF5F5E5E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Specs / Features Tab Control
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2))),
                ),
                child: Row(
                  children: [
                    _buildTabButton('Spesifikasi', 0),
                    const SizedBox(width: 24),
                    _buildTabButton('Fitur', 1),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Tab contents
              if (activeTab == 0) _buildSpecsList() else _buildFeaturesList(),
              const SizedBox(height: 24),
              // Credit Calculator Expansion Area
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Color(0xFFE2E2E2)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calculate, color: Color(0xFF041627)),
                      title: const Text(
                        'Kalkulator Kredit',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: Color(0xFF041627),
                        ),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isCalculatorOpen ? Icons.expand_less : Icons.expand_more,
                          color: const Color(0xFF5F5E5E),
                        ),
                        onPressed: () {
                          setState(() {
                            isCalculatorOpen = !isCalculatorOpen;
                          });
                        },
                      ),
                    ),
                    if (isCalculatorOpen)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(color: Color(0xFFE2E2E2)),
                            const SizedBox(height: 12),
                            // DP Slider Label
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Uang Muka (DP)',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF5F5E5E),
                                    letterSpacing: 1.0,
                                  ),
                                ),
                                Text(
                                  '${formatFullCurrency(phantomXMotor.price * (dpPercent / 100))} (${dpPercent.toInt()}%)',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF041627),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // DP Slider
                            Slider(
                              value: dpPercent,
                              min: 10,
                              max: 50,
                              divisions: 8, // 10%, 15%, 20%, 25%, 30%, 35%, 40%, 45%, 50%
                              activeColor: const Color(0xFF041627),
                              inactiveColor: const Color(0xFFE2E2E2),
                              onChanged: (val) {
                                setState(() {
                                  dpPercent = val;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            // Tenor Title
                            const Text(
                              'Tenor (Bulan)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF5F5E5E),
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 12),
                            // Tenor Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: tenors.map((tenor) {
                                final isSelected = selectedTenor == tenor;
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          selectedTenor = tenor;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: isSelected
                                            ? const Color(0xFF041627)
                                            : Colors.transparent,
                                        side: BorderSide(
                                          color: isSelected
                                              ? const Color(0xFF041627)
                                              : const Color(0xFFC4C6CD),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: Text(
                                        '$tenor',
                                        style: TextStyle(
                                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                          color: isSelected ? Colors.white : const Color(0xFF5F5E5E),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 24),
                            // Estimation Result Container
                            Container(
                              padding: const EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F3F3), // bg-surface-container
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Estimasi Cicilan/Bulan',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5F5E5E),
                                    ),
                                  ),
                                  Text(
                                    formatFullCurrency(monthlyInstallment),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF041627),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '*Simulasi dapat berubah sewaktu-waktu',
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF5F5E5E),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Sticky Bottom WhatsApp Action Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.95),
                border: const Border(top: BorderSide(color: Color(0xFFE2E2E2))),
              ),
              child: SizedBox(
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pemesanan dikirim ke WhatsApp dealer...')),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble, color: Colors.white, size: 20),
                  label: const Text(
                    'PESAN LEWAT WHATSAPP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF25D366), // WhatsApp Green
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26), // pill shape as per design
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF25D366).withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index) {
    final isSelected = activeTab == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          activeTab = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? const Color(0xFF041627) : Colors.transparent,
              width: 2.0,
            ),
          ),
        ),
        child: Text(
          label.toUpperCase(),
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? const Color(0xFF041627) : const Color(0xFF5F5E5E),
            fontSize: 12,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSpecsList() {
    return Column(
      children: [
        _buildSpecRow('Mesin', '250cc, Liquid Cooled DOHC'),
        _buildSpecRow('Tenaga Maksimal', '38.2 HP @ 12,000 rpm'),
        _buildSpecRow('Torsi Maksimal', '23.3 Nm @ 10,000 rpm'),
        _buildSpecRow('Transmisi', '6-Speed Manual'),
        _buildSpecRow('Berat Isi', '168 kg'),
        _buildSpecRow('Kapasitas Tangki', '14 Liter'),
      ],
    );
  }

  Widget _buildFeaturesList() {
    return Column(
      children: [
        _buildSpecRow('Sistem Pengereman', 'ABS Dual Channel'),
        _buildSpecRow('Kontrol Traksi', 'Traction Control System (TCS)'),
        _buildSpecRow('Pencahayaan', 'Full LED Projector Lighting'),
        _buildSpecRow('Kunci Kontak', 'Smart Key System (Keyless)'),
        _buildSpecRow('Speedometer', 'Full Digital TFT Color Panel'),
      ],
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 8.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E2E2), width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF5F5E5E), fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF041627), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
