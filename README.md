# SRB Motor Mobile App 🏍️

Aplikasi mobile resmi untuk dealer **SRB Motor** yang dibangun menggunakan **Flutter** dan **Dart**. Aplikasi ini dirancang dengan estetika premium yang bersih, modern, dan sepenuhnya responsif, mengikuti desain Stitch project wireframe.

Aplikasi ini memudahkan calon pembeli untuk menjelajahi katalog sepeda motor (Honda & Yamaha), melakukan simulasi kredit secara dinamis, membandingkan spesifikasi motor secara *side-by-side*, serta langsung menghubungi pihak dealer melalui WhatsApp.

---

## 🚀 Fitur Utama

### 1. Dashboard Utama (Home)
* **Header Selamat Datang**: Menyapa pengguna dengan nama profil mereka dan avatar profil yang interaktif.
* **Auto-Playing Image Slider**: Banner promosi yang berputar otomatis untuk menampilkan info dealer dan promo terbaru.
* **Filter Merek Cepat**: Tombol kategori Honda & Yamaha yang dilengkapi logo resmi dari aset lokal.
* **Daftar Motor Populer**: Menampilkan produk unggulan dalam tata letak kartu yang menarik.

### 2. Katalog & Pencarian Motor
* Fitur pencarian cepat berdasarkan model atau tipe motor.
* Penyaringan data produk berdasarkan merek motor secara dinamis.

### 3. Detail Spesifikasi Lengkap
* Penjelasan deskriptif mengenai motor, detail kapasitas mesin (CC), transmisi, tahun rilis, dan berat kendaraan.
* Pilihan warna motor yang divisualisasikan dalam bentuk chip warna.
* Tombol CTA **Pesan lewat WhatsApp** bermerek hijau resmi untuk menghubungkan langsung ke dealer.

### 4. Simulasi Kredit Interaktif
* **Bunga Flat 1.5%**: Formula perhitungan cicilan disesuaikan secara presisi dengan sistem web aplikasi SRB Motor (`d:\laragon\www\SrbMotor`).
* **DP Slider Dinamis**: Memungkinkan pengguna menyesuaikan Uang Muka (DP) secara interaktif dari 10% hingga 80% OTR.
* **Pilihan Tenor**: Pilihan tenor kredit yang fleksibel (12 Bulan, 24 Bulan, dan 36 Bulan) menggunakan chip interaktif dengan pembaruan cicilan per bulan secara real-time.

### 5. Komparator Motor (Side-by-Side)
* Memungkinkan pengguna memilih dan membandingkan spesifikasi teknis serta harga dua sepeda motor secara berdampingan dalam satu layar perbandingan yang terstruktur.

### 6. Halaman Bantuan & FAQ
* Menampilkan panduan *"Cara Pemesanan"* dan *"Syarat Kredit & Cash"*.
* Menyediakan pintasan akses cepat ke Google Maps lokasi dealer dan kontak bantuan resmi.

### 7. Profil & Wishlist Pengguna
* Pengelolaan nama panggilan (*nickname*) dan nomor WhatsApp pengguna.
* Menyimpan daftar sepeda motor favorit/bookmark yang dikelola langsung melalui state aplikasi.

---

## 🛠️ Teknologi & Library

* **Core**: [Flutter SDK](https://flutter.dev) (Dart)
* **State Management**: Simple State & State Container (`setState` & `AppState`)
* **Design System**: Material Design 3 dengan kombinasi warna primer premium SRB `#041627`.

---

## 📥 Cara Menjalankan Project

Ikuti langkah-langkah di bawah ini untuk memasang project di komputer lokal teman sekelompok Anda:

1. **Kloning Repository**:
   ```bash
   git clone https://github.com/Rangga11268/SrbMotorApp.git
   ```

2. **Masuk ke Direktori Project**:
   ```bash
   cd SrbMotorApp
   ```

3. **Unduh Dependencies/Package**:
   Jalankan perintah berikut untuk mengunduh pustaka eksternal yang dibutuhkan aplikasi:
   ```bash
   flutter pub get
   ```

4. **Jalankan Aplikasi**:
   Pastikan emulator atau perangkat Android/iOS Anda telah terhubung, lalu jalankan:
   ```bash
   flutter run
   ```

---

## ✍️ Aturan Pengembangan (Developer Notes)

1. **Kesederhanaan Kode**: Tetap gunakan pendekatan kode yang sederhana, modular, mudah dibaca, dan ramah pemula (hindari pola arsitektur yang terlalu kompleks seperti BLoC atau Clean Architecture berlebihan jika tidak diperlukan oleh tim).
2. **Kerapihan & Tata Letak**: Pastikan tata letak responsif dan tidak mengalami overflow di perangkat dengan layar kecil.
3. **Dokumentasi & Komentar**: Gunakan Bahasa Indonesia untuk penamaan fitur atau komentar developer notes penting di dalam kode.
