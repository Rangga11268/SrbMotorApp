import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/screens/detail/motor_compare_screen.dart';

class MotorDetailScreen extends StatefulWidget {
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
  State<MotorDetailScreen> createState() => _MotorDetailScreenState();
}

class _MotorDetailScreenState extends State<MotorDetailScreen> {
  double dpPercent = 20.0; // Default to 20% DP as in the web version
  int selectedTenor = 36; // Default to 36 months tenor as in the web version
  final List<int> tenors = const [12, 24, 36]; // Tenors: 12, 24, 36 months

  double get monthlyInstallment {
    final dpAmount = widget.motor.price * (dpPercent / 100);
    final principal = widget.motor.price - dpAmount;
    if (principal <= 0) return 0;
    const interestRate = 0.015; // 1.5% flat interest per month
    final totalInterest = principal * interestRate * selectedTenor;
    return (principal + totalInterest) / selectedTenor;
  }

  String formatFullCurrency(double amount) {
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

  void _showCompareSelection(BuildContext context) {
    final otherMotors = motorList.where((m) => m.id != widget.motor.id).toList();

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
                      subtitle: Text('${other.brand} • ${widget.formatPrice(other.price)}'),
                      onTap: () {
                        Navigator.pop(context); // Close bottom sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MotorCompareScreen(
                              motor1: widget.motor,
                              motor2: other,
                              formatPrice: widget.formatPrice,
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
    final isWishlisted = widget.appState.isInWishlist(widget.motor.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
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
                        widget.motor.imagePath,
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
                          await widget.appState.toggleWishlist(widget.motor.id);
                          setState(() {});
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
                    widget.motor.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.motor.brand} • ${widget.motor.type}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.formatPrice(widget.motor.price),
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF2563EB),
                              fontWeight: FontWeight.w800,
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
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Deskripsi'),
                  const SizedBox(height: 8),
                  Text(widget.motor.description),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Spesifikasi'),
                  const SizedBox(height: 12),
                  _specRow('Tahun', widget.motor.year.toString()),
                  _specRow('Transmisi', widget.motor.transmission),
                  _specRow('Mesin', '${widget.motor.engineCC} cc'),
                  _specRow('Berat', '${widget.motor.weight} kg'),
                  const SizedBox(height: 18),
                  _detailTitle(context, 'Warna'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.motor.colors
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
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pemesanan dikirim ke WhatsApp dealer...'),
                          ),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Credit Simulation Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailTitle(context, 'Simulasi Kredit'),
                  const SizedBox(height: 6),
                  Text(
                    'Estimasi pembiayaan dengan bunga flat 1.5% per bulan.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  // DP Percentage Slider Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Uang Muka (DP): ${dpPercent.toInt()}%',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      Text(
                        formatFullCurrency(widget.motor.price * (dpPercent / 100)),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2563EB),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: dpPercent,
                    min: 10.0,
                    max: 80.0,
                    divisions: 14,
                    label: '${dpPercent.toInt()}%',
                    activeColor: const Color(0xFF2563EB),
                    inactiveColor: const Color(0xFFEFF6FF),
                    onChanged: (value) {
                      setState(() {
                        dpPercent = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  // Tenor Selection
                  const Text(
                    'Pilih Tenor (Bulan)',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: tenors.map((tenor) {
                      final active = selectedTenor == tenor;
                      return ChoiceChip(
                        label: Text('$tenor Bulan'),
                        selected: active,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              selectedTenor = tenor;
                            });
                          }
                        },
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: active ? Colors.white : const Color(0xFF041627),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Monthly Installment Result Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'ESTIMASI ANGSURAN',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          formatFullCurrency(monthlyInstallment),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF041627),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '/ bulan',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
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
