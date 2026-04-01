import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/motor.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/main_provider.dart';
import '../../main.dart'; // Added for global midtrans instance
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_config.dart';

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
  String _deliveryMethod = 'Ambil di Dealer';
  String _paymentMethod = 'Tunai di Toko';
  double _sisaPembayaran = 0;

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
    _sisaPembayaran = widget.motor.price;

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
    _notesController.dispose();
    _bookingFeeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<OrderProvider>().submitCashOrder(
            motorId: widget.motor.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            nik: _nikController.text.trim(),
            address: _addressController.text.trim(),
            motorColor: _selectedColor ?? 'Default',
            deliveryMethod: _deliveryMethod,
            paymentMethod: _paymentMethod,
            bookingFee: double.tryParse(_bookingFeeController.text.replaceAll('.', '')) ?? 0,
            email: _emailController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (success && mounted) {
        final lastResult = context.read<OrderProvider>().lastOrderResult;
        
        if (_paymentMethod == 'Transfer Bank' && lastResult?['snap_token'] != null) {
          _handleMidtransNativePayment(lastResult!['snap_token']);
        } else {
          _showSuccessDialog();
        }
      } else if (!success && mounted) {
        _showErrorDialog(context.read<OrderProvider>().errorMessage ?? 'Gagal membuat pesanan');
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle, color: Colors.green, size: 60),
              ),
              const SizedBox(height: 24),
              const Text(
                'Pesanan Berhasil!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Terima kasih! Pesanan Anda telah kami terima. Tim kami akan segera menghubungi Anda melalui WhatsApp.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.read<MainProvider>().setSelectedIndex(1); // Go to Orders tab
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(); // Kembali dari form
                    Navigator.of(context).pop(); // Kembali dari detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('KEMBALI KE HOME', style: TextStyle(fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.payment, color: Colors.blue, size: 60),
              const SizedBox(height: 24),
              const Text(
                'Lanjutkan Pembayaran',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 12),
              const Text(
                'Anda akan diarahkan ke halaman pembayaran aman Midtrans untuk menyelesaikan transaksi.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // 1. Switch to Order History tab globally
                    context.read<MainProvider>().setSelectedIndex(1);

                    // 2. Start background status polling for the first installment (Booking Fee)
                    final orderProvider = context.read<OrderProvider>();
                    final lastResult = orderProvider.lastOrderResult;
                    if (lastResult != null && 
                        lastResult['order'] != null && 
                        lastResult['order']['installments'] != null &&
                        (lastResult['order']['installments'] as List).isNotEmpty) {
                      final orderData = lastResult['order'];
                      final firstInst = (orderData['installments'] as List).first;
                      final instId = firstInst['id'];
                      final orderId = orderData['id'];
                      if (instId != null && orderId != null) {
                        orderProvider.startPollingStatus(instId, orderId);
                      }
                    }

                    // 3. Clear navigation stack back to HomeScreen so form is gone
                    Navigator.of(context).pop(); // Dialog
                    Navigator.of(context).pop(); // OrderForm
                    Navigator.of(context).pop(); // MotorDetail

                    // 4. Start the Native SDK flow
                    try {
                      midtrans?.startPaymentUiFlow(token: token);
                    } catch (e) {
                      debugPrint('Error launching Midtrans SDK: $e');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape:
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child:
                      const Text('BAYAR SEKARANG', style: TextStyle(fontWeight: FontWeight.bold)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              const Text('Oops! Gagal Memesan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('TUTUP'),
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
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Beli Cash', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Motor Summary Header
              _buildMotorSummary(currencyFormat),
              const SizedBox(height: 24),
              
              // 2. Form Section
              const Text(
                'Informasi Pelanggan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 16),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Nama Lengkap (Sesuai KTP)', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Nomor WhatsApp', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(_emailController, 'Email (Opsional)', Icons.mail_outline, keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 16),
                    _buildTextField(_nikController, 'NIK (16 Digit)', Icons.fingerprint, keyboardType: TextInputType.number, maxLength: 16),
                    const SizedBox(height: 16),
                    
                    // Dropdown Warna
                    _buildDropdownColor(),
                    const SizedBox(height: 24),
                    
                    // Delivery Method Toggle
                    _buildSectionHeader('Metode Penyerahan'),
                    const SizedBox(height: 12),
                    _buildToggleSelection(
                      options: ['Ambil di Dealer', 'Kirim ke Rumah'],
                      currentValue: _deliveryMethod,
                      onChanged: (val) => setState(() => _deliveryMethod = val),
                    ),
                    const SizedBox(height: 24),

                    // Payment Method Toggle
                    _buildSectionHeader('Metode Pembayaran'),
                    const SizedBox(height: 12),
                    _buildToggleSelection(
                      options: ['Transfer Bank', 'Tunai di Toko'],
                      currentValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val),
                    ),
                    const SizedBox(height: 24),

                    _buildTextField(
                      _addressController,
                      _deliveryMethod == 'Kirim ke Rumah' ? 'Alamat Pengiriman' : 'Alamat Lengkap (Sesuai KTP)',
                      Icons.location_on_outlined,
                      maxLines: 3,
                      hint: _deliveryMethod == 'Kirim ke Rumah' 
                          ? 'Masukkan alamat lengkap tujuan pengiriman unit...' 
                          : 'Masukkan alamat sesuai KTP untuk keperluan STNK/BPKB',
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(_bookingFeeController, 'Booking Fee (Opsional)', Icons.wallet_outlined, keyboardType: TextInputType.number, isCurrency: true),
                    
                    // Live Sisa Pembayaran Card (Web Style)
                    if (_bookingFeeController.text.isNotEmpty && double.parse(_bookingFeeController.text.replaceAll('.', '')) > 0)
                      _buildRemainingBalanceCard(currencyFormat),
                    
                    const SizedBox(height: 16),
                    
                    _buildTextField(_notesController, 'Catatan (Opsional)', Icons.note_outlined, maxLines: 2),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Submit Button
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: 8,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('PESAN SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              ),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shield_outlined, size: 16, color: Colors.green),
                  SizedBox(width: 8),
                  Text('Transaksi Aman & Terenkripsi', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMotorSummary(NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: widget.motor.imagePath != null
                ? CachedNetworkImage(
                    imageUrl: ApiConfig.sanitizeUrl(widget.motor.imagePath!)!,
                    httpHeaders: ApiConfig.ngrokHeaders,
                    width: 100,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 100,
                      height: 80,
                      color: Colors.grey[100],
                      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
                    errorWidget: (context, url, error) => _buildNoImage(),
                  )
                : _buildNoImage(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.motor.brand.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue)),
                Text(widget.motor.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
                const SizedBox(height: 4),
                Text(format.format(widget.motor.price), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoImage() {
    return Container(width: 100, height: 80, color: Colors.grey[200], child: const Icon(Icons.motorcycle, color: Colors.grey));
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey));
  }

  Widget _buildToggleSelection({required List<String> options, required String currentValue, required Function(String) onChanged}) {
    return Row(
      children: options.map((option) {
        bool isSelected = currentValue == option;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(option),
            child: Container(
              margin: EdgeInsets.only(right: option == options.first ? 8 : 0, left: option == options.last ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isSelected ? const Color(0xFF2563EB) : Colors.grey[300]!, width: 1.5),
              ),
              child: Center(
                child: Text(
                  option, // Show full text for clarity
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? const Color(0xFF2563EB) : Colors.grey[600],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdownColor() {
    return DropdownButtonFormField<String>(
      value: _selectedColor,
      decoration: InputDecoration(
        labelText: 'Pilih Warna',
        prefixIcon: const Icon(Icons.palette_outlined),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
      ),
      items: _availableColors.map((color) => DropdownMenuItem(value: color, child: Text(color))).toList(),
      onChanged: (val) => setState(() => _selectedColor = val),
      validator: (value) => value == null ? 'Pilih warna motor' : null,
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1, int? maxLength, bool isCurrency = false, String? hint}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: (value) {
        if (isCurrency) {
          String cleaned = value.replaceAll('.', '').replaceAll(RegExp(r'[^0-9]'), '');
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
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[200]!)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey[300]!)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2)),
      ),
      validator: (value) {
        if (label.contains('(Opsional)')) return null;
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        if (label.contains('NIK') && value.length != 16) {
          return 'NIK harus 16 digit';
        }
        return null;
      },
    );
  }

  Widget _buildRemainingBalanceCard(NumberFormat format) {
    bool isOverPrice = _sisaPembayaran < 0;
    
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isOverPrice ? Colors.red[50] : Colors.green[50],
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isOverPrice ? Colors.red[200]! : Colors.green[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SISA PEMBAYARAN',
                style: TextStyle(
                  fontSize: 12, 
                  fontWeight: FontWeight.bold, 
                  color: isOverPrice ? Colors.red[700] : Colors.green[700],
                  letterSpacing: 1.1
                ),
              ),
              Text(
                format.format(_sisaPembayaran < 0 ? 0 : _sisaPembayaran),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          if (isOverPrice)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Booking fee tidak boleh melebihi harga unit!',
                style: TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
