import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import '../../models/installment.dart';
import '../../providers/order_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../services/api_config.dart';
import 'payment_details_screen.dart';

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
      // Get the latest version of this order from provider
      final latestOrder = orderProvider.orders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      );
      // Proactively sync with Midtrans for all pending installments
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

    if (result['success'] && result['redirect_url'] != null) {
      final uri = Uri.parse(result['redirect_url']);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Gagal membuat link pembayaran')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMMM yyyy, HH:mm');

    return Selector<OrderProvider, OrderModel>(
      selector: (context, provider) => provider.orders.firstWhere(
        (o) => o.id == widget.order.id,
        orElse: () => widget.order,
      ),
      builder: (context, currentOrder, child) {
        final _currentOrder = currentOrder; // Shadowing for sub-builders
        final isLoading = context.select<OrderProvider, bool>((p) => p.isLoading) || _isRefreshing;

        return Stack(
          children: [
            Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: AppBar(
                title: Text('Detail Pesanan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                backgroundColor: Colors.white,
                surfaceTintColor: Colors.white,
                elevation: 0,
                centerTitle: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2563EB)),
                    onPressed: _refresh,
                    tooltip: 'Refresh Status',
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: _refresh,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Transaction ID & Status Badge
                      _buildHeaderSection(_currentOrder),
                      const SizedBox(height: 24),

                      // 2. Main Call to Action (Payment)
                      if (_currentOrder.status != 'completed' && _currentOrder.status != 'cancelled')
                        _buildPaymentCTA(_currentOrder),
                      const SizedBox(height: 24),

                      // 3. Motor Info Card
                      _buildMotorCard(_currentOrder, currencyFormat),
                      const SizedBox(height: 24),

                      // 4. Payment Summary (Booking Fee & Pelunasan)
                      _buildPaymentSection(_currentOrder, currencyFormat),
                      const SizedBox(height: 24),

                      // 5. Timeline Status
                      _buildTimelineSection(_currentOrder, dateFormat),
                      const SizedBox(height: 24),

                      // 6. Customer Details Card
                      _buildCustomerInfoCard(_currentOrder),
                      const SizedBox(height: 24),

                      // 7. Cancel Button (conditional)
                      if (_isCancellable(_currentOrder)) _buildCancelButton(_currentOrder),
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

  Widget _buildHeaderSection(OrderModel _currentOrder) {
    Color statusColor;
    String statusText = _currentOrder.statusText;
    
    switch (_currentOrder.status.toLowerCase()) {
      case 'new_order': statusColor = Colors.blue; break;
      case 'pending': 
      case 'waiting_payment':
        statusColor = Colors.orange; break;
      case 'completed': statusColor = Colors.green; break;
      case 'cancelled': 
      case 'dibatalkan':
        statusColor = Colors.red; break;
      case 'pembayaran_dikonfirmasi':
      case 'unit_preparation':
      case 'ready_for_delivery':
      case 'dalam_pengiriman':
        statusColor = Colors.blueAccent; break;
      default: statusColor = Colors.grey;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID PESANAN', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1)),
            Text('#SRB-${_currentOrder.id}', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: statusColor.withOpacity(0.3)),
          ),
          child: Text(
            statusText,
            style: GoogleFonts.outfit(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildMotorCard(OrderModel _currentOrder, NumberFormat format) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          Container(
            width: 100,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              image: _currentOrder.motor?.imagePath != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(ApiConfig.sanitizeUrl(_currentOrder.motor!.imagePath!)!), 
                      fit: BoxFit.cover,
                      onError: (exception, stackTrace) => debugPrint('Image load error: $exception'),
                    )
                  : null,
            ),
            child: _currentOrder.motor?.imagePath == null 
                ? const Icon(Icons.motorcycle, color: Colors.grey) 
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_currentOrder.motor?.brand.toUpperCase() ?? 'SRB MOTOR', style: GoogleFonts.outfit(fontSize: 10, color: Colors.blue, fontWeight: FontWeight.bold)),
                Text(_currentOrder.motor?.name ?? 'Unit Motor', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(format.format(_currentOrder.motor?.price ?? 0), style: GoogleFonts.outfit(color: const Color(0xFF2563EB), fontWeight: FontWeight.bold)),
                if (_currentOrder.motorColor != null)
                  Text('Warna: ${_currentOrder.motorColor}', style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection(OrderModel _currentOrder, NumberFormat format) {
    double total = _currentOrder.motor?.price ?? 0;
    double bFee = _currentOrder.bookingFee;
    double remaining = total - bFee;

    InstallmentModel? bookingInstallment;
    InstallmentModel? remainingInstallment;

    if (_currentOrder.installments.isNotEmpty) {
      bookingInstallment = _currentOrder.installments.firstWhere((i) => i.installmentNumber == 0, orElse: () => _currentOrder.installments.first);
      if (_currentOrder.installments.length > 1) {
         remainingInstallment = _currentOrder.installments.firstWhere((i) => i.installmentNumber == 1, orElse: () => _currentOrder.installments.last);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('RINCIAN PEMBAYARAN', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700], letterSpacing: 0.5)),
            GestureDetector(
              onTap: () {
                // Future: Show full invoice/receipt
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fitur invoice segera hadir')));
              },
              child: Text('Lihat Invoice', style: GoogleFonts.outfit(fontSize: 12, color: const Color(0xFF2563EB), fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              _buildPaymentRow('Harga Unit', format.format(total), isBold: true),
              const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFF1F5F9))),
              
              const SizedBox(height: 8),
              _buildPaymentItemWithStatus(
                label: 'Booking Fee', 
                amount: format.format(bFee), 
                status: bookingInstallment?.status ?? 'Pending',
                canPay: bookingInstallment != null && _canPayInstallment(bookingInstallment.status),
                onPay: () => _handlePayment(bookingInstallment!),
              ),
              
              const SizedBox(height: 16),
              _buildPaymentItemWithStatus(
                label: 'Sisa Pelunasan', 
                amount: format.format(remaining), 
                status: remainingInstallment?.status ?? (_currentOrder.status == 'completed' ? 'paid' : 'unpaid'),
                canPay: remainingInstallment != null && _canPayInstallment(remainingInstallment.status),
                onPay: () => _handlePayment(remainingInstallment!),
              ),
              
              if (_currentOrder.status == 'completed')
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_user, color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text('Transaksi telah lunas sepenuhnya', style: GoogleFonts.outfit(color: Colors.green[700], fontWeight: FontWeight.bold, fontSize: 13)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(color: Colors.grey[600], fontSize: 14)),
        Text(value, style: GoogleFonts.outfit(fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 14, color: isBold ? Colors.black : Colors.grey[800])),
      ],
    );
  }

  Widget _buildPaymentItemWithStatus({required String label, required String amount, required String status, bool canPay = false, VoidCallback? onPay}) {
    Color statusColor;
    String statusLabel = status.toUpperCase();
    
    switch (status.toLowerCase()) {
      case 'paid': statusColor = Colors.green; statusLabel = 'LUNAS'; break;
      case 'pending': case 'pending_payment': statusColor = Colors.orange; statusLabel = 'MENUNGGU'; break;
      case 'unpaid': statusColor = Colors.red; statusLabel = 'BELUM BAYAR'; break;
      default: statusColor = Colors.grey;
    }
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey[600])),
                Text(amount, style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8), border: Border.all(color: statusColor.withOpacity(0.2))),
              child: Text(statusLabel, style: GoogleFonts.outfit(color: statusColor, fontSize: 10, fontWeight: FontWeight.w900)),
            ),
          ],
        ),
        if (canPay)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onPay,
                icon: const Icon(Icons.payment, size: 18),
                label: const Text('BAYAR SEKARANG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTimelineSection(OrderModel _currentOrder, DateFormat format) {
    final currentStatusRaw = _currentOrder.status.toLowerCase();
    final isCancelled = currentStatusRaw == 'cancelled' || currentStatusRaw == 'dibatalkan';
    final isRejected = currentStatusRaw == 'ditolak';
    final isTerminal = isCancelled || isRejected;

    // Full status ordered list — matches Transaction model statusMap
    final List<Map<String, dynamic>> cashSteps = [
      {'key': 'new_order',               'label': 'Pesanan Masuk',            'icon': Icons.assignment_outlined},
      {'key': 'waiting_payment',          'label': 'Menunggu Pembayaran',      'icon': Icons.account_balance_wallet_outlined},
      {'key': 'pembayaran_dikonfirmasi',  'label': 'Pembayaran Dikonfirmasi',  'icon': Icons.verified_outlined},
      {'key': 'unit_preparation',         'label': 'Motor Disiapkan',          'icon': Icons.settings_suggest_outlined},
      {'key': 'ready_for_delivery',       'label': 'Motor Siap Dikirim/Ambil', 'icon': Icons.inventory_2_outlined},
      {'key': 'dalam_pengiriman',         'label': 'Dalam Pengiriman',         'icon': Icons.local_shipping_outlined},
      {'key': 'completed',               'label': 'Pesanan Selesai',           'icon': Icons.check_circle_outline},
    ];

    final List<Map<String, dynamic>> creditSteps = [
      {'key': 'new_order',               'label': 'Pesanan Masuk',            'icon': Icons.assignment_outlined},
      {'key': 'menunggu_persetujuan',    'label': 'Verifikasi Berkas',        'icon': Icons.folder_open_outlined},
      {'key': 'data_tidak_valid',        'label': 'Perbaiki Dokumen',         'icon': Icons.edit_document, 'isWarning': true},
      {'key': 'dikirim_ke_surveyor',     'label': 'Proses Surveyor',          'icon': Icons.person_search_outlined},
      {'key': 'jadwal_survey',           'label': 'Jadwal Survey',            'icon': Icons.calendar_month_outlined},
      {'key': 'waiting_credit_approval', 'label': 'Menunggu Persetujuan',   'icon': Icons.fact_check_outlined},
      {'key': 'disetujui',               'label': 'Kredit Disetujui',         'icon': Icons.thumb_up_outlined},
      {'key': 'unit_preparation',        'label': 'Motor Disiapkan',          'icon': Icons.settings_suggest_outlined},
      {'key': 'ready_for_delivery',      'label': 'Motor Siap Dikirim/Ambil', 'icon': Icons.inventory_2_outlined},
      {'key': 'dalam_pengiriman',        'label': 'Dalam Pengiriman',         'icon': Icons.local_shipping_outlined},
      {'key': 'completed',              'label': 'Pesanan Selesai',            'icon': Icons.check_circle_outline},
    ];

    // Select steps based on transaction type
    final steps = (_currentOrder.transactionType?.toUpperCase() == 'CREDIT') 
        ? creditSteps 
        : cashSteps;
        
    final currentStatus = _currentOrder.status.toLowerCase();
    final currentIdx = steps.indexWhere((s) => s['key'] == currentStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PROGRESS PESANAN', style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700])),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: isTerminal
              ? Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (isRejected ? Colors.orange : Colors.red).withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isRejected ? Icons.block_flipped : Icons.cancel_outlined,
                        color: isRejected ? Colors.orange : Colors.red,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isRejected ? 'Kredit Ditolak' : 'Pesanan Dibatalkan',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isRejected ? Colors.orange : Colors.red,
                            ),
                          ),
                          Text(
                            isRejected 
                                ? 'Maaf, pengajuan kredit Anda belum disetujui.' 
                                : 'Pesanan ini tidak dapat dilanjutkan.',
                            style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            format.format(_currentOrder.createdAt),
                            style: GoogleFonts.outfit(fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              : Column(
                  children: steps.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final step = entry.value;
                    final isCompleted = currentIdx >= idx;
                    final isCurrent = currentIdx == idx;
                    final isLast = idx == steps.length - 1;
                    final isWarning = step['isWarning'] == true;

                    Color dotColor = isCompleted
                        ? (isWarning && isCurrent ? Colors.orange : const Color(0xFF2563EB))
                        : Colors.grey.shade200;

                    return _buildTimelineTile(
                      title: step['label'] as String,
                      subtitle: isCurrent
                          ? 'Status saat ini'
                          : isCompleted
                              ? 'Selesai'
                              : 'Menunggu',
                      icon: step['icon'] as IconData,
                      isFirst: idx == 0,
                      isLast: isLast,
                      isCompleted: isCompleted,
                      isCurrent: isCurrent,
                      dotColor: dotColor,
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
    bool isFirst = false,
    bool isLast = false,
    bool isCompleted = false,
    bool isCurrent = false,
    Color? dotColor,
  }) {
    final color = dotColor ?? (isCompleted ? const Color(0xFF2563EB) : Colors.grey.shade200);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color,
                border: isCurrent ? Border.all(color: const Color(0xFF2563EB), width: 2.5) : null,
                boxShadow: isCurrent
                    ? [BoxShadow(color: const Color(0xFF2563EB).withOpacity(0.3), blurRadius: 8)]
                    : null,
              ),
              child: Icon(
                isCompleted ? Icons.check : icon,
                size: 15,
                color: isCompleted ? Colors.white : Colors.grey.shade400,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 44,
                color: isCompleted ? const Color(0xFF2563EB).withOpacity(0.3) : Colors.grey.shade100,
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w600,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isCurrent
                        ? const Color(0xFF2563EB)
                        : isCompleted
                            ? Colors.grey.shade500
                            : Colors.grey.shade300,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfoCard(OrderModel _currentOrder) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_pin_outlined, color: Colors.blue),
              const SizedBox(width: 12),
              Text('Informasi Pelanggan', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow('Nama', _currentOrder.customerName),
          _buildInfoRow('Nomor HP', _currentOrder.customerPhone),
          if (_currentOrder.customerNik != null) _buildInfoRow('NIK', _currentOrder.customerNik!),
          _buildInfoRow('Alamat', _currentOrder.customerAddress),
          if (_currentOrder.deliveryMethod != null) _buildInfoRow('Metode', _currentOrder.deliveryMethod!),
          if (_currentOrder.notes != null && _currentOrder.notes!.isNotEmpty) _buildInfoRow('Catatan', _currentOrder.notes!),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: GoogleFonts.outfit(fontSize: 13, color: Colors.grey))),
          Expanded(child: Text(value, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildPaymentCTA(OrderModel _currentOrder) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentDetailsScreen(order: _currentOrder)));
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
                      Text('Lanjutkan Pembayaran', style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('Selesaikan cicilan / booking fee Anda', style: GoogleFonts.outfit(color: Colors.white.withOpacity(0.8), fontSize: 12)),
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

  bool _isCancellable(OrderModel _currentOrder) {
    final status = _currentOrder.status.toLowerCase();
    // Cash statuses
    if (status == 'new_order' || status == 'waiting_payment') return true;
    // Credit statuses
    if (status == 'menunggu_persetujuan' || status == 'waiting_credit_approval') return true;
    return false;
  }

  /// Returns true if the given installment status allows payment
  bool _canPayInstallment(String status) {
    final s = status.toLowerCase();
    return s == 'unpaid' || s == 'pending' || s == 'pending_payment' || s == 'waiting_approval';
  }

  Widget _buildCancelButton(OrderModel _currentOrder) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () => _showCancelDialog(_currentOrder),
        icon: const Icon(Icons.cancel_outlined, color: Colors.red),
        label: Text('Batalkan Pesanan', style: GoogleFonts.outfit(color: Colors.red, fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.red.withOpacity(0.2))),
        ),
      ),
    );
  }

  void _showCancelDialog(OrderModel _currentOrder) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 40),
              ),
              const SizedBox(height: 24),
              Text(
                'Batalkan Pesanan?',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Text(
                'Gunakan pembatalan hanya jika Anda yakin. Tindakan ini tidak dapat diurungkan.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF64748B), height: 1.5),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Kembali', style: GoogleFonts.outfit(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _handleCancel(_currentOrder);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text('Ya, Batalkan', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancel(OrderModel _currentOrder) async {
    final orderProvider = context.read<OrderProvider>();
    final result = await orderProvider.cancelOrder(_currentOrder.id, "Dibatalkan melalui aplikasi mobile");

    if (mounted) {
      if (result['success']) {
        _showSuccessCancelDialog();
        await orderProvider.fetchOrderHistory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showSuccessCancelDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 48),
              ),
              const SizedBox(height: 24),
              Text(
                'Berhasil Dibatalkan',
                style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
              ),
              const SizedBox(height: 12),
              Text(
                'Pesanan Anda telah berhasil dibatalkan dari sistem kami.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 14, color: const Color(0xFF64748B)),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Back to history
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('OK, MENGERTI', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
