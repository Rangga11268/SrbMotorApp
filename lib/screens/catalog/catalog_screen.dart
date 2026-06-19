import 'package:flutter/material.dart';
import 'package:srb_motor_app/app_state.dart';
import 'package:srb_motor_app/models/motor.dart';
import 'package:srb_motor_app/screens/home/widgets/motor_card.dart';

class CatalogScreen extends StatefulWidget {
  final AppState appState;
  final Function(Motor) onMotorTap;

  const CatalogScreen({
    super.key,
    required this.appState,
    required this.onMotorTap,
  });

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final searchController = TextEditingController();
  String selectedBrand = 'Semua';
  String selectedType = 'Semua';
  List<Motor> filteredMotors = [];

  @override
  void initState() {
    super.initState();
    filteredMotors = motorList;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void filterMotors() {
    List<Motor> filtered = motorList;
    final query = searchController.text.toLowerCase().trim();

    if (query.isNotEmpty) {
      filtered = filtered.where((motor) {
        return motor.name.toLowerCase().contains(query) ||
            motor.brand.toLowerCase().contains(query) ||
            motor.type.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedBrand != 'Semua') {
      filtered = filtered.where((motor) => motor.brand == selectedBrand).toList();
    }

    if (selectedType != 'Semua') {
      filtered = filtered.where((motor) => motor.type == selectedType).toList();
    }

    setState(() {
      filteredMotors = filtered;
    });
  }

  void resetFilters() {
    searchController.clear();
    setState(() {
      selectedBrand = 'Semua';
      selectedType = 'Semua';
      filteredMotors = motorList;
    });
  }

  String formatPrice(double price) {
    return 'Rp ${(price / 1000000).toStringAsFixed(1)} jt';
  }

  List<String> getTypes() {
    // Get unique motor types
    final types = motorList.map((m) => m.type).toSet().toList();
    return types;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.motorcycle, color: Color(0xFF041627)),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Katalog Motor',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF041627),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Honda dan Yamaha pilihan terbaik Anda.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF5F5E5E)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Filter Panel Card
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Color(0xFFE2E2E2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cari & Filter',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF041627)),
                ),
                const SizedBox(height: 12),
                // Search TextField
                TextField(
                  controller: searchController,
                  onChanged: (_) => filterMotors(),
                  decoration: InputDecoration(
                    hintText: 'Cari motor, brand, atau tipe...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF3F3F3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
                const SizedBox(height: 16),
                // Brand Chips
                const Text(
                  'Brand',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF5F5E5E)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ['Semua', 'Honda', 'Yamaha'].map((brand) {
                    final selected = selectedBrand == brand;
                    return ChoiceChip(
                      label: Text(brand),
                      selected: selected,
                      selectedColor: const Color(0xFF041627),
                      backgroundColor: const Color(0xFFF3F3F3),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF041627),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedBrand = brand;
                        });
                        filterMotors();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Type Chips
                const Text(
                  'Tipe Motor',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Color(0xFF5F5E5E)),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: ['Semua', ...getTypes()].map((type) {
                    final selected = selectedType == type;
                    return ChoiceChip(
                      label: Text(type),
                      selected: selected,
                      selectedColor: const Color(0xFF041627),
                      backgroundColor: const Color(0xFFF3F3F3),
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : const Color(0xFF041627),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      onSelected: (_) {
                        setState(() {
                          selectedType = type;
                        });
                        filterMotors();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Count and Reset Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Ditemukan ${filteredMotors.length} motor',
                      style: const TextStyle(color: Color(0xFF5F5E5E), fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                    TextButton(
                      onPressed: resetFilters,
                      child: const Text(
                        'Reset Filter',
                        style: TextStyle(color: Color(0xFFBA1A1A), fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Motors List
        if (filteredMotors.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            alignment: Alignment.center,
            child: const Column(
              children: [
                Icon(Icons.search_off, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text('Motor tidak ditemukan', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        else
          Column(
            children: filteredMotors.map((motor) {
              final isWishlisted = widget.appState.isInWishlist(motor.id);
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: MotorCard(
                  motor: motor,
                  isWishlisted: isWishlisted,
                  onWishlistToggle: () async {
                    await widget.appState.toggleWishlist(motor.id);
                    if (mounted) {
                      setState(() {});
                    }
                  },
                  onTap: () => widget.onMotorTap(motor),
                  formatPrice: formatPrice,
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
