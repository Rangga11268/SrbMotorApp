import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/installment.dart';
import '../../providers/order_provider.dart';
import '../../main.dart'; // Added for global midtrans instance

class PaymentDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const PaymentDetailsScreen({super.key, required this.order});

  void _handlePayment(BuildContext context, InstallmentModel installment) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.getInstallmentPaymentUrl(installment.id);

    if (result['success'] && result['snap_token'] != null) {
      // 1. Close the Payment Details screen immediately
      Navigator.of(context).pop();

      // 2. Launch the Native SDK flow over the main Detail screen
      try {
        final token = result['snap_token'];
        midtrans?.startPaymentUiFlow(token: token);
      } catch (e) {
        debugPrint('Error launching Midtrans SDK: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka halaman pembayaran native')),
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

  @override
  Widget build(BuildContext context) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Halaman Pembayaran', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
            onPressed: () => context.read<OrderProvider>().syncOrderDetails(order),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: Selector<OrderProvider, OrderModel>(
        selector: (context, provider) => provider.orders.firstWhere(
          (o) => o.id == order.id,
          orElse: () => order,
        ),
        builder: (context, currentOrder, child) {
          final isLoading = context.select<OrderProvider, bool>((p) => p.isLoading);

          double total = currentOrder.motor?.price ?? 0;
          double bFee = currentOrder.bookingFee;
          double remaining = total - bFee;

          InstallmentModel? bookingInstallment;
          InstallmentModel? remainingInstallment;

          if (currentOrder.installments.isNotEmpty) {
            bookingInstallment = currentOrder.installments.firstWhere((i) => i.installmentNumber == 0, orElse: () => currentOrder.installments.first);
            if (currentOrder.installments.length > 1) {
              remainingInstallment = currentOrder.installments.firstWhere((i) => i.installmentNumber == 1, orElse: () => currentOrder.installments.last);
            }
          }

          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Receipt Header
                    Center(
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: Colors.blue[50], shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long_outlined, color: Colors.blue, size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text('Rincian Tagihan', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                          Text('#SRB-${currentOrder.id}', style: GoogleFonts.outfit(color: Colors.grey)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // 2. Breakdown Table
                    Text('DETAIL PESANAN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    _buildRow('Unit Motor', currentOrder.motor?.name ?? 'Unit'),
                    if (currentOrder.motorColor != null) _buildRow('Warna', currentOrder.motorColor!),
                    _buildRow('Harga Unit', format.format(total), isBold: true),
                    
                    const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider(height: 1)),
                    
                    Text('STATUS PEMBAYARAN', style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1)),
                    const SizedBox(height: 16),
                    
                    _buildPaymentCard(
                      context,
                      label: 'Booking Fee',
                      amount: format.format(bFee),
                      status: bookingInstallment?.status ?? 'Pending',
                      installment: bookingInstallment,
                    ),
                    const SizedBox(height: 16),
                    _buildPaymentCard(
                      context,
                      label: 'Sisa Pelunasan',
                      amount: format.format(remaining),
                      status: remainingInstallment?.status ?? 'Unpaid',
                      installment: remainingInstallment,
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // 3. Security Note
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange[100]!)),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Colors.orange, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Pembayaran diproses secara aman melalui Midtrans. Status akan otomatis diperbarui setelah pembayaran sukses.',
                              style: GoogleFonts.outfit(fontSize: 12, color: Colors.orange[800], height: 1.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                Container(
                  color: Colors.white.withOpacity(0.5),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: Colors.grey[600])),
          Text(value, style: GoogleFonts.outfit(fontWeight: isBold ? FontWeight.bold : FontWeight.w500, fontSize: isBold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, {required String label, required String amount, required String status, InstallmentModel? installment}) {
    Color statusColor;
    String statusLabel = status.toUpperCase();
    bool isPaid = status.toLowerCase() == 'paid';
    bool canPay = installment != null && (
      status.toLowerCase() == 'unpaid' || 
      status.toLowerCase() == 'pending' || 
      status.toLowerCase() == 'pending_payment'
    );

    switch (status.toLowerCase()) {
      case 'paid': statusColor = Colors.green; break;
      case 'pending': case 'pending_payment': statusColor = Colors.orange; break;
      default: statusColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPaid ? Colors.green[100]! : Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600])),
                  Text(amount, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(statusLabel, style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (canPay)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handlePayment(context, installment),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text('BAYAR SEKARANG', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
