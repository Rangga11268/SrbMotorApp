import 'package:flutter/material.dart';

class HelpFaqScreen extends StatelessWidget {
  final Function(int) onTabChange;

  const HelpFaqScreen({super.key, required this.onTabChange});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // bg-background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Bantuan & FAQ',
          style: TextStyle(color: Color(0xFF041627), fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Cara Pemesanan
          const Text(
            'CARA PEMESANAN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF041627),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE2E2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  _buildStepItem(
                    stepNumber: '1',
                    title: 'PILIH MOTOR',
                    description: 'Cari motor impian Anda di katalog aplikasi kami yang lengkap.',
                  ),
                  const Divider(height: 32, color: Color(0xFFE2E2E2)),
                  _buildStepItem(
                    stepNumber: '2',
                    title: 'VERIFIKASI DATA',
                    description: 'Tim kami akan menghubungi Anda untuk proses verifikasi dokumen dan ketersediaan.',
                  ),
                  const Divider(height: 32, color: Color(0xFFE2E2E2)),
                  _buildStepItem(
                    stepNumber: '3',
                    title: 'PENGIRIMAN',
                    description: 'Motor impian Anda akan dikirimkan langsung ke alamat tujuan dengan aman.',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Section 2: Syarat Kredit & Cash
          const Text(
            'SYARAT KREDIT & CASH',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: Color(0xFF041627),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFE2E2E2)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Siapkan dokumen berikut untuk mempercepat proses persetujuan:',
                    style: TextStyle(color: Color(0xFF5F5E5E), fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  _buildRequirementItem('KTP Suami & Istri'),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Kartu Keluarga'),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Rekening Listrik / PBB'),
                  const SizedBox(height: 12),
                  _buildRequirementItem('Slip Gaji / Bukti Usaha'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          // Contact buttons
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka WhatsApp dealer...')),
              );
            },
            icon: const Icon(Icons.chat_bubble_outline, color: Colors.white),
            label: const Text(
              'HUBUNGI VIA WHATSAPP',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366), // WhatsApp color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Membuka lokasi dealer di Google Maps...')),
              );
            },
            icon: const Icon(Icons.location_on_outlined, color: Colors.white),
            label: const Text(
              'LOKASI DEALER (MAPS)',
              style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A66C2), // Maps/Blue color
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStepItem({
    required String stepNumber,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: const Color(0xFF041627), // primary
          child: Text(
            stepNumber,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF041627),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F5E5E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRequirementItem(String text) {
    return Row(
      children: [
        const Icon(Icons.check_circle_outline, color: Color(0xFF041627), size: 18),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF041627),
          ),
        ),
      ],
    );
  }
}
