import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/motor.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../providers/main_provider.dart';
import '../../services/api_config.dart';
import '../../main.dart';

class OrderFormScreen extends StatefulWidget {
  final Motor motor;
  const OrderFormScreen({super.key, required this.motor});

  @override
  State<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends State<OrderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _nikController;
  late TextEditingController _addressController;
  final _notesController = TextEditingController();
  final _bookingFeeController = TextEditingController();

  String? _selectedColor;
  String? _selectedBranch;
  bool _showAllBranches = false;
  String _deliveryMethod = 'Ambil di Dealer';
  String _paymentMethod = 'Tunai di Toko';
  double _sisaPembayaran = 0;

  List<String> _availableColors = [];

  File? _ktpImage;
  File? _kkImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(bool isKtp) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          if (isKtp) {
            _ktpImage = File(image.path);
          } else {
            _kkImage = File(image.path);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Gagal mengambil gambar: $e');
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
    _emailController = TextEditingController(text: user?.email);
    _nikController = TextEditingController(text: user?.nik);
    _addressController = TextEditingController(text: user?.alamat);
    _sisaPembayaran = widget.motor.price;

    // Auto-select branch from motor data — but only if it has stock
    final motorProvider = context.read<MotorProvider>();
    final availableBranches = motorProvider.getBranchesWithMotor(widget.motor.name);

    if (widget.motor.branch != null) {
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
    _notesController.dispose();
    _bookingFeeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        _showErrorDialog('Silakan pilih cabang terlebih dahulu');
        return;
      }

      if (_ktpImage == null || _kkImage == null) {
        _showErrorDialog('Mohon unggah dokumen KTP dan KK Anda.');
        return;
      }

      final success = await context.read<OrderProvider>().submitCashOrder(
        motorId: widget.motor.id,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        nik: _nikController.text.trim(),
        address: _addressController.text.trim(),
        motorColor: _selectedColor ?? 'Default',
        deliveryMethod: _deliveryMethod,
        paymentMethod: _paymentMethod,
        branch: _selectedBranch,
        bookingFee:
            double.tryParse(_bookingFeeController.text.replaceAll('.', '')) ??
            0,
        email: _emailController.text.trim(),
        notes: _notesController.text.trim(),
        ktpImage: _ktpImage,
        kkImage: _kkImage,
      );

      if (success && mounted) {
        final lastResult = context.read<OrderProvider>().lastOrderResult;

        if (_paymentMethod == 'Transfer Bank' &&
            lastResult?['snap_token'] != null) {
          _handleMidtransNativePayment(lastResult!['snap_token']);
        } else {
          _showSuccessDialog();
        }
      } else if (!success && mounted) {
        _showErrorDialog(
          context.read<OrderProvider>().errorMessage ?? 'Gagal membuat pesanan',
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
                  Icons.check_rounded,
                  color: Color(0xFF10B981),
                  size: 50,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Pesanan Terkirim!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Terima kasih! Pesanan Anda telah kami terima. Tim kami akan segera menghubungi Anda melalui WhatsApp.',
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
                    'LIHAT PESANAN SAYA',
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

  void _handleMidtransNativePayment(String token) async {
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
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Color(0xFF2563EB),
                  size: 40,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Lanjutkan Pembayaran',
                style: GoogleFonts.outfit(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Selesaikan pembayaran booking fee Anda melalui Midtrans untuk memproses pesanan.',
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
                  onPressed: () async {
                    context.read<MainProvider>().setSelectedIndex(1);
                    final orderProvider = context.read<OrderProvider>();
                    final lastResult = orderProvider.lastOrderResult;
                    if (lastResult != null &&
                        lastResult['order'] != null &&
                        lastResult['order']['installments'] != null &&
                        (lastResult['order']['installments'] as List)
                            .isNotEmpty) {
                      final orderData = lastResult['order'];
                      final firstInst =
                          (orderData['installments'] as List).first;
                      final instId = firstInst['id'];
                      final orderId = orderData['id'];
                      if (instId != null && orderId != null) {
                        orderProvider.startPollingStatus(instId, orderId);
                      }
                    }

                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();

                    try {
                      midtrans?.startPaymentUiFlow(token: token);
                    } catch (e) {
                      debugPrint('Error: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'BAYAR SEKARANG',
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
                'Terjadi Kesalahan',
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
          'FORMULIR PEMBELIAN',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF0F172A),
            fontSize: 16,
            letterSpacing: 1,
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

                _buildSectionHeader('INFORMASI CABANG'),
                const SizedBox(height: 16),
                _buildBranchSelection(motorProvider),
                const SizedBox(height: 32),

                _buildSectionHeader('INFORMASI PELANGGAN'),
                const SizedBox(height: 16),
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
                  hint: 'Contoh: 0812...',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _emailController,
                  'Email',
                  Icons.email_rounded,
                  keyboardType: TextInputType.emailAddress,
                  hint: 'Alamat email aktif',
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  _nikController,
                  'NIK',
                  Icons.badge_rounded,
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  hint: '16 digit nomor KTP',
                ),
                const SizedBox(height: 16),
                _buildDropdownColor(),
                const SizedBox(height: 32),

                _buildSectionHeader('DOKUMEN PERSYARATAN'),
                const SizedBox(height: 16),
                _buildDocumentUploadCard(
                  title: 'Foto KTP',
                  subtitle: 'Unggah foto KTP asli yang jelas terbaca',
                  image: _ktpImage,
                  onTap: () => _pickImage(true),
                ),
                const SizedBox(height: 12),
                _buildDocumentUploadCard(
                  title: 'Foto Kartu Keluarga (KK)',
                  subtitle: 'Unggah foto KK yang jelas terbaca',
                  image: _kkImage,
                  onTap: () => _pickImage(false),
                ),
                const SizedBox(height: 32),

                _buildSectionHeader('PENGIRIMAN & PEMBAYARAN'),
                const SizedBox(height: 16),
                _buildToggleSelection(
                  label: 'Metode Penyerahan',
                  options: ['Ambil di Dealer', 'Kirim ke Rumah'],
                  currentValue: _deliveryMethod,
                  onChanged: (val) => setState(() => _deliveryMethod = val),
                ),
                const SizedBox(height: 20),
                _buildToggleSelection(
                  label: 'Metode Pembayaran',
                  options: ['Transfer Bank', 'Tunai di Toko'],
                  currentValue: _paymentMethod,
                  onChanged: (val) => setState(() => _paymentMethod = val),
                ),
                const SizedBox(height: 24),

                _buildTextField(
                  _addressController,
                  'Alamat Lengkap',
                  Icons.location_on_rounded,
                  maxLines: 3,
                  hint: _deliveryMethod == 'Kirim ke Rumah'
                      ? 'Alamat tujuan pengiriman unit...'
                      : 'Alamat domisili untuk STNK/BPKB',
                ),
                const SizedBox(height: 16),

                _buildTextField(
                  _bookingFeeController,
                  'Booking Fee',
                  Icons.payments_rounded,
                  keyboardType: TextInputType.number,
                  isCurrency: true,
                  hint: 'Opsional (Rp)',
                ),

                if (_bookingFeeController.text.isNotEmpty &&
                    double.parse(
                          _bookingFeeController.text.replaceAll('.', ''),
                        ) >
                        0)
                  _buildRemainingBalanceCard(currencyFormat),

                const SizedBox(height: 16),
                _buildTextField(
                  _notesController,
                  'Catatan Tambahan',
                  Icons.chat_bubble_rounded,
                  maxLines: 2,
                  hint: 'Tulis pesan khusus jika ada...',
                ),

                const SizedBox(height: 48),

                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withOpacity(0.4),
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
                      : Text(
                          'KONFIRMASI PESANAN',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Data aman dan terenkripsi oleh sistem',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMotorSummary(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Hero(
            tag: 'motor_${widget.motor.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: widget.motor.imagePath != null
                  ? CachedNetworkImage(
                      imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                      httpHeaders: ApiConfig.ngrokHeaders,
                      width: 110,
                      height: 90,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => _buildNoImage(),
                    )
                  : _buildNoImage(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.motor.brand.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2563EB),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.motor.name,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  format.format(widget.motor.price),
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImage() {
    return Container(
      width: 110,
      height: 90,
      color: const Color(0xFFF1F5F9),
      child: const Icon(
        Icons.motorcycle_rounded,
        color: Color(0xFFCBD5E1),
        size: 32,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 12,
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

    // Filter and sort branches: Only show available ones, then by distance
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

          // Logic: Show only selected branch OR show all if toggled
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
                    _showAllBranches = false; // Auto-collapse after select
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
                                  fontSize: 15,
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

          // Button to show all
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
            fontWeight: FontWeight.w600,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: options.map((option) {
            bool isSelected = currentValue == option;
            return Expanded(
              child: GestureDetector(
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
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
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
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
                        letterSpacing: 0.5,
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
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.palette_rounded,
              color: Color(0xFF2563EB),
              size: 20,
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
          setState(() {
            double booking = double.tryParse(cleaned) ?? 0;
            _sisaPembayaran = widget.motor.price - booking;
          });
        }
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF64748B),
          fontSize: 14,
        ),
        hintText: hint,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF94A3B8),
          fontSize: 15,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 12.0),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 20),
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
        if (label.contains('Opsional') ||
            label.contains('Booking Fee') ||
            label.contains('Catatan'))
          return null;
        if (value == null || value.isEmpty) return '$label wajib diisi';
        if (label.contains('NIK') && value.length != 16)
          return 'NIK harus 16 digit';
        return null;
      },
    );
  }

  Widget _buildRemainingBalanceCard(NumberFormat format) {
    bool isOverPrice = _sisaPembayaran < 0;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isOverPrice ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isOverPrice
              ? const Color(0xFFFEE2E2)
              : const Color(0xFFDCFCE7),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ESTIMASI PELUNASAN',
                style: GoogleFonts.outfit(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isOverPrice
                      ? const Color(0xFFB91C1C)
                      : const Color(0xFF15803D),
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                format.format(_sisaPembayaran < 0 ? 0 : _sisaPembayaran),
                style: GoogleFonts.outfit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          if (isOverPrice)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Booking fee melebihi harga unit!',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: const Color(0xFFB91C1C),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required File? image,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: image != null ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: image != null ? 2 : 1.5,
          ),
          boxShadow: [
            if (image != null)
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(11),
                      child: Image.file(image, fit: BoxFit.cover),
                    )
                  : const Icon(
                      Icons.add_a_photo_rounded,
                      color: Color(0xFF94A3B8),
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    image != null ? 'Dokumen terunggah' : subtitle,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: image != null ? const Color(0xFF10B981) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              image != null ? Icons.check_circle_rounded : Icons.chevron_right_rounded,
              color: image != null ? const Color(0xFF10B981) : const Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }
}
