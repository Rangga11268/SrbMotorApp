import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../models/installment.dart';
import '../../providers/order_provider.dart';
import '../../main.dart';

class PaymentDetailsScreen extends StatelessWidget {
  final OrderModel order;
  const PaymentDetailsScreen({super.key, required this.order});

  void _handlePayment(BuildContext context, InstallmentModel installment) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.getInstallmentPaymentUrl(installment.id);

    if (result['success'] && result['snap_token'] != null) {
      Navigator.of(context).pop();
      orderProvider.startPollingStatus(installment.id, order.id);
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Tagihan Pembayaran', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,
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
                  children: [
                    // 1. Receipt Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: const Color(0xFF2563EB).withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF2563EB), size: 32),
                          ),
                          const SizedBox(height: 16),
                          Text('Rincian Tagihan', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
                          const SizedBox(height: 4),
                          Text('#SRB-${currentOrder.id}', style: GoogleFonts.jetBrainsMono(color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 2. Order Summary
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DETAIL PESANAN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
                          const SizedBox(height: 16),
                          _buildDetailRow('Unit Motor', currentOrder.motor?.name ?? 'Unit'),
                          _buildDetailRow('Harga Unit', format.format(total), isBold: true),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
                          Text('STATUS TAGIHAN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF94A3B8), letterSpacing: 1)),
                          const SizedBox(height: 16),
                          _buildPaymentCard(
                            context,
                            label: 'Booking Fee',
                            amount: format.format(bFee),
                            status: bookingInstallment?.status ?? 'Pending',
                            installment: bookingInstallment,
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentCard(
                            context,
                            label: 'Sisa Pelunasan',
                            amount: format.format(remaining),
                            status: remainingInstallment?.status ?? 'Unpaid',
                            installment: remainingInstallment,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // 3. Security Note
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_outlined, color: Color(0xFF10B981), size: 24),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              'Pembayaran aman melalui Midtrans. Status akan otomatis diperbarui.',
                              style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w500, height: 1.5),
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

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
          Text(value, style: GoogleFonts.inter(fontWeight: isBold ? FontWeight.w800 : FontWeight.w600, fontSize: isBold ? 15 : 14, color: const Color(0xFF1E293B))),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, {required String label, required String amount, required String status, InstallmentModel? installment}) {
    Color statusColor;
    bool isPaid = status.toLowerCase() == 'paid';
    bool canPay = installment != null && (status.toLowerCase() == 'unpaid' || status.toLowerCase() == 'pending' || status.toLowerCase() == 'pending_payment');

    switch (status.toLowerCase()) {
      case 'paid': statusColor = const Color(0xFF10B981); break;
      case 'pending': case 'pending_payment': statusColor = const Color(0xFFF59E0B); break;
      default: statusColor = const Color(0xFFEF4444);
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPaid ? const Color(0xFF10B981).withOpacity(0.1) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(amount, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(status.toUpperCase(), style: GoogleFonts.inter(color: statusColor, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
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
                  child: Text('BAYAR SEKARANG', style: GoogleFonts.inter(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1)),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
