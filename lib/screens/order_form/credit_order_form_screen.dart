import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/motor.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../providers/main_provider.dart';
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
  bool _showAllBranches = false;
  String _deliveryMethod = 'Ambil di Dealer';
  String _paymentMethod = 'Transfer Bank';
  int _selectedTenor = 36;
  double _dpAmount = 0;
  double _minDP = 0;
  int _currentStep = 0;

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
    _dpController = TextEditingController(
      text: NumberFormat.decimalPattern('id_ID').format(_dpAmount),
    );

    // Auto-select branch from motor data — but only if it has stock
    final motorProvider = context.read<MotorProvider>();
    final availableBranches = motorProvider.getBranchesWithMotor(widget.motor.name);

    if (widget.motor.branch != null) {
      // Only auto-select if this branch actually has stock
      final branchLower = widget.motor.branch!.toLowerCase();
      final hasStock = availableBranches.any((av) => av.toLowerCase() == branchLower);
      if (hasStock) {
        _selectedBranch = widget.motor.branch;
      }
    } else if (widget.motor.branchCode != null) {
      final branch = motorProvider.branches.firstWhere(
        (b) => b['id'].toString() == widget.motor.branchCode.toString(),
        orElse: () => <String, dynamic>{},
      );
      if (branch.isNotEmpty) {
        final bName = branch['name']?.toString().toLowerCase() ?? '';
        final bCode = branch['code']?.toString().toLowerCase() ?? '';
        final hasStock = availableBranches.any(
          (av) => av.toLowerCase() == bName || av.toLowerCase() == bCode,
        );
        if (hasStock) {
          _selectedBranch = branch['name'];
        }
      }
    }

    // Initialize colors
    if (widget.motor.colors is List) {
      _availableColors = List<String>.from(widget.motor.colors);
    } else if (widget.motor.colors != null &&
        widget.motor.colors.toString().isNotEmpty) {
      _availableColors = [widget.motor.colors.toString()];
    }

    if (_availableColors.isEmpty) {
      _availableColors = ['Beragam'];
      _selectedColor = 'Beragam';
    } else if (_availableColors.length == 1) {
      _selectedColor = _availableColors.first;
    }
  }

  Future<void> _checkNearestBranch() async {
    try {
      // Check permissions using Geolocator's built-in methods
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Izin lokasi ditolak. Silakan berikan izin untuk mencari dealer terdekat.',
                ),
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Izin lokasi ditolak permanen. Silakan buka pengaturan aplikasi.',
              ),
            ),
          );
        }
        return;
      }

      // Get position with best possible accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      final provider = context.read<MotorProvider>();

      // 1. Get branches that actually have this unit in stock (Consistent with Web)
      final availableBranchNames = provider.getBranchesWithMotor(
        widget.motor.name,
      );

      Map<String, dynamic>? nearest;

      if (availableBranchNames.isNotEmpty) {
        // Find nearest from available branches
        double minDistance = double.infinity;
        for (var branch in provider.branches) {
          final bLat = double.tryParse(branch['latitude']?.toString() ?? '');
          final bLon = double.tryParse(branch['longitude']?.toString() ?? '');

          if (bLat != null && bLon != null) {
            // Calculate and save distance for ALL branches so UI can display it
            final dist = provider.calculateDistance(
              position.latitude,
              position.longitude,
              bLat,
              bLon,
            );
            branch['distance'] = dist;

            final bName = branch['name']?.toString().toLowerCase() ?? '';
            final bCode = branch['code']?.toString().toLowerCase() ?? '';
            final bId = branch['id']?.toString().toLowerCase() ?? '';

            bool hasStock = availableBranchNames.any(
              (av) =>
                  av.toLowerCase() == bName ||
                  av.toLowerCase() == bCode ||
                  av.toLowerCase() == bId,
            );

            if (hasStock) {
              if (dist < minDistance) {
                minDistance = dist;
                nearest = branch;
              }
            }
          }
        }
      }

      // If no available branch found, warn user instead of fallback
      if (nearest == null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFFEF4444),
            content: Text(
              'Tidak ada cabang yang memiliki stok unit ini. Silakan coba motor lain.',
            ),
          ),
        );
        return;
      }

      if (nearest != null && mounted) {
        setState(() {
          _selectedBranch = nearest!['name'];
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF10B981),
            content: Text(
              'Berhasil! Cabang terdekat dengan unit ready: ${nearest['name']} (${NumberFormat('#,##0.0', 'id_ID').format(nearest['distance'] ?? 0)} km)',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal mendapatkan lokasi: $e')));
      }
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
        _showErrorDialog(
          'DP minimal adalah Rp ${NumberFormat.decimalPattern('id_ID').format(_minDP)}',
        );
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
        monthlyIncome:
            double.tryParse(_incomeController.text.replaceAll('.', '')) ?? 0,
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
        _showErrorDialog(
          context.read<OrderProvider>().errorMessage ??
              'Gagal membuat pengajuan kredit',
        );
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
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF10B981),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pengajuan Terkirim!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pengajuan kredit Anda sedang kami proses. Mohon segera lengkapi dokumen pendukung (KTP, KK, Slip Gaji) di halaman detail pesanan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF64748B),
                  height: 1.5,
                  fontSize: 14,
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'LIHAT STATUS PENGAJUAN',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
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
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: Color(0xFFEF4444),
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal Mengajukan',
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'TUTUP',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFEF4444),
                  ),
                ),
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
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'PENGAJUAN KREDIT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStepIndicator(),
                const SizedBox(height: 28),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.1, 0.0),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(
                    key: ValueKey<int>(_currentStep),
                    child: _buildCurrentStepContent(motorProvider, currencyFormat),
                  ),
                ),
                _buildStepNavigation(isLoading),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepContent(
      MotorProvider motorProvider, NumberFormat currencyFormat) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMotorSummary(currencyFormat),
            const SizedBox(height: 28),
            _buildSectionHeader('SIMULASI KREDIT'),
            const SizedBox(height: 12),
            _buildCreditSimulator(currencyFormat),
            const SizedBox(height: 28),
            _buildSectionHeader('INFORMASI CABANG'),
            const SizedBox(height: 12),
            _buildBranchSelection(motorProvider),
          ],
        );
      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Kelompok 1: Informasi Pribadi
            _buildFormCard(
              title: 'INFORMASI PRIBADI',
              icon: Icons.person_outline_rounded,
              children: [
                _buildTextField(
                  _nameController,
                  'Nama Lengkap',
                  Icons.person_rounded,
                  hint: 'Sesuai KTP',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _phoneController,
                  'WhatsApp',
                  Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  hint: '0812...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _nikController,
                  'NIK',
                  Icons.badge_rounded,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  hint: '16 digit KTP',
                ),
                const SizedBox(height: 16),
                _buildDropdownColor(),
              ],
            ),
            const SizedBox(height: 20),

            // Card Kelompok 2: Informasi Pekerjaan
            _buildFormCard(
              title: 'INFORMASI PEKERJAAN',
              icon: Icons.work_outline_rounded,
              children: [
                _buildTextField(
                  _occupationController,
                  'Pekerjaan',
                  Icons.work_rounded,
                  hint: 'Contoh: Karyawan Swasta',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _incomeController,
                  'Pendapatan per Bulan',
                  Icons.account_balance_wallet_rounded,
                  keyboardType: TextInputType.number,
                  isCurrency: true,
                  hint: 'Rp',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _durationController,
                  'Lama Bekerja',
                  Icons.access_time_rounded,
                  hint: 'Contoh: 2 Tahun',
                ),
              ],
            ),
          ],
        );
      case 2:
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card Kelompok 3: Metode Pengiriman
            _buildFormCard(
              title: 'METODE PENGIRIMAN & CATATAN',
              icon: Icons.local_shipping_outlined,
              children: [
                _buildToggleSelection(
                  label: 'Metode Penyerahan',
                  options: ['Ambil di Dealer', 'Kirim ke Rumah'],
                  currentValue: _deliveryMethod,
                  onChanged: (val) => setState(() => _deliveryMethod = val),
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  _addressController,
                  'Alamat Lengkap',
                  Icons.location_on_rounded,
                  maxLines: 3,
                  hint: 'Alamat domisili saat ini...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _notesController,
                  'Catatan (Opsional)',
                  Icons.chat_bubble_rounded,
                  maxLines: 2,
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildStepNavigation(bool isLoading) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                height: 56,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    foregroundColor: const Color(0xFF475569),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.arrow_back_rounded, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'KEMBALI',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: _currentStep < 2
                ? SizedBox(
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentStep == 0) {
                          if (_selectedBranch == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Silakan pilih cabang pengambilan terlebih dahulu'),
                                backgroundColor: Color(0xFFEF4444),
                              ),
                            );
                            return;
                          }
                          setState(() {
                            _currentStep = 1;
                          });
                        } else if (_currentStep == 1) {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              _currentStep = 2;
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'LANJUT',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  )
                : _buildSubmitButton(isLoading),
          ),
        ],
      ),
    );
  }


  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildStepNode(0, 'Simulasi', Icons.calculate_rounded),
          _buildStepLine(0),
          _buildStepNode(1, 'Data Diri', Icons.person_rounded),
          _buildStepLine(1),
          _buildStepNode(2, 'Pengiriman', Icons.local_shipping_rounded),
        ],
      ),
    );
  }

  Widget _buildStepNode(int stepIndex, String title, IconData icon) {
    final isActive = _currentStep == stepIndex;
    final isCompleted = _currentStep > stepIndex;

    Color containerColor;
    Color iconColor;
    Color textColor;
    double scale = isActive ? 1.05 : 1.0;

    if (isActive) {
      containerColor = const Color(0xFF2563EB);
      iconColor = Colors.white;
      textColor = const Color(0xFF2563EB);
    } else if (isCompleted) {
      containerColor = const Color(0xFF10B981);
      iconColor = Colors.white;
      textColor = const Color(0xFF10B981);
    } else {
      containerColor = const Color(0xFFF1F5F9);
      iconColor = const Color(0xFF94A3B8);
      textColor = const Color(0xFF94A3B8);
    }

    return Expanded(
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 200),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: containerColor,
                shape: BoxShape.circle,
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withValues(alpha: 0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                isCompleted ? Icons.check_rounded : icon,
                color: iconColor,
                size: 16,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w900 : FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepLine(int afterStep) {
    final isPassed = _currentStep > afterStep;
    return Container(
      width: 24,
      height: 2,
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isPassed ? const Color(0xFF10B981) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildFormCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF64748B)),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF64748B),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSubmitButton(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(0xFF2563EB).withOpacity(0.6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_turned_in_rounded, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'AJUKAN KREDIT SEKARANG',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
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
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.15),
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
                'Uang Muka (DP)',
                style: GoogleFonts.outfit(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Min: ${format.format(_minDP)}',
                style: GoogleFonts.outfit(
                  color: const Color(0xFFF59E0B),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _dpController,
            keyboardType: TextInputType.number,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
            onChanged: (value) {
              String cleaned = value
                  .replaceAll('.', '')
                  .replaceAll(RegExp(r'[^0-9]'), '');
              if (cleaned.isNotEmpty) {
                double val = double.parse(cleaned);

                double clampedValForSlider = val;
                if (clampedValForSlider < _minDP) {
                  clampedValForSlider = _minDP;
                }
                double maxDP = widget.motor.price * 0.8;
                if (clampedValForSlider > maxDP) {
                  clampedValForSlider = maxDP;
                }

                setState(() {
                  _dpAmount = clampedValForSlider;

                  final formatter = NumberFormat.decimalPattern('id_ID');
                  String formatted = formatter.format(val.toInt());
                  _dpController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(offset: formatted.length),
                  );
                });
              } else {
                setState(() {
                  _dpAmount = _minDP;
                });
              }
            },
            decoration: InputDecoration(
              prefixText: 'Rp ',
              prefixStyle: GoogleFonts.outfit(
                color: Colors.white60,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),
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
                  _dpController.text = NumberFormat.decimalPattern(
                    'id_ID',
                  ).format(val.toInt());
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Tenor Kredit',
            style: GoogleFonts.outfit(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [12, 24, 36].map((t) {
              bool isSelected = _selectedTenor == t;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedTenor = t),
                  child: Container(
                    margin: EdgeInsets.only(right: t == 36 ? 0 : 12),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF2563EB)
                            : Colors.white.withOpacity(0.1),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$t Bulan',
                        style: GoogleFonts.outfit(
                          color: isSelected ? Colors.white : Colors.white60,
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
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'ESTIMASI ANGSURAN BULANAN',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  format.format(_monthlyInstallment),
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '*Bunga Flat 1.5% - Angsuran hanya estimasi',
                  style: GoogleFonts.outfit(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorSummary(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: widget.motor.imagePath != null
                  ? CachedNetworkImage(
                      imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                      httpHeaders: ApiConfig.ngrokHeaders,
                      width: 110,
                      height: 85,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 110,
                      height: 85,
                      color: const Color(0xFFF1F5F9),
                      child: const Icon(Icons.motorcycle_rounded, color: Color(0xFF64748B)),
                    ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'PILIHAN UNIT',
                    style: GoogleFonts.outfit(
                      fontSize: 8,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2563EB),
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  widget.motor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  format.format(widget.motor.price),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildBranchSelection(MotorProvider provider) {
    final availableBranchNames = provider.getBranchesWithMotor(
      widget.motor.name,
    );

    final sortedBranches = List<Map<String, dynamic>>.from(provider.branches).where((b) {
      final bName = b['name']?.toString().toLowerCase() ?? '';
      final bCode = b['code']?.toString().toLowerCase() ?? '';
      final bId = b['id']?.toString().toLowerCase() ?? '';
      return availableBranchNames.any(
        (av) =>
            av.toLowerCase() == bName ||
            av.toLowerCase() == bCode ||
            av.toLowerCase() == bId,
      );
    }).toList();

    sortedBranches.sort((a, b) {
      if (a['distance'] != null && b['distance'] != null) {
        return (a['distance'] as double).compareTo(b['distance'] as double);
      }
      return 0;
    });

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Cabang Pengambilan',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: provider.isLocationLoading
                          ? null
                          : _checkNearestBranch,
                      icon: provider.isLocationLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2563EB),
                              ),
                            )
                          : const Icon(Icons.my_location_rounded, size: 16),
                      label: Text(
                        provider.isLocationLoading
                            ? 'Mencari...'
                            : 'Cek Lokasi',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF2563EB),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        backgroundColor: const Color(
                          0xFF2563EB,
                        ).withOpacity(0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedBranch == null && !provider.isLocationLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      'Silakan klik "Cek Lokasi" untuk mencari dealer terdekat',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFFEF4444),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          ...sortedBranches
              .where(
                (b) =>
                    _showAllBranches ||
                    _selectedBranch?.toLowerCase() ==
                        b['name'].toString().toLowerCase(),
              )
              .map((branch) {
                final isSelected =
                    _selectedBranch?.toLowerCase() ==
                    branch['name'].toString().toLowerCase();

                final bName = branch['name']?.toString().toLowerCase() ?? '';
                final bCode = branch['code']?.toString().toLowerCase() ?? '';
                final bId = branch['id']?.toString().toLowerCase() ?? '';
                final isAvailable = availableBranchNames.any(
                  (av) =>
                      av.toLowerCase() == bName ||
                      av.toLowerCase() == bCode ||
                      av.toLowerCase() == bId,
                );

                return InkWell(
                  onTap: () => setState(() {
                    _selectedBranch = branch['name'];
                    _showAllBranches = false;
                  }),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB).withOpacity(0.04)
                          : Colors.transparent,
                      border: Border(
                        bottom: BorderSide(
                          color:
                              branch == sortedBranches.last ||
                                  (!_showAllBranches && isSelected)
                              ? Colors.transparent
                              : const Color(0xFFF1F5F9),
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : const Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                branch['name'],
                                style: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? const Color(0xFF2563EB)
                                      : const Color(0xFF0F172A),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (isAvailable) ...[
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF10B981,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.check_circle_outline_rounded,
                                            size: 10,
                                            color: Color(0xFF059669),
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'READY',
                                            style: GoogleFonts.outfit(
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              color: const Color(0xFF059669),
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  if (branch['distance'] != null)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFF2563EB,
                                        ).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        '${NumberFormat('#,##0.0', 'id_ID').format(branch['distance'])} KM',
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                branch['address'] ?? '',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  color: const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected && !_showAllBranches)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2563EB),
                            size: 26,
                          ),
                      ],
                    ),
                  ),
                );
              })
              .toList(),

          if (!_showAllBranches && _selectedBranch != null)
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => setState(() => _showAllBranches = true),
                  child: Text(
                    'LIHAT CABANG LAINNYA',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF64748B),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToggleSelection({
    required String label,
    required List<String> options,
    required String currentValue,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            bool isSelected = currentValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: Container(
                  margin: EdgeInsets.only(
                    right: option == options.first ? 10 : 0,
                    left: option == options.last ? 10 : 0,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0F172A) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF0F172A)
                          : const Color(0xFFE2E8F0),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF475569),
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

  Widget _buildDropdownColor() {
    return DropdownButtonFormField<String>(
      value: _selectedColor,
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF64748B),
      ),
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: 'Pilih Warna Motor',
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Color(0xFF2563EB),
              size: 18,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
      ),
      dropdownColor: Colors.white,
      items: _availableColors
          .map(
            (color) => DropdownMenuItem(
              value: color,
              child: Text(color, style: GoogleFonts.outfit()),
            ),
          )
          .toList(),
      onChanged: (val) => setState(() => _selectedColor = val),
      validator: (value) => value == null ? 'Warna wajib dipilih' : null,
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    bool isCurrency = false,
    String? hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: GoogleFonts.outfit(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      onChanged: (value) {
        if (isCurrency) {
          String cleaned = value
              .replaceAll('.', '')
              .replaceAll(RegExp(r'[^0-9]'), '');
          if (cleaned.isNotEmpty) {
            final formatter = NumberFormat.decimalPattern('id_ID');
            String formatted = formatter.format(int.parse(cleaned));
            controller.value = TextEditingValue(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
          }
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF64748B),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 50),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
        ),
        counterText: '',
      ),
      validator: (value) {
        if (label.contains('Catatan')) return null;
        if (value == null || value.isEmpty) return '$label wajib diisi';
        return null;
      },
    );
  }
}
