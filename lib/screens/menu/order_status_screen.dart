import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/installment.dart';
import '../../providers/order_provider.dart';
import '../../main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/motor_provider.dart';
import '../../services/api_config.dart';
import 'payment_details_screen.dart';
import '../../utils/currency_util.dart';

class OrderStatusScreen extends StatefulWidget {
  final OrderModel order;
  const OrderStatusScreen({super.key, required this.order});

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    try {
      final orderProvider = context.read<OrderProvider>();
      final latestOrder = orderProvider.orders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      );
      await orderProvider.syncOrderDetails(latestOrder);
    } catch (e) {
      debugPrint('Error refreshing order: $e');
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  void _handlePayment(InstallmentModel installment) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.getInstallmentPaymentUrl(installment.id);

    if (result['success'] && result['snap_token'] != null) {
      orderProvider.startPollingStatus(installment.id, widget.order.id);
      try {
        final token = result['snap_token'];
        midtrans?.startPaymentUiFlow(token: token);
      } catch (e) {
        debugPrint('Error launching Midtrans SDK: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Gagal membuka halaman pembayaran native')),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal membuat token pembayaran')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return Selector<OrderProvider, OrderModel>(
      selector: (context, provider) => provider.orders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      ),
      builder: (context, currentOrder, child) {
        final isLoading = context.select<OrderProvider, bool>((p) => p.isLoading) || _isRefreshing;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: Text(
                  'Detail Pesanan',
                  style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2563EB), size: 20),
                    onPressed: _refresh,
                    tooltip: 'Refresh Status',
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Transaction ID & Status Badge
                      _buildHeaderSection(currentOrder),
                      const SizedBox(height: 24),

                      // 2. Main Call to Action (Payment)
                      if (currentOrder.status != 'completed' && currentOrder.status != 'cancelled')
                        _buildPaymentCTA(currentOrder),
                      const SizedBox(height: 24),

                      // 3. Motor Info Card
                      _buildMotorCard(currentOrder),
                      const SizedBox(height: 24),

                      // 4. Timeline Status
                      _buildTimelineSection(currentOrder, dateFormat),
                      const SizedBox(height: 24),

                      // 5. Payment Summary
                      _buildPaymentSection(currentOrder),
                      const SizedBox(height: 24),

                      // 6. Customer Details Card
                      _buildCustomerInfoCard(currentOrder),
                      const SizedBox(height: 24),

                      // 7. Cancel Button
                      if (_isCancellable(currentOrder)) _buildCancelButton(currentOrder),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.1),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }

  Widget _buildHeaderSection(OrderModel currentOrder) {
    Color statusColor;
    String statusText = currentOrder.status.toUpperCase();

    switch (currentOrder.status.toLowerCase()) {
      case 'completed':
      case 'selesai':
        statusColor = const Color(0xFF10B981);
        statusText = 'SELESAI';
        break;
      case 'pending':
      case 'new_order':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'PESANAN BARU';
        break;
      case 'waiting_payment':
      case 'menunggu_pembayaran':
        statusColor = const Color(0xFF2563EB);
        statusText = 'MENUNGGU BAYAR';
        break;
      case 'cancelled':
      case 'dibatalkan':
        statusColor = const Color(0xFFEF4444);
        statusText = 'DIBATALKAN';
        break;
      case 'ready_for_delivery':
      case 'siap_dikirim':
        statusColor = const Color(0xFF06B6D4);
        statusText = 'SIAP KIRIM';
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ID PESANAN',
                    style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '#SRB-${currentOrder.id}',
                    style: GoogleFonts.jetBrainsMono(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: statusColor.withOpacity(0.2)),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.inter(color: statusColor, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSmallBadge(
                currentOrder.transactionType == 'CREDIT' ? 'PEMBELIAN KREDIT' : 'PEMBELIAN TUNAI',
                currentOrder.transactionType == 'CREDIT' ? Colors.deepPurple : Colors.blueGrey,
              ),
              const SizedBox(width: 8),
              _buildSmallBadge(
                currentOrder.branchCode ?? 'SEMUA CABANG',
                const Color(0xFF2563EB),
                icon: Icons.store_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSmallBadge(String text, Color color, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            text,
            style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMotorCard(OrderModel currentOrder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              image: currentOrder.motor?.imagePath != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(ApiConfig.sanitizeUrl(currentOrder.motor!.imagePath!)!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: currentOrder.motor?.imagePath == null ? const Icon(Icons.motorcycle, color: Color(0xFFCBD5E1)) : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentOrder.motor?.brand.toUpperCase() ?? 'SRB MOTOR',
                  style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                const SizedBox(height: 4),
                Text(
                  currentOrder.motor?.name ?? 'Unit Motor',
                  style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyUtil.format(currentOrder.motor?.price ?? 0),
                  style: GoogleFonts.inter(color: const Color(0xFF2563EB), fontWeight: FontWeight.w800, fontSize: 16),
                ),
                if (currentOrder.motorColor != null) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      'Warna: ${currentOrder.motorColor}',
                      style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF64748B), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineSection(OrderModel currentOrder, DateFormat format) {
    final List<Map<String, dynamic>> cashSteps = [
      {'key': 'new_order', 'label': 'Pesanan Masuk', 'icon': Icons.assignment_outlined},
      {'key': 'waiting_payment', 'label': 'Menunggu Pembayaran', 'icon': Icons.account_balance_wallet_outlined},
      {'key': 'pembayaran_dikonfirmasi', 'label': 'Pembayaran Dikonfirmasi', 'icon': Icons.verified_outlined},
      {'key': 'unit_preparation', 'label': 'Motor Disiapkan', 'icon': Icons.settings_suggest_outlined},
      {'key': 'ready_for_delivery', 'label': 'Motor Siap Dikirim/Ambil', 'icon': Icons.inventory_2_outlined},
      {'key': 'completed', 'label': 'Pesanan Selesai', 'icon': Icons.check_circle_outline},
    ];

    final List<Map<String, dynamic>> creditSteps = [
      {'key': 'new_order', 'label': 'Pesanan Masuk', 'icon': Icons.assignment_outlined},
      {'key': 'menunggu_persetujuan', 'label': 'Verifikasi Berkas', 'icon': Icons.folder_open_outlined},
      {'key': 'dikirim_ke_surveyor', 'label': 'Proses Surveyor', 'icon': Icons.person_search_outlined},
      {'key': 'waiting_credit_approval', 'label': 'Menunggu Persetujuan', 'icon': Icons.fact_check_outlined},
      {'key': 'disetujui', 'label': 'Kredit Disetujui', 'icon': Icons.thumb_up_outlined},
      {'key': 'unit_preparation', 'label': 'Motor Disiapkan', 'icon': Icons.settings_suggest_outlined},
      {'key': 'completed', 'label': 'Pesanan Selesai', 'icon': Icons.check_circle_outline},
    ];

    final steps = (currentOrder.transactionType?.toUpperCase() == 'CREDIT') ? creditSteps : cashSteps;
    final currentStatus = currentOrder.status.toLowerCase();
    final currentIdx = steps.indexWhere((s) => s['key'] == currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'PROGRES PESANAN',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
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
            children: steps.asMap().entries.map((entry) {
              final idx = entry.key;
              final step = entry.value;
              final isCompleted = currentIdx >= idx;
              final isCurrent = currentIdx == idx;
              final isLast = idx == steps.length - 1;

              return _buildTimelineTile(
                title: step['label'] as String,
                subtitle: isCurrent ? 'Status saat ini' : (isCompleted ? 'Selesai' : 'Menunggu'),
                icon: step['icon'] as IconData,
                isLast: isLast,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineTile({
    required String title,
    required String subtitle,
    required IconData icon,
    bool isLast = false,
    bool isCompleted = false,
    bool isCurrent = false,
  }) {
    final Color activeColor = const Color(0xFF2563EB);
    final Color inactiveColor = const Color(0xFFE2E8F0);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? activeColor : Colors.white,
                border: Border.all(color: isCompleted ? activeColor : inactiveColor, width: 2),
                boxShadow: isCurrent ? [BoxShadow(color: activeColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                size: 16,
                color: isCompleted ? Colors.white : const Color(0xFF94A3B8),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? activeColor.withOpacity(0.2) : inactiveColor,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w600,
                  color: isCompleted ? const Color(0xFF1E293B) : const Color(0xFF94A3B8),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: isCurrent ? activeColor : const Color(0xFF94A3B8),
                  fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (!isLast) const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSection(OrderModel currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RINCIAN PEMBAYARAN',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
              ),
              TextButton.icon(
                onPressed: () => _handleInvoice(currentOrder),
                icon: const Icon(Icons.description_outlined, size: 14),
                label: Text('Invoice', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(foregroundColor: const Color(0xFF2563EB), padding: EdgeInsets.zero),
              ),
            ],
          ),
        ),
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
            children: [
              _buildPaymentItem('Harga Unit', CurrencyUtil.format(currentOrder.motor?.price ?? 0), isBold: true),
              const SizedBox(height: 16),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              const SizedBox(height: 16),
              _buildPaymentStatusItem('Booking Fee', CurrencyUtil.format(currentOrder.bookingFee), currentOrder.installments.isNotEmpty ? currentOrder.installments.first.status : 'Pending'),
              const SizedBox(height: 16),
              _buildPaymentStatusItem('Sisa Pelunasan', CurrencyUtil.format((currentOrder.motor?.price ?? 0) - currentOrder.bookingFee), currentOrder.status == 'completed' ? 'PAID' : 'UNPAID'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentItem(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
        Text(value, style: GoogleFonts.inter(fontSize: 14, fontWeight: isBold ? FontWeight.w800 : FontWeight.w500, color: const Color(0xFF1E293B))),
      ],
    );
  }

  Widget _buildPaymentStatusItem(String label, String value, String status) {
    Color statusColor = status.toLowerCase() == 'paid' ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
            Text(value, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(status.toUpperCase(), style: GoogleFonts.inter(fontSize: 9, color: statusColor, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(OrderModel currentOrder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'INFORMASI PENGIRIMAN',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF64748B), letterSpacing: 1),
          ),
        ),
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
            children: [
              _buildInfoRow(Icons.person_outline, 'Nama Penerima', currentOrder.customerName),
              _buildInfoRow(Icons.phone_android_outlined, 'Nomor Telepon', currentOrder.customerPhone),
              _buildInfoRow(Icons.location_on_outlined, 'Alamat Lengkap', currentOrder.customerAddress),
              if (currentOrder.deliveryMethod != null) _buildInfoRow(Icons.local_shipping_outlined, 'Metode Pengiriman', currentOrder.deliveryMethod!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF1E293B), fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCTA(OrderModel currentOrder) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentDetailsScreen(order: currentOrder)));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.payment_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lanjutkan Pembayaran', style: GoogleFonts.inter(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Selesaikan tagihan pesanan Anda', style: GoogleFonts.inter(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelButton(OrderModel currentOrder) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: () => _showCancelDialog(currentOrder),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFFEF4444), padding: const EdgeInsets.symmetric(vertical: 16)),
        child: Text('Batalkan Pesanan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13)),
      ),
    );
  }

  void _handleInvoice(OrderModel currentOrder) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.getInvoiceUrl(currentOrder.id);
    if (result['success'] && result['url'] != null) {
      final uri = Uri.parse(ApiConfig.sanitizeUrl(result['url'])!);
      if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  bool _isCancellable(OrderModel currentOrder) {
    final status = currentOrder.status.toLowerCase();
    return status == 'new_order' || status == 'waiting_payment' || status == 'menunggu_persetujuan';
  }

  void _showCancelDialog(OrderModel currentOrder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Konfirmasi Pembatalan', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin membatalkan pesanan ini? Tindakan ini tidak dapat diurungkan.', style: GoogleFonts.inter(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Kembali', style: GoogleFonts.inter(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleCancel(currentOrder);
            },
            child: Text('Ya, Batalkan', style: GoogleFonts.inter(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleCancel(OrderModel currentOrder) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.cancelOrder(currentOrder.id, "Dibatalkan oleh pengguna");
    if (mounted && result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pesanan berhasil dibatalkan')));
      Navigator.pop(context);
    }
  }
}
