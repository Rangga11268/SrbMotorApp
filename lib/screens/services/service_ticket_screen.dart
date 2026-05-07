import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ServiceTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const ServiceTicketScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = (ticket['status'] ?? 'pending').toString().toLowerCase();
    final bool isCompleted = status == 'completed' || status == 'selesai';
    final bool isPending = status == 'pending' || status == 'menunggu';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Tiket Servis',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: const Color(0xFF1E293B),
          ),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildTicketCard(context, status),
              const SizedBox(height: 32),
              if (isPending && ticket['payment_status'] != 'paid')
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      _showPaymentDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 8,
                      shadowColor: const Color(
                        0xFF2563EB,
                      ).withValues(alpha: 0.3),
                    ),
                    child: Text(
                      'Bayar Sekarang',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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

  Widget _buildTicketCard(BuildContext context, String currentStatus) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.directions_bike_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['motor_model'] ?? 'Servis Motor',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ticket['plate_number'] ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Ticket Details
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildInfoRow(
                  'Nomor Antrean',
                  ticket['queue_number']?.toString() ?? '-',
                ),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                _buildInfoRow('Jenis Servis', ticket['service_type'] ?? '-'),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Jadwal',
                  '${ticket['service_date'] ?? ''} ${ticket['service_time'] ?? ''}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Cabang', ticket['branch'] ?? 'Pusat'),

                if (ticket['complaint_notes'] != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow('Keluhan', ticket['complaint_notes']),
                ],
                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                _buildStatusRow(currentStatus),
              ],
            ),
          ),

          // Bottom Tear Edge Decor
          _buildTearEdge(),

          // Footer Section (Total Cost)
          if (ticket['estimated_cost'] != null || ticket['total_cost'] != null)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimasi Biaya',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Rp ${ticket['total_cost'] ?? ticket['estimated_cost']}',
                    style: GoogleFonts.outfit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String status) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
      case 'selesai':
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case 'pending':
      case 'menunggu':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'cancelled':
      case 'batal':
        statusColor = Colors.red;
        statusText = 'Dibatalkan';
        break;
      default:
        statusColor = Colors.blue;
        statusText = status.toUpperCase();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Status',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTearEdge() {
    return Row(
      children: List.generate(
        30,
        (index) => Expanded(
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }

  void _showPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: Colors.blue,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Informasi',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'Fitur pembayaran online untuk servis sedang dalam pengembangan. Silakan lakukan pembayaran langsung di bengkel setelah servis selesai.',
          style: GoogleFonts.inter(color: const Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Tutup',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
