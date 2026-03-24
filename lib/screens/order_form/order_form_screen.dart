import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/motor.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';

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
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    _nameController = TextEditingController(text: user?.name);
    _phoneController = TextEditingController(text: user?.phone);
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<OrderProvider>().submitCashOrder(
            motorId: widget.motor.id,
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            occupation: _occupationController.text.trim(),
            address: _addressController.text.trim(),
            notes: _notesController.text.trim(),
          );

      if (success && mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Pesanan Berhasil'),
            content: const Text('Terima kasih! Pesanan Anda telah diterima. Tim kami akan segera menghubungi Anda.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                  Navigator.of(context).pop(); // Kembali dari form
                  Navigator.of(context).pop(); // Kembali dari detail
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.read<OrderProvider>().errorMessage ?? 'Gagal membuat pesanan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<OrderProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Pemesanan Tunai'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Summary Table-like info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Motor', widget.motor.name),
                    _buildSummaryRow('Brand', widget.motor.brand),
                    _buildSummaryRow('Harga', 'Rp ${widget.motor.price.toStringAsFixed(0)}'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(_nameController, 'Nama Lengkap', Icons.person_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_phoneController, 'Nomor Telepon', Icons.phone_outlined, keyboardType: TextInputType.phone),
                    const SizedBox(height: 16),
                    _buildTextField(_occupationController, 'Pekerjaan', Icons.work_outline),
                    const SizedBox(height: 16),
                    _buildTextField(_addressController, 'Alamat Lengkap', Icons.location_on_outlined, maxLines: 3),
                    const SizedBox(height: 16),
                    _buildTextField(_notesController, 'Catatan (Opsional)', Icons.note_outlined),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('PESAN SEKARANG', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
