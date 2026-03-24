import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/motor_provider.dart';
import '../../models/motor.dart';
import '../motor_detail/motor_detail_screen.dart';
import '../menu/order_history_screen.dart';
import '../menu/profile_screen.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeContent(),
    const OrderHistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Pesanan'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
        selectedItemColor: const Color(0xFF2563EB),
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<MotorProvider>().fetchMotors());
  }

  final List<String> categories = ['All', 'Sport', 'Scooter', 'CUB', 'EV'];

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final motorProvider = context.watch<MotorProvider>();
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('SRB Motor', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${user?.name ?? 'Pengguna'}!',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const Text(
                    'Temukan Motor Impian Anda',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            
            SizedBox(
              height: 50,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = motorProvider.selectedCategory == (category == 'All' ? null : category);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        motorProvider.setCategory(category == 'All' ? null : category);
                      },
                      selectedColor: const Color(0xFF2563EB).withOpacity(0.2),
                      checkmarkColor: const Color(0xFF2563EB),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: motorProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : motorProvider.errorMessage != null
                      ? Center(child: Text(motorProvider.errorMessage!))
                      : motorProvider.motors.isEmpty
                          ? const Center(child: Text('Tidak ada motor ditemukan'))
                          : GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: motorProvider.motors.length,
                              itemBuilder: (context, index) {
                                final motor = motorProvider.motors[index];
                                return _buildMotorCard(motor, currencyFormat);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMotorCard(Motor motor, NumberFormat format) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MotorDetailScreen(motor: motor),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  image: motor.imagePath != null
                      ? DecorationImage(
                          image: NetworkImage(motor.imagePath!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: motor.imagePath == null
                    ? const Center(child: Icon(Icons.motorcycle, size: 50, color: Colors.grey))
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.brand,
                    style: const TextStyle(fontSize: 12, color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    motor.name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    format.format(motor.price),
                    style: const TextStyle(fontSize: 14, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
