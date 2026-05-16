import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/order_provider.dart';
import '../../services/api_config.dart';
import 'package:intl/intl.dart';
import 'order_status_screen.dart';
import '../../widgets/custom_app_bar.dart';
import '../../utils/currency_util.dart';
import '../../widgets/shimmer_loading.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _selectedCategory = 'Semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<String> _categories = [
    'Semua',
    'Berjalan',
    'Selesai',
    'Dibatalkan',
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<OrderProvider>().initializeIfNeeded();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final orders = orderProvider.orders;

    // Filter logic
    final filteredOrders = orders.where((order) {
      final matchesSearch = order.id.toString().contains(_searchQuery) ||
          (order.motor?.name ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedCategory == 'Semua') return matchesSearch;
      if (_selectedCategory == 'Berjalan') {
        return matchesSearch &&
            order.status.toLowerCase() != 'completed' &&
            order.status.toLowerCase() != 'selesai' &&
            order.status.toLowerCase() != 'cancelled' &&
            order.status.toLowerCase() != 'dibatalkan';
      }
      if (_selectedCategory == 'Selesai') {
        return matchesSearch && (order.status.toLowerCase() == 'completed' || order.status.toLowerCase() == 'selesai');
      }
      if (_selectedCategory == 'Dibatalkan') {
        return matchesSearch && (order.status.toLowerCase() == 'cancelled' || order.status.toLowerCase() == 'dibatalkan');
      }
      return matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(showLogo: false, title: 'Riwayat Pesanan'),
      body: Column(
        children: [
          _buildSearchAndFilter(),
          Expanded(
            child: orderProvider.isLoading
                ? _buildShimmerOrderList()
                : orderProvider.errorMessage != null
                    ? _buildErrorState(orderProvider.errorMessage!)
                    : filteredOrders.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: () => orderProvider.fetchOrderHistory(),
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: filteredOrders.length,
                              itemBuilder: (context, index) {
                                return _buildOrderCard(filteredOrders[index]);
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari ID Pesanan atau Nama Unit...',
                  hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ),
          // Categories
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCategory = cat);
                    },
                    labelStyle: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? Colors.white : const Color(0xFF64748B),
                    ),
                    selectedColor: const Color(0xFF2563EB),
                    backgroundColor: const Color(0xFFF1F5F9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    side: BorderSide.none,
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final statusColor = _getStatusColor(order.status);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OrderStatusScreen(order: order)),
          );
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // Header: Date & Status
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            order.transactionType == 'CREDIT' ? Icons.credit_card : Icons.payments_outlined,
                            size: 14,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            dateFormat.format(order.createdAt),
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF94A3B8),
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor.withOpacity(0.2)),
                    ),
                    child: Text(
                      order.statusText.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 9,
                        color: statusColor,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Middle: Motor Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      image: order.motor?.imagePath != null
                          ? DecorationImage(
                              image: CachedNetworkImageProvider(ApiConfig.sanitizeUrl(order.motor!.imagePath!)!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: order.motor?.imagePath == null ? const Icon(Icons.motorcycle, color: Color(0xFFCBD5E1)) : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ID-${order.id}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.motor?.name ?? 'Unit SRB Motor',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E293B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          CurrencyUtil.format(order.motor?.price ?? 0),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF2563EB),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFFE2E8F0)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Footer: Branch & Action
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.storefront_outlined, size: 14, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 6),
                  Text(
                    order.branchCode ?? 'Pusat',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Detail Status',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: const Color(0xFF2563EB),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward, size: 12, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.receipt_long_outlined, size: 60, color: const Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 24),
          Text(
            'Tidak ada pesanan',
            style: GoogleFonts.inter(
              fontSize: 20,
              color: const Color(0xFF1E293B),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pesanan yang Anda cari tidak ditemukan.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          Text(
            'Waduh, ada masalah!',
            style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(message, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () => context.read<OrderProvider>().fetchOrderHistory(),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new_order':
        return const Color(0xFF2563EB); // Blue
      case 'pending':
      case 'menunggu_pembayaran':
      case 'waiting_payment':
        return const Color(0xFFF59E0B); // Amber
      case 'completed':
      case 'selesai':
        return const Color(0xFF10B981); // Emerald
      case 'cancelled':
      case 'dibatalkan':
        return const Color(0xFFEF4444); // Red
      case 'unit_preparation':
      case 'persiapan_unit':
        return const Color(0xFF8B5CF6); // Violet
      case 'ready_for_delivery':
      case 'siap_dikirim':
        return const Color(0xFF06B6D4); // Cyan
      case 'dalam_pengiriman':
        return const Color(0xFFF43F5E); // Rose
      default:
        return const Color(0xFF64748B); // Slate
    }
  }

  Widget _buildShimmerOrderList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: 5,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: true,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        );
      },
    );
  }
}
