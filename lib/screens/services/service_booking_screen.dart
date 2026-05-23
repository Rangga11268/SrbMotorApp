import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:srb_motor_app/providers/motor_provider.dart';
import 'package:srb_motor_app/providers/service_provider.dart';
import 'package:srb_motor_app/providers/main_provider.dart';

class ServiceBookingScreen extends StatefulWidget {
  final bool isRoot;
  final String? initialServiceType;
  const ServiceBookingScreen({super.key, this.isRoot = false, this.initialServiceType});

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

  final List<Map<String, dynamic>> _serviceTypesData = [
    {'name': 'Servis Berkala', 'icon': Icons.build_circle_outlined},
    {'name': 'Servis Berat', 'icon': Icons.handyman_outlined},
    {'name': 'Ganti Oli', 'icon': Icons.opacity_outlined},
    {'name': 'Cek Kelistrikan', 'icon': Icons.bolt_outlined},
    {'name': 'Lainnya', 'icon': Icons.more_horiz_outlined},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialServiceType != null) {
      _selectedServiceType = widget.initialServiceType!;
    }
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

  List<DateTime> _generateDates() {
    return List.generate(14, (index) => DateTime.now().add(Duration(days: index + 1)));
  }

  String _getDayName(DateTime date) {
    const dayNames = {
      'Mon': 'Sen',
      'Tue': 'Sel',
      'Wed': 'Rab',
      'Thu': 'Kam',
      'Fri': 'Jum',
      'Sat': 'Sab',
      'Sun': 'Min'
    };
    final enName = DateFormat('EEE').format(date);
    return dayNames[enName] ?? enName;
  }

