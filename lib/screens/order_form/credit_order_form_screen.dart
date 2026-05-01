import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/motor.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/main_provider.dart';
import '../../providers/motor_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_config.dart';

class CreditOrderFormScreen extends StatefulWidget {
  final Motor motor;
  const CreditOrderFormScreen({super.key, required this.motor});

  @override
  State<CreditOrderFormScreen> createState() => _CreditOrderFormScreenState();
}

class _CreditOrderFormScreenState extends State<CreditOrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;
  late TextEditingController _addressController;
  late TextEditingController _occupationController;
  late TextEditingController _incomeController;
  late TextEditingController _durationController;
  late TextEditingController _dpController;
  final _notesController = TextEditingController();

  String? _selectedColor;
  String? _selectedBranch;
  String _deliveryMethod = 'Ambil di Dealer';
  String _paymentMethod = 'Transfer Bank';
  int _selectedTenor = 36;
  double _dpAmount = 0;
  double _minDP = 0;

  List<String> _availableColors = [];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _emailController = TextEditingController(text: user?.email);
    _nikController = TextEditingController(text: user?.nik);
    _addressController = TextEditingController(text: user?.alamat);
    _occupationController = TextEditingController();
    _incomeController = TextEditingController();
    _durationController = TextEditingController();
    
    _minDP = widget.motor.min_dp_amount ?? (widget.motor.price * 0.2);
    _dpAmount = _minDP;
    _dpController = TextEditingController(text: NumberFormat.decimalPattern('id_ID').format(_dpAmount));
    
    _selectedBranch = widget.motor.branch;

    // Initialize colors
    if (widget.motor.colors is List) {
      _availableColors = List<String>.from(widget.motor.colors);
    } else if (widget.motor.colors != null && widget.motor.colors.toString().isNotEmpty) {
      _availableColors = [widget.motor.colors.toString()];
    }

    if (_availableColors.isEmpty) {
      _availableColors = ['Beragam'];
      _selectedColor = 'Beragam';
    } else if (_availableColors.length == 1) {
      _selectedColor = _availableColors.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _nikController.dispose();
    _addressController.dispose();
    _occupationController.dispose();
    _incomeController.dispose();
    _durationController.dispose();
    _dpController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  double get _monthlyInstallment {
    final loanAmount = widget.motor.price - _dpAmount;
    if (loanAmount <= 0) return 0;
    const interestRate = 0.015; // 1.5% flat
    final totalInterest = loanAmount * interestRate * _selectedTenor;
    return (loanAmount + totalInterest) / _selectedTenor;
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        _showErrorDialog('Silakan pilih cabang terlebih dahulu');
        return;
      }

      if (_dpAmount < _minDP) {
        _showErrorDialog('DP minimal adalah Rp ${NumberFormat.decimalPattern('id_ID').format(_minDP)}');
        return;
      }

      final success = await context.read<OrderProvider>().submitCreditOrder(
            motorId: widget.motor.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            nik: _nikController.text.trim(),
            address: _addressController.text.trim(),
            motorColor: _selectedColor ?? 'Default',
            deliveryMethod: _deliveryMethod,
            paymentMethod: _paymentMethod,
            occupation: _occupationController.text.trim(),
            monthlyIncome: double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0,
            employmentDuration: _durationController.text.trim(),
            dpAmount: _dpAmount,
            tenor: _selectedTenor,
            branch: _selectedBranch,
            email: _emailController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (success && mounted) {
        _showSuccessDialog();
      } else if (!success && mounted) {
        _showErrorDialog(context.read<OrderProvider>().errorMessage ?? 'Gagal membuat pengajuan kredit');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.description_rounded, color: Color(0xFF10B981), size: 50),
              ),
              const SizedBox(height: 24),
              Text(
                'Pengajuan Terkirim!',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 12),
              Text(
                'Pengajuan kredit Anda sedang kami proses. Mohon segera lengkapi dokumen pendukung (KTP, KK, Slip Gaji) di halaman detail pesanan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFF64748B), height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MainProvider>().setSelectedIndex(1);
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('LIHAT STATUS PENGAJUAN', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded, color: Color(0xFFEF4444), size: 40),
              ),
              const SizedBox(height: 16),
              Text('Gagal Mengajukan', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text(message, textAlign: TextAlign.center, style: GoogleFonts.outfit(color: const Color(0xFF64748B))),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('TUTUP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444))),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OrderProvider>().isLoading;
    final motorProvider = context.watch<MotorProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('PENGAJUAN KREDIT', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A), fontSize: 16, letterSpacing: 1)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F172A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMotorSummary(currencyFormat),
                const SizedBox(height: 32),
                
                _buildSectionHeader('SIMULASI KREDIT'),
                const SizedBox(height: 16),
                _buildCreditSimulator(currencyFormat),
                const SizedBox(height: 32),

                _buildSectionHeader('INFORMASI CABANG'),
                const SizedBox(height: 16),
                _buildBranchSelection(motorProvider),
                const SizedBox(height: 32),

                _buildSectionHeader('INFORMASI PRIBADI'),
                const SizedBox(height: 16),
                _buildTextField(_nameController, 'Nama Lengkap', Icons.person_rounded, hint: 'Sesuai KTP'),
                const SizedBox(height: 16),
                _buildTextField(_phoneController, 'WhatsApp', Icons.phone_android_rounded, keyboardType: TextInputType.phone, hint: '0812...'),
                const SizedBox(height: 16),
                _buildTextField(_nikController, 'NIK', Icons.badge_rounded, keyboardType: TextInputType.number, maxLength: 16, hint: '16 digit KTP'),
                const SizedBox(height: 16),
                _buildDropdownColor(),
                const SizedBox(height: 32),

                _buildSectionHeader('INFORMASI PEKERJAAN'),
                const SizedBox(height: 16),
                _buildTextField(_occupationController, 'Pekerjaan', Icons.work_rounded, hint: 'Contoh: Karyawan Swasta'),
                const SizedBox(height: 16),
                _buildTextField(_incomeController, 'Pendapatan per Bulan', Icons.account_balance_wallet_rounded, keyboardType: TextInputType.number, isCurrency: true, hint: 'Rp'),
                const SizedBox(height: 16),
                _buildTextField(_durationController, 'Lama Bekerja', Icons.access_time_rounded, hint: 'Contoh: 2 Tahun'),
                const SizedBox(height: 32),
                
                _buildSectionHeader('PENGIRIMAN'),
                const SizedBox(height: 16),
                _buildToggleSelection(
                  label: 'Metode Penyerahan',
                  options: ['Ambil di Dealer', 'Kirim ke Rumah'],
                  currentValue: _deliveryMethod,
                  onChanged: (val) => setState(() => _deliveryMethod = val),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  _addressController,
                  'Alamat Lengkap',
                  Icons.location_on_rounded,
                  maxLines: 3,
                  hint: 'Alamat domisili saat ini...',
                ),
                const SizedBox(height: 16),
                _buildTextField(_notesController, 'Catatan (Opsional)', Icons.chat_bubble_rounded, maxLines: 2),
                
                const SizedBox(height: 48),
                
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 4,
                    shadowColor: const Color(0xFF0F172A).withOpacity(0.4),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text('AJUKAN KREDIT SEKARANG', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreditSimulator(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: const Color(0xFF0F172A).withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          _buildSimulationRow('Uang Muka (DP)', format.format(_dpAmount), isBold: true),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2563EB),
              inactiveTrackColor: Colors.white.withOpacity(0.1),
              thumbColor: Colors.white,
              overlayColor: const Color(0xFF2563EB).withOpacity(0.2),
              trackHeight: 4,
            ),
            child: Slider(
              value: _dpAmount,
              min: _minDP,
              max: widget.motor.price * 0.8,
              onChanged: (val) {
                setState(() {
                  _dpAmount = val;
                  _dpController.text = NumberFormat.decimalPattern('id_ID').format(val.toInt());
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [12, 24, 36].map((t) {
              bool isSelected = _selectedTenor == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTenor = t),
                  child: Container(
                    margin: EdgeInsets.only(right: t == 36 ? 0 : 12),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.1)),
                    ),
                    child: Center(
                      child: Text('$t bln', style: GoogleFonts.outfit(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: Column(
              children: [
                Text('ESTIMASI ANGSURAN', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                const SizedBox(height: 4),
                Text(format.format(_monthlyInstallment), style: GoogleFonts.outfit(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                Text('*Bunga Flat 1.5%', style: GoogleFonts.outfit(color: Colors.white38, fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 13)),
        Text(value, style: GoogleFonts.outfit(color: Colors.white, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 15)),
      ],
    );
  }

  Widget _buildMotorSummary(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: widget.motor.imagePath != null
                ? CachedNetworkImage(
                    imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                    httpHeaders: ApiConfig.ngrokHeaders,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(width: 100, height: 80, color: const Color(0xFFF1F5F9), child: const Icon(Icons.motorcycle_rounded)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.motor.name, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                Text(format.format(widget.motor.price), style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFF2563EB))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1.5));
  }

  Widget _buildBranchSelection(MotorProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: provider.branches.map((branch) {
          final isSelected = _selectedBranch == branch['name'];
          return InkWell(
            onTap: () => setState(() => _selectedBranch = branch['name']),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB).withOpacity(0.05) : Colors.transparent,
                border: Border(bottom: BorderSide(color: branch == provider.branches.last ? Colors.transparent : const Color(0xFFF1F5F9))),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, size: 20, color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch['name'], style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: const Color(0xFF0F172A))),
                        Text(branch['address'] ?? '', style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF64748B))),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 22),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildToggleSelection({required String label, required List<String> options, required String currentValue, required Function(String) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            bool isSelected = currentValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  margin: EdgeInsets.only(right: option == options.first ? 10 : 0, left: option == options.last ? 10 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0), width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      option.toUpperCase(),
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF475569)),
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

  Widget _buildDropdownColor() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: DropdownButtonFormField<String>(
        value: _selectedColor,
        decoration: InputDecoration(
          labelText: 'Pilih Warna Motor',
          labelStyle: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 14),
          prefixIcon: const Icon(Icons.palette_rounded, color: Color(0xFF64748B)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        items: _availableColors.map((color) => DropdownMenuItem(value: color, child: Text(color, style: GoogleFonts.outfit()))).toList(),
        onChanged: (val) => setState(() => _selectedColor = val),
        validator: (value) => value == null ? 'Warna wajib dipilih' : null,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1, int? maxLength, bool isCurrency = false, String? hint}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        maxLength: maxLength,
        style: GoogleFonts.outfit(fontSize: 15),
        onChanged: (value) {
          if (isCurrency) {
            String cleaned = value.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '');
            if (cleaned.isNotEmpty) {
              final formatter = NumberFormat.decimalPattern('id_ID');
              String formatted = formatter.format(int.parse(cleaned));
              controller.value = TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
            }
          }
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 14),
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          counterText: '',
        ),
        validator: (value) {
          if (label.contains('Catatan')) return null;
          if (value == null || value.isEmpty) return '$label wajib diisi';
          return null;
        },
      ),
    );
  }
}
