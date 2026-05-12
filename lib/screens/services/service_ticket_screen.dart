import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/service_provider.dart';
import '../../main.dart';

class ServiceTicketScreen extends StatelessWidget {
  final Map<String, dynamic> ticket;

  const ServiceTicketScreen({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = (ticket['status'] ?? 'pending').toString().toLowerCase();
    final bool isCompleted = status == 'completed' || status == 'selesai';
    final bool isUnpaid = ticket['payment_status'] == 'unpaid';

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
      body: Consumer<ServiceProvider>(
        builder: (context, serviceProvider, _) {
          // Use latest data from provider if available
          final currentTicket = serviceProvider.history.firstWhere(
            (t) => t['id'] == ticket['id'],
            orElse: () => ticket,
          );
          
          final currentStatus = (currentTicket['status'] ?? 'pending').toString().toLowerCase();
          final bool canPay = currentStatus == 'completed' && currentTicket['payment_status'] == 'unpaid' && currentTicket['total_cost'] != null;

          return Stack(
            children: [
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTicketCard(context, currentTicket),
                      const SizedBox(height: 32),
                      if (canPay)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {
                              _handlePayment(context, currentTicket['id']);
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
              if (serviceProvider.isLoading)
                Container(
                  color: Colors.white.withValues(alpha: 0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  void _handlePayment(BuildContext context, int id) async {
    final serviceProvider = context.read<ServiceProvider>();
    final result = await serviceProvider.getServicePaymentToken(id);

    if (result['success'] && result['snap_token'] != null) {
      try {
        final token = result['snap_token'];
        midtrans?.startPaymentUiFlow(token: token);
        
        // After starting UI flow, we should eventually refresh the status
        // The main.dart callback will handle the sync
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka halaman pembayaran')),
          );
        }
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal membuat token pembayaran')),
        );
      }
    }
  }

  Widget _buildTicketCard(BuildContext context, Map<String, dynamic> ticketData) {
    final status = (ticketData['status'] ?? 'pending').toString().toLowerCase();
    
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
                        ticketData['motor_model'] ?? 'Servis Motor',
                        style: GoogleFonts.outfit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        ticketData['plate_number'] ?? '-',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Servis Oleh:',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset(
                        'assets/images/logos/logoSSM.webp',
                        height: 24,
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox.shrink(),
                      ),
                    ),
                  ],
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
                  ticketData['queue_number']?.toString() ?? '-',
                ),
                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                _buildInfoRow('Jenis Servis', ticketData['service_type'] ?? '-'),
                const SizedBox(height: 16),
                _buildInfoRow(
                  'Jadwal',
                  '${ticketData['service_date'] ?? ''} ${ticketData['service_time'] ?? ''}',
                ),
                const SizedBox(height: 16),
                _buildInfoRow('Cabang', ticketData['branch'] ?? 'Pusat'),

                if (ticketData['complaint_notes'] != null) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow('Keluhan', ticketData['complaint_notes']),
                ],

                // Itemized Service Details
                if (ticketData['service_notes'] != null) ...[
                  const Divider(height: 32, color: Color(0xFFF1F5F9)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Rincian Pekerjaan & Suku Cadang',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildItemizedList(ticketData['service_notes']),
                ],

                const Divider(height: 32, color: Color(0xFFF1F5F9)),
                _buildStatusRow(status, ticketData['payment_status']),
              ],
            ),
          ),

          // Bottom Tear Edge Decor
          _buildTearEdge(),

          // Footer Section (Total Cost)
          if (ticketData['estimated_cost'] != null || ticketData['total_cost'] != null)
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
                    status == 'completed' ? 'Total Biaya' : 'Estimasi Biaya',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    'Rp ${ticketData['total_cost'] ?? ticketData['estimated_cost']}',
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

  Widget _buildStatusRow(String status, String? paymentStatus) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'completed':
      case 'selesai':
        statusColor = Colors.green;
        statusText = paymentStatus == 'paid' ? 'Selesai & Lunas' : 'Selesai (Belum Bayar)';
        break;
      case 'pending':
      case 'menunggu':
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case 'in_progress':
        statusColor = Colors.blue;
        statusText = 'Sedang Dikerjakan';
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

  Widget _buildItemizedList(dynamic serviceNotes) {
    try {
      final List<dynamic> items = serviceNotes is String 
          ? jsonDecode(serviceNotes) 
          : serviceNotes;
      
      return Column(
        children: items.map((item) => _buildItemRow(
          item['name'] ?? 'Item',
          item['qty']?.toString() ?? '1',
          item['price']?.toString() ?? '0',
        )).toList(),
      );
    } catch (e) {
      return Text(
        serviceNotes.toString(),
        style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B)),
      );
    }
  }

  Widget _buildItemRow(String name, String qty, String price) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              name,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF1E293B)),
            ),
          ),
          Expanded(
            child: Text(
              'x$qty',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B)),
            ),
          ),
          Expanded(
            child: Text(
              'Rp $price',
              textAlign: TextAlign.right,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