  String _getMonthName(DateTime date) {
    const monthNames = {
      'Jan': 'Jan',
      'Feb': 'Feb',
      'Mar': 'Mar',
      'Apr': 'Apr',
      'May': 'Mei',
      'Jun': 'Jun',
      'Jul': 'Jul',
      'Aug': 'Ags',
      'Sep': 'Sep',
      'Oct': 'Okt',
      'Nov': 'Nov',
      'Dec': 'Des'
    };
    final enName = DateFormat('MMM').format(date);
    return monthNames[enName] ?? enName;
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
        _showError(
          context.read<ServiceProvider>().errorMessage ??
              'Gagal memesan servis',
        );
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
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
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF10B981),
                size: 72,
              ),
              const SizedBox(height: 24),
              Text(
                'Booking Berhasil!',
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tiket antrian Anda telah diterbitkan. Silakan cek riwayat servis untuk detailnya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  color: const Color(0xFF64748B),
                  fontSize: 14,
                  height: 1.4,
                ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
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

  @override
  Widget build(BuildContext context) {
    final motorProvider = context.watch<MotorProvider>();
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'BOOKING SERVIS',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF0F172A),
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        automaticallyImplyLeading: !widget.isRoot,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
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
              const SizedBox(height: 28),

              _buildVehicleInfoSection(),
              const SizedBox(height: 28),

              _buildHorizontalCalendar(),
              const SizedBox(height: 20),
              if (_selectedDate != null) ...[
                _buildTimeSlotGrid(serviceProvider),
                const SizedBox(height: 28),
              ],

              _buildSectionTitle('CATATAN / KELUHAN (OPSIONAL)'),
              const SizedBox(height: 12),
              _buildTextField(
                _complaintController,
                'Tulis keluhan jika ada...',
                Icons.note_add_outlined,
                maxLines: 3,
              ),

              const SizedBox(height: 40),
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
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF64748B),
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildBranchSelector(MotorProvider provider) {
    final branches = provider.branches
        .where((b) => b['can_service'] == true || b['can_service'] == 1)
        .toList();

    if (branches.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFBEB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFFDE68A)),
        ),
        child: Text(
          'Maaf, tidak ada cabang yang tersedia untuk servis saat ini.',
          style: GoogleFonts.outfit(color: const Color(0xFFB45309), fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: branches.length,
        itemBuilder: (context, index) {
          final branch = branches[index];
          final isSelected = _selectedBranch == branch['name'];
          return GestureDetector(
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
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 250,
              margin: const EdgeInsets.only(right: 12, bottom: 8, top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                  width: isSelected ? 2 : 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isSelected ? 0.05 : 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF2563EB).withOpacity(0.1)
                          : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          branch['name'],
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: const Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          branch['address'] ?? '',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: const Color(0xFF64748B),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF0F172A),
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.outfit(
          color: const Color(0xFF64748B),
          fontSize: 13,
        ),
        hintText: label,
        hintStyle: GoogleFonts.outfit(
          color: const Color(0xFF94A3B8),
          fontSize: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 14.0, right: 10.0),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
      validator: (val) {
        if (label.contains('Opsional')) return null;
        if (val == null || val.isEmpty) return 'Wajib diisi';
        return null;
      },
    );
  }

  Widget _buildServiceTypeSelectorInsideCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TIPE LAYANAN',
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 38,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _serviceTypesData.length,
            itemBuilder: (context, index) {
              final type = _serviceTypesData[index];
              final isSelected = _selectedServiceType == type['name'];
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedServiceType = type['name'];
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        type['icon'] as IconData,
                        color: isSelected ? Colors.white : const Color(0xFF64748B),
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type['name'] as String,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('INFORMASI KENDARAAN'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTextField(
                _plateController,
                'Nomor Plat (e.g. B 1234 ABC)',
                Icons.pin_outlined,
              ),
              const SizedBox(height: 14),
              _buildTextField(
                _modelController,
                'Model Motor (e.g. Vario 160)',
                Icons.motorcycle_outlined,
              ),
              const SizedBox(height: 16),
              const Divider(color: Color(0xFFE2E8F0), height: 1),
              const SizedBox(height: 14),
              _buildServiceTypeSelectorInsideCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalCalendar() {
    final dates = _generateDates();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildSectionTitle('JADWAL KUNJUNGAN'),
            GestureDetector(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 14)),
                );
                if (date != null) _onDateSelected(date);
              },
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    color: Color(0xFF2563EB),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Pilih Manual',
                    style: GoogleFonts.outfit(
                      color: const Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 82,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (context, index) {
              final date = dates[index];
              final dayName = _getDayName(date);
              final dayNum = DateFormat('d').format(date);
              final monthName = _getMonthName(date);

              final isSelected = _selectedDate != null &&
                  _selectedDate!.year == date.year &&
                  _selectedDate!.month == date.month &&
                  _selectedDate!.day == date.day;

              return GestureDetector(
                onTap: () => _onDateSelected(date),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 60,
                  margin: const EdgeInsets.only(right: 8, bottom: 6, top: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                      width: isSelected ? 2 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isSelected ? 0.08 : 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        dayName.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dayNum,
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: isSelected ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(
                        monthName,
                        style: GoogleFonts.outfit(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white.withOpacity(0.8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotGrid(ServiceProvider provider) {
    if (provider.isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (provider.availableSlots.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          'Tidak ada slot tersedia untuk tanggal ini.',
          style: GoogleFonts.outfit(color: const Color(0xFF64748B), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('PILIH JAM KEDATANGAN'),
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

            return GestureDetector(
              onTap: available ? () => setState(() => _selectedTime = slot['time']) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (available ? Colors.white : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (available ? const Color(0xFFE2E8F0) : const Color(0xFFE2E8F0)),
                    width: isSelected ? 2 : 1.5,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                  ],
                ),
                child: Center(
                  child: Text(
                    slot['time'],
                    style: GoogleFonts.outfit(
                      color: isSelected
                          ? Colors.white
                          : (available ? const Color(0xFF0F172A) : const Color(0xFF94A3B8)),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 14,
                      decoration: available ? null : TextDecoration.lineThrough,
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
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
        child: ElevatedButton(
          onPressed: provider.isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: provider.isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  'KONFIRMASI BOOKING SEKARANG',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    fontSize: 13,
                  ),
                ),
        ),
      ),
    );
  }
}
