import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:srb_motor_app/providers/motor_provider.dart';
import 'package:srb_motor_app/providers/service_provider.dart';
import 'package:srb_motor_app/providers/auth_provider.dart';
import 'package:srb_motor_app/providers/main_provider.dart';

class ServiceBookingScreen extends StatefulWidget {
  final bool isRoot;
  const ServiceBookingScreen({super.key, this.isRoot = false});

  @override
  State<ServiceBookingScreen> createState() => _ServiceBookingScreenState();
}

class _ServiceBookingScreenState extends State<ServiceBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedBranch;
  DateTime? _selectedDate;
  String? _selectedTime;
  
  final _plateController = TextEditingController();
  final _modelController = TextEditingController();
  final _complaintController = TextEditingController();
  
  String _selectedServiceType = 'Servis Berkala';
  final List<String> _serviceTypes = [
    'Servis Berkala',
    'Servis Berat',
    'Ganti Oli',
    'Cek Kelistrikan',
    'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MotorProvider>().fetchBranches();
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _complaintController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _selectedTime = null;
    });
    if (_selectedBranch != null) {
      context.read<ServiceProvider>().fetchSlots(
        DateFormat('yyyy-MM-dd').format(date),
        _selectedBranch!,
      );
    }
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedBranch == null) {
        _showError('Silakan pilih cabang');
        return;
      }
      if (_selectedDate == null) {
        _showError('Silakan pilih tanggal');
        return;
      }
      if (_selectedTime == null) {
        _showError('Silakan pilih jam');
        return;
      }

      final success = await context.read<ServiceProvider>().bookService(
        branch: _selectedBranch!,
        plateNumber: _plateController.text.trim(),
        serviceDate: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        serviceTime: _selectedTime!,
        motorModel: _modelController.text.trim(),
        serviceType: _selectedServiceType,
        complaintNotes: _complaintController.text.trim(),
      );

      if (success && mounted) {
        _showSuccess();
      } else if (!success && mounted) {
        _showError(context.read<ServiceProvider>().errorMessage ?? 'Gagal memesan servis');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 64),
              const SizedBox(height: 24),
              Text(
                'Booking Berhasil!',
                style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Tiket antrian Anda telah diterbitkan. Silakan cek riwayat servis untuk detailnya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Pop dialog
                    if (!widget.isRoot) {
                      Navigator.pop(context); // Pop screen
                    } else {
                      context.read<MainProvider>().setSelectedIndex(0); // Back to Home
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('OK', style: TextStyle(color: Colors.white)),
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
    final motorProvider = context.watch<MotorProvider>();
    final serviceProvider = context.watch<ServiceProvider>();
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('BOOKING SERVIS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: !widget.isRoot,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('PILIH CABANG'),
              const SizedBox(height: 12),
              _buildBranchSelector(motorProvider),
              const SizedBox(height: 32),
              
              _buildSectionTitle('INFORMASI KENDARAAN'),
              const SizedBox(height: 12),
              _buildTextField(_plateController, 'Nomor Plat (e.g. B 1234 ABC)', Icons.pin_outlined),
              const SizedBox(height: 16),
              _buildTextField(_modelController, 'Model Motor (e.g. Vario 160)', Icons.motorcycle_outlined),
              const SizedBox(height: 16),
              _buildServiceTypeDropdown(),
              const SizedBox(height: 32),
              
              _buildSectionTitle('JADWAL KUNJUNGAN'),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 16),
              if (_selectedDate != null) _buildTimeSlotGrid(serviceProvider),
              const SizedBox(height: 32),
              
              _buildSectionTitle('CATATAN / KELUHAN (OPSIONAL)'),
              const SizedBox(height: 12),
              _buildTextField(_complaintController, 'Tulis keluhan jika ada...', Icons.note_add_outlined, maxLines: 3),
              
              const SizedBox(height: 48),
              _buildSubmitButton(serviceProvider),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildBranchSelector(MotorProvider provider) {
    final branches = provider.branches.where((b) => b['can_service'] == true || b['can_service'] == 1).toList();
    
    if (branches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12)),
        child: const Text('Maaf, tidak ada cabang yang tersedia untuk servis saat ini.'),
      );
    }

    return Column(
      children: branches.map((branch) {
        final isSelected = _selectedBranch == branch['name'];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedBranch = branch['name'];
                if (_selectedDate != null) {
                  context.read<ServiceProvider>().fetchSlots(
                    DateFormat('yyyy-MM-dd').format(_selectedDate!),
                    branch['name'],
                  );
                }
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB).withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.location_on_rounded, color: isSelected ? const Color(0xFF2563EB) : Colors.grey),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(branch['address'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  if (isSelected) const Icon(Icons.check_circle, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF64748B)),
          hintText: label,
          hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        validator: (val) {
          if (label.contains('Opsional')) return null;
          if (val == null || val.isEmpty) return 'Wajib diisi';
          return null;
        },
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonFormField<String>(
        value: _selectedServiceType,
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.settings_outlined, size: 20, color: Color(0xFF64748B)),
          border: InputBorder.none,
        ),
        items: _serviceTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
        onChanged: (val) => setState(() => _selectedServiceType = val!),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now().add(const Duration(days: 1)),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 14)),
        );
        if (date != null) _onDateSelected(date);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded, size: 20, color: Color(0xFF64748B)),
            const SizedBox(width: 16),
            Text(
              _selectedDate == null ? 'Pilih Tanggal' : DateFormat('EEEE, d MMMM yyyy').format(_selectedDate!),
              style: TextStyle(color: _selectedDate == null ? const Color(0xFF94A3B8) : Colors.black),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSlotGrid(ServiceProvider provider) {
    if (provider.isLoading) return const Center(child: CircularProgressIndicator());
    if (provider.availableSlots.isEmpty) return const Text('Tidak ada slot tersedia untuk tanggal ini.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pilih Jam Kedatangan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemCount: provider.availableSlots.length,
          itemBuilder: (context, index) {
            final slot = provider.availableSlots[index];
            final bool available = slot['available'] == true;
            final bool isSelected = _selectedTime == slot['time'];

            return InkWell(
              onTap: available ? () => setState(() => _selectedTime = slot['time']) : null,
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF0F172A) : (available ? Colors.white : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSelected ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0)),
                ),
                child: Center(
                  child: Text(
                    slot['time'],
                    style: TextStyle(
                      color: isSelected ? Colors.white : (available ? Colors.black : Colors.grey),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSubmitButton(ServiceProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: provider.isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
        ),
        child: provider.isLoading
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
            : const Text('PESAN SEKARANG', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ),
    );
  }
}
