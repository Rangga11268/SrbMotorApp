# SRB Motor Mobile App - Course Project Design

## Mobile Programming 1 (Flutter)

**Version**: 1.0
**Last Updated**: March 19, 2026
**Target Audience**: Course Project (MP-1)
**Platform**: Flutter (iOS & Android)

---

## TABLE OF CONTENTS

1. [Project Overview](#project-overview)
2. [Tech Stack](#tech-stack)
3. [Database Schema](#database-schema)
4. [Core Features](#core-features)
5. [Page Designs](#page-designs)
6. [Responsive Design Basics](#responsive-design-basics)
7. [Safe Area & Platform Handling](#safe-area--platform-handling)
8. [Navigation Structure](#navigation-structure)
9. [API Integration](#api-integration)
10. [State Management](#state-management)
11. [Implementation Checklist](#implementation-checklist)

---

## 1. PROJECT OVERVIEW

### What is SRB Motor?

E-commerce application untuk pembelian motor dengan opsi:

- **Cash Purchase** (pemesanan tunai via API)
- **Favorite / Wishlist** (simpan motor impian via SQLite)

### Course Project Goals

✅ Build functional mobile app untuk user flow utama
✅ Implement responsive design (support landscape & portrait)
✅ Integrate with existing Laravel backend
✅ Handle both iOS & Android safely
✅ Arsitektur yang rapi dengan Provider state management

### Target Features for MVP

- ✅ Authentication (Login/Register menggunakan JWT)
- ✅ Browse Motors (Home + Catalog via API)
- ✅ Motor Detail (Info & Specs via API)
- ✅ Place Order (Khusus Cash/Tunai via POST API)
- ✅ Track Order Status (Riwayat Pesanan)
- ✅ Wishlist / Favorite (Local Storage SQLite)
- ✅ User Profile

---

## 2. TECH STACK

### Frontend (Mobile)

```
Framework:           Flutter 3.25.0+
Language:            Dart 3.5+
State Management:    Provider (Lebih ramah untuk OOP pemula/mahasiswa)
HTTP Client:         http 1.2+ (atau Dio)
Auth:                JWT Token (dari REST API Laravel)
Local Storage:       shared_preferences (Token) + sqflite (Fitur Favorite)
UI:                  Material Design 3
```

### Backend (Already Built)

```
Framework:           Laravel 12
Database:            MySQL 8.0
Payment:             Midtrans Snap API
Authentication:      Laravel Session + JWT for mobile
```

### Key Packages

```yaml
dependencies:
  flutter: sdk: flutter
  provider: ^6.1.1
  http: ^1.2.0
  sqflite: ^2.3.0
  shared_preferences: ^2.2.0
  google_fonts: ^6.0.0
  intl: ^0.19.0
  cached_network_image: ^3.3.0
  image_picker: ^1.0.0
  file_picker: ^6.0.0
```

---

## 3. DATABASE SCHEMA

### Active Tables (dari Laravel backend)

```
users (id, email, name, phone, password, role)
├── transactions (hanya berfokus pada order_type: cash)
└── transaction_logs (log riwayat status pesanan dari sistem)

motors (id, name, brand, details, price, type, image_path ...)
└── categories (id, name, slug)
```

### Key Relationships

```
User 1—→ Many Transactions
Transaction 1—→ 1 Motor
Transaction 1—→ Many TransactionLogs
Motor 1—→ 1 Category
```

---

## 4. CORE FEATURES

### 4.1 Authentication

- **Login**: Email + Password (mendapatkan JWT)
- **Register**: Email, Password, Name, Phone
- **Logout**: Clear token dari shared_preferences
- **Session**: Simpan token JWT menggunakan shared_preferences

### 4.2 Home Screen

- Greeting message (Hello, [User]!)
- Featured motors carousel (auto-scroll 5s)
- Category chips (horizontal scroll)
- Motor grid (2 columns portrait, 3 columns landscape)
- Search bar shortcut

### 4.3 Motor Catalog

- Grid/List view toggle
- **Filters**:
    - Category (dropdown)
    - Price range (slider 0-500M)
    - Brand (dropdown)
    - Transmission (Auto/Manual)
- **Sort**: Price (asc/desc), Newest, Sales
- 2-3 column grid (responsive)

### 4.4 Motor Detail

- Image carousel (5+ photos)
- Specs (engine, transmission, weight, price)
- Spesifikasi Kendaraan
- Related motors (3 item dari API rekomendasi)
- Action 1: **Pesan Sekarang (Tunai)**
- Action 2: **Favoritkan (❤️ Simpan ke SQLite)**

### 4.5 Cash Order Form

Single form screen:

- Customer Name
- Phone Number
- Occupation
- Address (textarea)
- Notes (optional)
- **Submit** button

### 4.6 Order Status Tracking

- Vertical timeline with status indicators
- Menampilkan status pesanan:
  1. Pesanan Diterima (new_order)
  2. Menunggu Pembayaran
  3. Selesai

### 4.7 User Profile

- User Info (Email, Phone, Name)
- **Settings**:
    - **Logout** button (menghapus token JWT)

---

## 5. PAGE DESIGNS

### 5.1 Navigation Structure

```
BottomTabNavigationBar (5 tabs):
├── 🏠 Home
│   └── HomeScreen
│       ├── [Featured Carousel]
│       ├── [Category Chips]
│       └── [Motor Grid]
│           └── MotorDetailScreen
│
├── 🔍 Explore
│   └── CatalogScreen (Browse all motors with filters)
│       └── MotorDetailScreen
│
├── 👤 Profile
│   └── ProfileScreen
│
├── 🔔 Notifications
│   └── NotificationListScreen
│
└── ☰ Menu
    └── MenuScreen (Order history, Settings, Help, Logout)
```

### 5.2 Home Screen Layout

**Portrait (360-600px)**:

```
┌─────────────────────┐
│ ≡ SRB Motor    [🔔] │  ← AppBar
├─────────────────────┤
│ Hello, Budi Santoso!│  ← Greeting
├─────────────────────┤
│   [◄ Featured ►]    │  ← Auto-scroll carousel
│   [Motor image]     │
├─────────────────────┤
│ Categories:         │
│ [Sport] [Scooter]...│  ← Horizontal scroll
├─────────────────────┤
│ Popular Motors      │
├─────────────────────┤
│ ┌──────┐ ┌──────┐   │
│ │Aerox │ │ NMax │   │  ← 2-column grid
│ │4.5/5 │ │4.8/5 │   │
│ │Rp... │ │Rp... │   │
│ └──────┘ └──────┘   │
│ ┌──────┐ ┌──────┐   │
│ │ Nala │ │ Vario│   │
│ │4.2/5 │ │4.3/5 │   │
│ └──────┘ └──────┘   │
└─────────────────────┘
```

**Landscape (600px+)**:

```
┌──────────────────────────────────┐
│ ≡ SRB Motor          [🔔] [👤]   │  ← Compact AppBar
├──────────────────────────────────┤
│ Hello, Budi!                     │
│ ┌──────────┐ ┌──────────┐        │
│ │Featured  │ │Featured  │        │  ← 3-column grid
│ │Carousel  │ │Carousel  │        │
│ └──────────┘ └──────────┘        │
│ Categories: [Sport][Scooter]...  │
│ ┌────────┐ ┌────────┐ ┌────────┐ │
│ │ Aerox  │ │ NMax   │ │ Nala   │ │
│ │4.5/5   │ │4.8/5   │ │4.2/5   │ │
│ │ Rp... │ │ Rp... │ │ Rp... │ │
│ └────────┘ └────────┘ └────────┘ │
└──────────────────────────────────┘
```

### 5.3 Motor Detail Screen

**Portrait**:

```
┌─────────────────────┐
│ ◄ Motor Detail  [♥] │  ← AppBar
├─────────────────────┤
│ [◄ Image 1/5 ►]     │  ← Image carousel
│ [Thumbnails below]  │
├─────────────────────┤
│ Yamaha NMax         │  ← Title
│ Rp78,500,000       │  ← Price
│ ⭐ 4.8 (234 review) │
├─────────────────────┤
│ Specifications      │  ← Card
│ Engine: 155cc       │
│ Trans: Automatic    │
│ Weight: 125kg       │
├─────────────────────┤
│ Financing Options   │  ← Table
│ Tenor | Monthly     │
│ 12mo | Rp 6,5jt    │
│ 24mo | Rp 3,7jt    │
│ 36mo | Rp 2,7jt    │
├─────────────────────┤
│ Reviews (5 shown)   │  ← Card
│ ⭐⭐⭐⭐⭐          │
│ "Bagus banget!"     │
├─────────────────────┤
│ [Order Now] [Fav]   │  ← Action buttons
└─────────────────────┘
```

### 5.4 Catalog with Filters

**Portrait**:

```
┌─────────────────────┐
│ ≡ Catalog       [🔍] │
├─────────────────────┤
│ [Search...]         │  ← Sticky search
│ [Filters ↓] [↕ Sort]│
├─────────────────────┤
│ ┌──────┐ ┌──────┐   │
│ │Aerox │ │ NMax │   │  ← 2-column grid
│ │ Rp..│ │ Rp..│   │
│ └──────┘ └──────┘   │
│ ┌──────┐ ┌──────┐   │
│ │ Nala │ │ Vario│   │
│ │ Rp..│ │ Rp..│   │
│ └──────┘ └──────┘   │
└─────────────────────┘

--- Filter Bottom Sheet ---
┌─────────────────────┐
│ ⚙️ Filters         │
├─────────────────────┤
│ Category:           │
│ [Sport] [Scooter]   │
│ [All]               │
│                     │
│ Price Range:        │
│ [•————————] 0 - 500M │
│                     │
│ Brand:              │
│ □ Yamaha            │
│ ✓ Honda             │
│ □ Suzuki            │
│                     │
│ [Reset] [Apply]     │
└─────────────────────┘
```

### 5.5 Cash Order Form

```
┌─────────────────────┐
│ ◄ Pesan (Cash) │
├─────────────────────┤
│ ///////  Order      │
│ ///////  Yamaha     │
│ ///////  NMax       │
├─────────────────────┤
│ Rp78,500,000       │
│ Uang Muka: Rp10jt  │
│ Sisa: Rp68.5jt     │
├─────────────────────┤
│ Nama Lengkap:       │
│ [Budi Santoso    ]  │
│                     │
│ Nomor Telepon:      │
│ [+62812345678    ]  │
│                     │
│ Pekerjaan:          │
│ [Karyawan        ▼] │
│                     │
│ Alamat:             │
│ [Jalan Merdeka...]  │
│                     │
│ Catatan (opsional): │
│ [.................] │
│                     │
│         [Pesan]     │
└─────────────────────┘
```



### 5.6 Order Status Tracking

```
┌─────────────────────┐
│ ◄ Status Order  [⋯] │
├─────────────────────┤
│ Order ID: ORD-00123 │
│ Yamaha NMax         │
│ Rp78,500,000       │
├─────────────────────┤
│ Timeline:           │
│                     │
│ ✓ Pesanan Diterima  │
│   03-19 10:30       │
│                     │
│ ⏳ Tunggu Pembayaran │
│   (Menunggu...)     │
│                     │
│ ○ Pesanan Selesai   │
│                     │
│ ========== Actions ==│
│ [💬 Chat WhatsApp]   │
└─────────────────────┘
```

### 5.7 User Profile

```
┌─────────────────────┐
│ Profil          [✎] │
├─────────────────────┤
│       [👤]          │  ← Avatar
│   Budi Santoso      │
│   budi@email.com    │
├─────────────────────┤
│ Informasi Pribadi   │
│ Email:              │
│ budi@email.com      │
│                     │
│ Nomor Telepon:      │
│ +6281234567890      │
├─────────────────────┤
│      [Logout]       │
└─────────────────────┘
```



---

## 6. RESPONSIVE DESIGN BASICS

### 6.1 Device Categories

```
COMPACT (< 600dp)
├── iPhone 11/12/13/14/15 (360-390px)
└── Older Android phones (360-480px)

MEDIUM (600-840dp)
├── iPad (6th-10th gen) landscape, 600px width
└── Larger Android phones in landscape (600-800px)

EXPANDED (> 840dp)
├── iPad Pro 11" & 12.9" landscape (840px+)
└── Web browser / Desktop emulation (1200px+)
```

### 6.2 Layout Grid System

| Device Size | Columns | Padding | Gutter |
| ----------- | ------- | ------- | ------ |
| Compact     | 2       | 16dp    | 12dp   |
| Medium      | 3       | 24dp    | 16dp   |
| Expanded    | 4       | 32dp    | 20dp   |

**Implementation** (Provider + MediaQuery):

```dart
class ResponsiveHelper {
  static int getColumns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2;
    if (width < 840) return 3;
    return 4;
  }

  static double getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 16;
    if (width < 840) return 24;
    return 32;
  }
}
```

### 6.3 Typography Scaling

| Element | Compact | Medium | Expanded |
| ------- | ------- | ------ | -------- |
| Display | 24px    | 28px   | 32px     |
| H1      | 20px    | 24px   | 28px     |
| H2      | 18px    | 20px   | 24px     |
| Body    | 14px    | 14px   | 16px     |
| Small   | 12px    | 12px   | 14px     |

**Implementation**:

```dart
TextStyle getDisplayStyle(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  final size = width < 600 ? 24.0 : (width < 840 ? 28.0 : 32.0);
  return TextStyle(fontSize: size, fontWeight: FontWeight.bold);
}
```

### 6.4 Image Sizing

**Motor Cards**:

- Compact: 180px wide, 240px height (3:4 aspect ratio)
- Medium: 200px wide, 260px height (same ratio)
- Expanded: 240px wide, 320px height (same ratio)

**Implementation**:

```dart
class MotorCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final cardWidth = width < 600 ? 180.0 : (width < 840 ? 200.0 : 240.0);
    final cardHeight = cardWidth * 1.33; // 3:4 ratio

    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Card(
        child: CachedNetworkImage(
          imageUrl: motor.image,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
```

### 6.5 Multi-Column Forms

**Portrait (Compact/Medium)**:

- All form fields: full width
- Button: full width

**Landscape (Medium/Expanded)**:

- 2 columns for form fields
- Button: max 300dp width, centered

**Implementation**:

```dart
class OrderForm extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(isLandscape ? 12.0 : 16.0),
        child: Column(
          children: [
            if (isLandscape)
              Row(
                children: [
                  Expanded(child: TextFormField(decoration: InputDecoration(labelText: 'Name'))),
                  SizedBox(width: 16),
                  Expanded(child: TextFormField(decoration: InputDecoration(labelText: 'Phone'))),
                ],
              )
            else
              Column(
                children: [
                  TextFormField(decoration: InputDecoration(labelText: 'Name')),
                  SizedBox(height: 12),
                  TextFormField(decoration: InputDecoration(labelText: 'Phone')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. SAFE AREA & PLATFORM HANDLING

### 7.1 iOS Safe Insets

- **Top** (Notch): 39.3dp (iPhone 13+), 20.7dp (older)
- **Bottom** (Home Indicator): 34dp
- **Sides**: 0dp (typically)

### 7.2 Android Safe Insets

- **Top** (Status Bar): 24dp
- **Bottom**: 0dp
- **Sides**: 0dp

### 7.3 Implementation

**Wrap content with SafeArea**:

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(title: Text('Home')),
    body: SafeArea(
      // Content automatically avoids notch/status bar
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Your widgets here
          ],
        ),
      ),
    ),
  );
}
```

**For fullscreen images** (Optional - extend under status bar):

```dart
ExtendBodyBehindAppBar: true,
AppBar(backgroundColor: Colors.transparent, elevation: 0),
```

### 7.4 Platform-Specific Behavior

No need platform-specific code for **course project**. Use Material Design 3 for both iOS & Android:

```dart
MaterialApp(
  theme: ThemeData(
    useMaterial3: true, // Works beautifully on both platforms
    colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2563EB)),
  ),
  // ...
)
```

---

## 8. NAVIGATION STRUCTURE

### 8.1 Bottom Tab Navigation

```
┌────────────────────────   ┐
│ [Content Area]           │
├────────────────────────   ┤
│ 🏠 Home │ 🔍 │ 👤 │ 🔔 │ ☰ │  ← 5 tabs
└────────────────────────   ┘
```

**Implementation** (Provider):

```dart
class TabProvider with ChangeNotifier {
  int _currentIndex = 0;
  int get currentIndex => _currentIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }
}

  Widget build(BuildContext context) {
    final tabProvider = Provider.of<TabProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: tabProvider.currentIndex,
        children: [
          HomeScreen(),
          CatalogScreen(),
          ProfileScreen(),
          NotificationScreen(),
          MenuScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabProvider.currentIndex,
        onTap: (index) => tabProvider.setIndex(index),
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Explore'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notif'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
```

### 8.2 Screen Hierarchy

```
MainNavigation
├── HomeScreen
│   └── MotorDetailScreen
│       └── OrderFormScreen (Cash)
├── CatalogScreen
│   ├── FilterBottomSheet
│   └── MotorDetailScreen (→ OrderForm)
├── ProfileScreen
├── NotificationScreen
└── MenuScreen
    ├── OrderHistoryScreen
    │   └── OrderStatusScreen
    └── SettingsScreen
```

---

## 9. API INTEGRATION

### 9.1 Base Configuration

**Dio or http Setup** (Example with HTTP):

```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.1.5:8000/api'; // Ganti IP
  
  static Future<Map<String, String>> get headers async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
```

### 9.2 Key API Endpoints

| Method | Endpoint                         | Purpose                        |
| ------ | -------------------------------- | ------------------------------ |
| POST   | `/login`                         | User login (email + password)  |
| POST   | `/register`                      | User registration              |
| GET    | `/motors`                        | List all motors (with filters) |
| GET    | `/motors/{id}`                   | Motor detail + reviews         |
| POST   | `/orders/cash`                   | Place cash order               |
| GET    | `/orders`                        | Order history list             |
| GET    | `/orders/{id}`                   | Order detail + status          |
| GET    | `/user/profile`                  | User profile info              |

### 9.3 Service Layer (OOP Concept)

```dart
class MotorService {
  Future<List<Motor>> getMotors() async {
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}/motors'),
      headers: await ApiConfig.headers,
    );
    // Parse JSON to List<Motor>
  }
}
```

---

## 10. STATE MANAGEMENT

### 10.1 Provider Structure

```
lib/
├── providers/
│   ├── auth_provider.dart (login logic, simpan token)
│   ├── motor_provider.dart (fetch motors via API, filtering)
│   ├── order_provider.dart (POST pesanan, GET history)
│   └── favorite_provider.dart (SQLite CRUD untuk wishlist)
├── services/
│   ├── auth_service.dart
│   ├── motor_service.dart
│   └── order_service.dart
├── models/
│   ├── user.dart
│   ├── motor.dart
│   └── order.dart
├── screens/
│   ├── auth/
│   ├── home/
│   ├── motor_detail/
│   ├── order_form/
│   └── ...
└── main.dart
```

### 10.2 Example: Integrating Provider

```dart
// Di main.dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MotorProvider()),
        ChangeNotifierProvider(create: (_) => TabProvider()),
      ],
      child: MyApp(),
    ),
  );
}
```

---

## 11. IMPLEMENTATION CHECKLIST

### Phase 1: Setup (Week 1)

- [ ] Create Flutter project with Provider + HTTP
- [ ] Setup project folder structure
- [ ] Create API service layer
- [ ] Configure BaseUrl (localhost IP for testing)
- [ ] Setup Material Design 3 theme

### Phase 2: Authentication (Week 1-2)

- [ ] Login screen UI
- [ ] Register screen UI
- [ ] Implement auth service (POST /login)
- [ ] Store JWT token in shared_preferences
- [ ] Create auth validation logic

### Phase 3: Motor Catalog (Week 2-3)

- [ ] Home screen with motor list
- [ ] Motor detail screen
- [ ] Filter & search functionality
- [ ] Image carousel for motor photos
- [ ] Reviews display
- [ ] Responsive layout (2-3 column grid)

### Phase 4: Order Placement (Week 3-4)

- [ ] Cash order form (Form Sederhana)
- [ ] Handle input validation (Nama, HP, Alamat)
- [ ] POST data ke backend
- [ ] Notifikasi Sukses / Dialog
- [ ] Spinner/loading state saat request

### Phase 5: Order Tracking (Week 4-5)

- [ ] Order status timeline screen
- [ ] Status update polling
- [ ] Download invoice feature
- [ ] Contact sales button (WhatsApp link)

### Phase 6: User Profile & Settings (Week 5)

- [ ] Profile screen
- [ ] Edit profile functionality
- [ ] Dark mode toggle
- [ ] Notification settings
- [ ] Logout

### Phase 7: Polish & Responsive Design (Week 6)

- [ ] Test on 2+ devices (portrait & landscape)
- [ ] SafeArea implementation
- [ ] Responsive font sizing
- [ ] Touch target verification (48x48 minimum)
- [ ] Fix UI issues

### Phase 8: Testing & Deployment (Week 6-7)

- [ ] Debug on real device (Android emulator required)
- [ ] Integration testing with backend
- [ ] APK build for Android
- [ ] Device testing (landscape, orientation changes)
- [ ] Bug fixes & final polish

### Phase 2: Next Update (Advanced Features)

Jika MVP utama (Tunai/Cash) sudah selesai dan berjalan lancar, fitur berikut ditargetkan untuk *update* selanjutnya:

- [ ] **Alur Pemesanan Kredit (Credit Workflow)**: Form multi-step dengan pemilihan tenor dan leasing.
- [ ] **Upload Dokumen KTP & Selfie**: Menggunakan package `image_picker` atau `camera` dengan form multipart/form-data.
- [ ] **Integrasi Midtrans (Payment Gateway)**: Menggunakan SDK / API Midtrans untuk pembayaran uang muka (DP) secara langsung dari aplikasi.
- [ ] **Offline Mode**: Cache katalog menggunakan SQLite (`sqflite`).
- [ ] **Push Notifications**: Menggunakan Firebase Cloud Messaging (FCM).

---

## QUICK START

### 1. Setup Project

```bash
flutter create srb_motor_app --org com.srbmotor
cd srb_motor_app
flutter pub add provider http shared_preferences sqflite path
```

### 2. Update pubspec.yaml

```yaml
dependencies:
    flutter:
        sdk: flutter
    provider: ^6.1.1
    http: ^1.2.0
    shared_preferences: ^2.2.0
    sqflite: ^2.3.0
    path: ^1.9.0
    cached_network_image: ^3.3.0
    intl: ^0.19.0
    google_fonts: ^6.0.0
    image_picker: ^1.0.0
    file_picker: ^6.0.0
```

### 3. Main Entry Point

```dart
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SRB Motor',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF2563EB)),
      ),
      home: const SplashScreen(),
    );
  }
}
```

### 4. Configure API Base URL

Update `lib/services/api_service.dart`:

```dart
const String API_BASE_URL = 'http://YOUR_LARAVEL_IP:8000/api';
// Example: http://192.168.1.5:8000/api
```

### 5. Run

```bash
flutter run
```

---

## TROUBLESHOOTING

### API Connection Issues

**Problem**: `Failed to connect to 192.168.x.x:8000`

- **Solution**: Ensure mobile device is on same WiFi as Laravel server
- Use `ipconfig getifaddr en0` (Mac) or `ipconfig` (Windows) to get server IP
- Update API_BASE_URL with correct IP

### SafeArea Cutting Content

**Problem**: Content is hidden behind notch or status bar

- **Solution**: Wrap Scaffold body with `SafeArea` widget

### Images Not Loading

**Problem**: `CachedNetworkImage` shows placeholder forever

- **Solution**: Verify image URL is accessible from mobile
- Check CORS if using cloud CDN
- Use `CachedNetworkImageProvider` for debugging

### Form Validation Not Working

**Problem**: `TextFormField` validation not triggering

- **Solution**: Ensure `Form` widget wraps fields and call `_formKey.currentState?.validate()`

---

## RESOURCES

- [Flutter Documentation](https://flutter.dev/docs)
- [Provider Documentation](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io)
- [HTTP Package Client](https://pub.dev/packages/http)
- [SQFLite Documentation](https://pub.dev/packages/sqflite)
- [Flutter Responsive Guide](https://flutter.dev/docs/development/ui/layout/responsive)

---

**Last Updated**: March 19, 2026
**For**: Course Project - Mobile Programming 1
**Status**: Ready for Development ✅

---

## DEVELOPER INSTRUCTIONS (USER NOTES)
1. **Tulis kode dengan rapih**.
2. **Kurangi komentar `//` yang tidak berguna**.
3. **Gunakan Bahasa Indonesia** untuk komentar yang memang diperlukan.
4. **Pastikan state managementnya bagus** (menggunakan Provider sesuai spec, terstruktur rapi).
5. **Rapihkan folder assets** (satukan `assets_honda` dan `assets_yamaha` dengan struktur yang jelas).

