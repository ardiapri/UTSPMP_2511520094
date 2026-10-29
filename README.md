# utspmp_2511520094

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# APLIKASI KAS KECIL

## Ujian Tengah Semester Pemrograman Multi Platform

### 1. Identitas Proyek

| Keterangan | Informasi |
|---|---|
| Nama aplikasi | Kas Kecil |
| Mata kuliah | Pemrograman Multi Platform |
| Program studi | Teknologi Informasi |
| Institusi | Institut Sains dan Bisnis Atma Luhur Pangkalpinang |
| Tahun akademik | 2026/2027 |
| Framework | Flutter |
| Bahasa pemrograman | Dart |
| Basis data | Firebase Cloud Firestore |
| Autentikasi | Firebase Authentication |
| REST API | Dio |

### 2. Deskripsi Aplikasi

Kas Kecil merupakan aplikasi berbasis Flutter yang digunakan untuk mencatat pemasukan dan pengeluaran. Aplikasi ini membantu pengguna mengelola transaksi, melihat ringkasan saldo, serta memantau data transaksi yang tersimpan di Cloud Firestore.

Aplikasi dilengkapi dengan autentikasi pengguna menggunakan Firebase Authentication. Selain itu, terdapat fitur Pengguna API yang mengambil dan menampilkan data dari layanan API publik menggunakan Dio.

Proyek ini dibuat untuk menerapkan materi Dart Async, REST API, Provider/MultiProvider, Firebase Authentication, dan Firestore CRUD sesuai ketentuan Ujian Tengah Semester Pemrograman Multi Platform.

### 3. Anggota Kelompok dan Pembagian Peran

**Lengkapi nama dan NIM setiap anggota sesuai kelompok sebenarnya.**

| No. | Nama | NIM | 
|---|---|---|---|
| 1 | Ardilia Apriandi | 2511520094 | 




### 4. Fitur Aplikasi

Registrasi akun pengguna.

- Login dan logout menggunakan Firebase Authentication.

- Menampilkan halaman beranda setelah login.

- Menambahkan transaksi pemasukan dan pengeluaran.

- Menampilkan daftar transaksi.

- Mengedit transaksi.

- Menghapus transaksi.

- Menampilkan data pengguna dari REST API.

- Menampilkan detail pengguna dari API.

- Mengelola kondisi loading, loaded, error, dan empty menggunakan Provider.

- Menyimpan dan mengambil data transaksi dari Cloud Firestore.

### 5. Teknologi yang Digunakan

- Flutter dan Dart untuk membangun aplikasi.
- Firebase Authentication untuk autentikasi pengguna.
- Cloud Firestore untuk menyimpan dan mengelola data transaksi.
- Provider dan MultiProvider untuk pengelolaan state.
- Dio untuk melakukan permintaan REST API.
- Future dan Stream untuk menangani proses asinkron.
- Model, service, dan provider untuk memisahkan tanggung jawab kode program.

### 6. Struktur Folder

Struktur utama proyek:

```text
UTSPMP_2511520094/
├── lib/
│   ├── models/
│   ├── providers/
│   ├── services/
│   │   ├── firestore_service.dart
│   │   └── api_service.dart
│   ├── screens/
│   ├── main.dart
│   └── firebase_options.dart
├── android/
├── pubspec.yaml
├── pubspec.lock
└── README.md
```

### 7. Screenshot Aplikasi

## Screenshot Aplikasi

### 1. Halaman Login
![Halaman Login](screenshots/login.png)

### 2. Halaman Register
![Halaman Register](screenshots/register.png)

### 3. Halaman Beranda
![Halaman Beranda](screenshots/beranda.png)

### 4. Daftar Transaksi
![Daftar Transaksi](screenshots/transaksi.png)

### 5. Tambah Transaksi
![Tambah Transaksi](screenshots/tambah-transaksi.png)

### 6. Edit Transaksi
![Edit Transaksi](screenshots/edit-transaksi.png)

### 7. Hapus Transaksi
![Hapus Transaksi](screenshots/hapus-transaksi.png)

### 8. Logout
![Logout](screenshots/logout.png)

### 9. Daftar Pengguna API
![Pengguna API](screenshots/pengguna-api.png)

### 10. Detail Pengguna API
![Detail Pengguna API](screenshots/detailpengguna-api.png)

## Bukti Firebase

### Firebase Authentication
![Firebase Authentication](screenshots/authentication.png)

### Data Pemasukan
![Database Pemasukan](screenshots/database-pemasukan.png)

### Data Pengeluaran
![Database Pengeluaran](screenshots/database-pengeluaran.png)

### Aturan Keamanan Firestore
![Firestore Rules](screenshots/rules.png)


### 8. Cara Menjalankan Aplikasi

#### Persyaratan

- Flutter SDK.
- Dart SDK yang sesuai dengan versi Flutter.
- Android Studio atau Visual Studio Code.
- Akun Firebase dan akses ke proyek Firebase.
- Koneksi internet untuk mengakses Firebase dan API.

#### Langkah menjalankan

1. Clone repositori GitHub proyek.
2. Buka terminal pada folder proyek.
3. Instal dependensi:

   ```bash
   flutter pub get
   ```

4. Konfigurasikan Firebase untuk lingkungan yang digunakan. Instal dan jalankan FlutterFire CLI bila belum tersedia:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

5. Pilih proyek Firebase yang benar dan platform yang diperlukan. Periksa kembali `lib/firebase_options.dart` dan konfigurasi platform.
6. Pastikan Firebase Authentication dan Cloud Firestore telah diaktifkan serta aturan keamanan Firestore sudah sesuai.
7. Jalankan pemeriksaan kode:

   ```bash
   flutter analyze
   ```

8. Jalankan aplikasi:

   ```bash
   flutter run
   ```



### 9. Penjelasan Future dan Stream

**Future** digunakan untuk operasi asinkron yang menghasilkan satu penyelesaian, misalnya menunggu permintaan GET API atau proses menyimpan transaksi selesai.

**Stream** digunakan untuk menerima rangkaian data atau perubahan secara berkelanjutan. Dalam proyek ini, Stream digunakan untuk memantau status autentikasi dan perubahan data Firestore.



### 10. Kesimpulan

Aplikasi Kas Kecil menerapkan autentikasi pengguna, pengelolaan transaksi menggunakan Firestore, pengelolaan state menggunakan Provider, serta pengambilan data API publik menggunakan Dio.

Melalui proyek ini, materi pemrograman asinkron, REST API, Firebase Authentication, dan Firestore CRUD diterapkan dalam satu aplikasi Flutter.
