import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/service_provider.dart';
import 'service_booking_screen.dart';
import 'service_ticket_screen.dart';
import 'package:intl/intl.dart';
import '../../widgets/shimmer_loading.dart';

class ServiceScreen extends StatefulWidget {
  const ServiceScreen({super.key});

  @override
  State<ServiceScreen> createState() => _ServiceScreenState();
}

class _ServiceScreenState extends State<ServiceScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) {
        context.read<ServiceProvider>().fetchHistory();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final serviceProvider = context.watch<ServiceProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeroBanner(),
                _buildServiceCategories(),
                _buildWhyChooseUs(),
                if (serviceProvider.isLoading)
                  _buildShimmerHistory()
                else if (serviceProvider.history.isNotEmpty)
                  _buildRecentHistory(serviceProvider),
                const SizedBox(height: 100), // Space for FAB-like button
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildBookingButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      title: Text(
        'LAYANAN SERVIS',
        style: GoogleFonts.outfit(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: const Color(0xFF0F172A),
          letterSpacing: 1.2,
        ),
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          color: const Color(0xFFE2E8F0),
          height: 1,
        ),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      height: 160,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
          image: AssetImage('assets/images/banner/banner_service.png'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.3),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF60A5FA).withOpacity(0.3)),
              ),
              child: Text(
                'PROMO BULAN INI',
                style: GoogleFonts.outfit(
                  fontSize: 9,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF60A5FA),
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
               'Servis Lengkap\nDiskon 20%',
              style: GoogleFonts.outfit(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Berlaku untuk semua jenis motor matic.',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
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

  Widget _buildServiceCategories() {
    final categories = [
      {
        'title': 'Servis Berkala',
        'desc': 'Pengecekan rutin & tune-up komponen motor.',
        'icon': Icons.build_circle_outlined,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Ganti Oli',
        'desc': 'Ganti oli mesin & oli gardan original.',
        'icon': Icons.opacity_outlined,
        'color': const Color(0xFFF97316),
      },
      {
        'title': 'Servis Berat',
        'desc': 'Overhaul mesin & perbaikan komponen inti.',
        'icon': Icons.handyman_outlined,
        'color': const Color(0xFFEF4444),
      },
      {
        'title': 'Cek Kelistrikan',
        'desc': 'Pengecekan aki, lampu, kabel & starter.',
        'icon': Icons.bolt_outlined,
        'color': const Color(0xFFEAB308),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSectionTitle('LAYANAN KAMI'),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final color = cat['color'] as Color;
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ServiceBookingScreen(
                      initialServiceType: cat['title'] as String,
                    ),
                  ),
                );
              },
              child: Container(
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        cat['icon'] as IconData,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      cat['title'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cat['desc'] as String,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildWhyChooseUs() {
    final benefits = [
      {
        'title': 'Mekanik Ahli',
        'subtitle': 'Teknisi bersertifikat resmi.',
        'icon': Icons.verified_user_outlined,
        'color': const Color(0xFF10B981),
      },
      {
        'title': 'Part Asli',
        'subtitle': 'Suku cadang 100% original.',
        'icon': Icons.auto_awesome_outlined,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Garansi Servis',
        'subtitle': 'Jaminan pengerjaan 7 hari.',
        'icon': Icons.security_outlined,
        'color': const Color(0xFF6366F1),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSectionTitle('KEUNGGULAN KAMI'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: benefits.length,
            itemBuilder: (context, index) {
               final b = benefits[index];
               final color = b['color'] as Color;
               return Container(
                 width: 220,
                 margin: const EdgeInsets.only(right: 12, bottom: 4),
                 padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                 decoration: BoxDecoration(
                   color: Colors.white,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: const Color(0xFFE2E8F0)),
                   boxShadow: [
                     BoxShadow(
                       color: Colors.black.withOpacity(0.01),
                       blurRadius: 6,
                       offset: const Offset(0, 3),
                     ),
                   ],
                 ),
                 child: Row(
                   children: [
                     Container(
                       padding: const EdgeInsets.all(8),
                       decoration: BoxDecoration(
                         color: color.withOpacity(0.08),
                         shape: BoxShape.circle,
                       ),
                       child: Icon(
                         b['icon'] as IconData,
                         color: color,
                         size: 18,
                       ),
                     ),
                     const SizedBox(width: 12),
                     Expanded(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         mainAxisAlignment: MainAxisAlignment.center,
                         children: [
                           Text(
                             b['title'] as String,
                             style: GoogleFonts.outfit(
                               fontSize: 12,
                               fontWeight: FontWeight.bold,
                               color: const Color(0xFF0F172A),
                             ),
                           ),
                           const SizedBox(height: 2),
                           Text(
                             b['subtitle'] as String,
                             style: GoogleFonts.outfit(
                               fontSize: 9,
                               fontWeight: FontWeight.w600,
                               color: const Color(0xFF64748B),
                             ),
                             maxLines: 1,
                             overflow: TextOverflow.ellipsis,
                           ),
                         ],
                       ),
                     ),
                   ],
                 ),
               );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(ServiceProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSectionTitle('RIWAYAT TERBARU'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: provider.history.take(5).length,
            itemBuilder: (context, index) {
              final item = provider.history[index];
              final status = (item['status'] as String?)?.toLowerCase() ?? 'pending';

              Color statusColor;
              Color statusBg;
              if (status == 'success' || status == 'completed' || status == 'selesai') {
                statusColor = const Color(0xFF10B981);
                statusBg = const Color(0xFFECFDF5);
              } else if (status == 'pending' || status == 'proses') {
                statusColor = const Color(0xFFF59E0B);
                statusBg = const Color(0xFFFEF3C7);
              } else {
                statusColor = const Color(0xFFEF4444);
                statusBg = const Color(0xFFFEE2E2);
              }

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ServiceTicketScreen(
                        ticket: item as Map<String, dynamic>,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12, bottom: 6),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 12,
                                color: Color(0xFF64748B),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatDate(item['service_date'] ?? '-'),
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFF1F5F9), height: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item['motor_model'] ?? 'Unit Motor',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item['service_type'] ?? 'Servis Umum',
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                          ],
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

  Widget _buildBookingButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Container(
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
          height: 56,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ServiceBookingScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_task_rounded, size: 20),
                const SizedBox(width: 12),
                Text(
                  'BOOKING SERVIS SEKARANG',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      if (dateStr == '-') return '-';
      DateTime dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  Widget _buildShimmerHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 28),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSectionTitle('RIWAYAT TERBARU'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return ShimmerLoading(
                isLoading: true,
                child: Container(
                  width: 250,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
