
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/transaction_provider.dart';
import 'providers/api_provider.dart';
import 'models/transaction_model.dart';
import 'screens/auth_screen.dart';
import 'screens/api_users_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
      ],
      child: const KasKecilApp(),
    ),
  );
}

const Color warnaBiru = Color(0xFF2563EB);
const Color warnaLatar = Color(0xFFF5F7FC);
const Color warnaHijau = Color(0xFF16A34A);
const Color warnaMerah = Color(0xFFDC2626);

class KasKecilApp extends StatelessWidget {
  const KasKecilApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kas Kecil',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: warnaLatar,
        colorScheme: ColorScheme.fromSeed(seedColor: warnaBiru),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF172033),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: warnaLatar,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

String rupiah(double nominal) {
  final angka = nominal.round().toString();
  final hasil = angka.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
  return 'Rp$hasil';
}

String formatTanggal(DateTime tanggal) {
  return '${tanggal.day.toString().padLeft(2, '0')}/'
      '${tanggal.month.toString().padLeft(2, '0')}/'
      '${tanggal.year}';
}

// ==================== GERBANG LOGIN ====================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (auth.user == null) {
      return const AuthScreen();
    }

    return const HalamanUtama();
  }
}

// ==================== HALAMAN UTAMA ====================

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int halamanAktif = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TransactionProvider>().listenTransactions();
    });
  }

  Future<void> bukaFormTransaksi({
    String jenisAwal = 'Pemasukan',
    TransactionModel? transaksi,
  }) async {
    final provider = context.read<TransactionProvider>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => FormTransaksi(
        jenisAwal: transaksi?.type ?? jenisAwal,
        transaksi: transaksi,
        onSimpan: (judul, nominal, jenis) async {
          if (transaksi == null) {
            return provider.addTransaction(
              title: judul,
              amount: nominal,
              type: jenis,
            );
          }

          final hasil = TransactionModel(
            id: transaksi.id,
            title: judul,
            amount: nominal,
            type: jenis,
            createdAt: transaksi.createdAt,
            userId: transaksi.userId,
          );

          return provider.updateTransaction(hasil);
        },
      ),
    );
  }

  Future<void> hapusTransaksi(TransactionModel transaksi) async {
    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus transaksi?'),
        content: Text(
          'Transaksi "${transaksi.title}" akan dihapus secara permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: warnaMerah,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (setuju != true || !mounted) return;

    final berhasil = await context
        .read<TransactionProvider>()
        .deleteTransaction(transaksi);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          berhasil
              ? 'Transaksi berhasil dihapus.'
              : context.read<TransactionProvider>().errorMessage ??
                  'Transaksi gagal dihapus.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TransactionProvider>();
    final transaksi = provider.transactions;

    final halaman = [
      Dashboard(
        transaksi: transaksi,
        saldo: provider.saldo,
        pemasukan: provider.totalPemasukan,
        pengeluaran: provider.totalPengeluaran,
        state: provider.state,
        errorMessage: provider.errorMessage,
        onTambah: () => bukaFormTransaksi(),
        onPemasukan: () => bukaFormTransaksi(
          jenisAwal: 'Pemasukan',
        ),
        onPengeluaran: () => bukaFormTransaksi(
          jenisAwal: 'Pengeluaran',
        ),
        onLihatSemua: () => setState(() => halamanAktif = 1),
        onUlangi: provider.listenTransactions,
      ),
      HalamanTransaksi(
        transaksi: transaksi,
        state: provider.state,
        errorMessage: provider.errorMessage,
        onTambah: () => bukaFormTransaksi(),
        onEdit: (item) => bukaFormTransaksi(transaksi: item),
        onHapus: hapusTransaksi,
        onUlangi: provider.listenTransactions,
      ),
      const ApiUsersScreen(),
      const HalamanProfil(),
    ];

    return Scaffold(
      body: SafeArea(child: halaman[halamanAktif]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: halamanAktif,
        onDestinationSelected: (index) {
          setState(() => halamanAktif = index);
        },
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDBEAFE),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Transaksi',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Pengguna API',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}

// ==================== DASHBOARD ====================

class Dashboard extends StatelessWidget {
  final List<TransactionModel> transaksi;
  final double saldo;
  final double pemasukan;
  final double pengeluaran;
  final ViewState state;
  final String? errorMessage;
  final VoidCallback onTambah;
  final VoidCallback onPemasukan;
  final VoidCallback onPengeluaran;
  final VoidCallback onLihatSemua;
  final VoidCallback onUlangi;

  const Dashboard({
    super.key,
    required this.transaksi,
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
    required this.state,
    required this.errorMessage,
    required this.onTambah,
    required this.onPemasukan,
    required this.onPengeluaran,
    required this.onLihatSemua,
    required this.onUlangi,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: warnaBiru,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white,
                size: 27,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kas Kecil',
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF172033),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Kelola keuangan lebih mudah',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onUlangi,
              icon: const Icon(Icons.refresh_rounded),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: warnaBiru,
              ),
              tooltip: 'Muat ulang transaksi',
            ),
          ],
        ),
        const SizedBox(height: 26),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: warnaBiru.withValues(alpha: 0.20),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    color: Colors.white70,
                    size: 21,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Total Saldo Anda',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                rupiah(saldo),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 31,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: Colors.white30),
              const SizedBox(height: 8),
              const Row(
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 7),
                  Text(
                    'Data transaksi dari Firestore',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: KartuRingkasan(
                judul: 'Pemasukan',
                nominal: pemasukan,
                ikon: Icons.south_west_rounded,
                warna: warnaHijau,
                latar: const Color(0xFFDCFCE7),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: KartuRingkasan(
                judul: 'Pengeluaran',
                nominal: pengeluaran,
                ikon: Icons.north_east_rounded,
                warna: warnaMerah,
                latar: const Color(0xFFFEE2E2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ),
            TextButton.icon(
              onPressed: onTambah,
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Tambah'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TombolAksi(
                ikon: Icons.add_rounded,
                judul: 'Pemasukan',
                warna: warnaHijau,
                onTap: onPemasukan,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TombolAksi(
                ikon: Icons.remove_rounded,
                judul: 'Pengeluaran',
                warna: warnaMerah,
                onTap: onPengeluaran,
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Transaksi Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF172033),
                ),
              ),
            ),
            TextButton(
              onPressed: onLihatSemua,
              child: const Text('Lihat Semua'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (state == ViewState.loading)
          const Padding(
            padding: EdgeInsets.all(28),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (state == ViewState.error)
          KartuKesalahan(
            pesan: errorMessage ?? 'Gagal memuat transaksi.',
            onUlangi: onUlangi,
          )
        else if (transaksi.isEmpty)
          const KartuKosong(
            ikon: Icons.receipt_long_outlined,
            pesan: 'Belum ada transaksi. Tambahkan transaksi pertama Anda.',
          )
        else
          ...transaksi.take(4).map(
                (item) => ItemTransaksi(item: item),
              ),
      ],
    );
  }
}

// ==================== KARTU RINGKASAN ====================

class KartuRingkasan extends StatelessWidget {
  final String judul;
  final double nominal;
  final IconData ikon;
  final Color warna;
  final Color latar;

  const KartuRingkasan({
    super.key,
    required this.judul,
    required this.nominal,
    required this.ikon,
    required this.warna,
    required this.latar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: latar,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(ikon, color: warna, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            judul,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rupiah(nominal),
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TOMBOL AKSI ====================

class TombolAksi extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final Color warna;
  final VoidCallback onTap;

  const TombolAksi({
    super.key,
    required this.ikon,
    required this.judul,
    required this.warna,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 17,
            horizontal: 10,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(ikon, color: warna),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== DAFTAR TRANSAKSI ====================

class HalamanTransaksi extends StatelessWidget {
  final List<TransactionModel> transaksi;
  final ViewState state;
  final String? errorMessage;
  final VoidCallback onTambah;
  final ValueChanged<TransactionModel> onEdit;
  final ValueChanged<TransactionModel> onHapus;
  final VoidCallback onUlangi;

  const HalamanTransaksi({
    super.key,
    required this.transaksi,
    required this.state,
    required this.errorMessage,
    required this.onTambah,
    required this.onEdit,
    required this.onHapus,
    required this.onUlangi,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaksi',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Pantau pemasukan dan pengeluaran',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onUlangi,
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Muat ulang',
              ),
              IconButton.filled(
                onPressed: onTambah,
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: warnaBiru,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: switch (state) {
            ViewState.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            ViewState.error => KartuKesalahan(
                pesan: errorMessage ?? 'Gagal memuat transaksi.',
                onUlangi: onUlangi,
              ),
            ViewState.empty => const KartuKosong(
                ikon: Icons.receipt_long_outlined,
                pesan: 'Belum ada transaksi. Tekan + untuk menambahkan.',
              ),
            ViewState.loaded => ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                itemCount: transaksi.length,
                itemBuilder: (context, index) {
                  final item = transaksi[index];

                  return ItemTransaksi(
                    item: item,
                    onLongPress: () => onEdit(item),
                    onEdit: () => onEdit(item),
                    onHapus: () => onHapus(item),
                  );
                },
              ),
          },
        ),
      ],
    );
  }
}

// ==================== ITEM TRANSAKSI ====================

class ItemTransaksi extends StatelessWidget {
  final TransactionModel item;
  final VoidCallback? onLongPress;
  final VoidCallback? onEdit;
  final VoidCallback? onHapus;

  const ItemTransaksi({
    super.key,
    required this.item,
    this.onLongPress,
    this.onEdit,
    this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    final bool masuk = item.type == 'Pemasukan';
    final Color warna = masuk ? warnaHijau : warnaMerah;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
      ),
      child: ListTile(
        onLongPress: onLongPress,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 8,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: masuk
                ? const Color(0xFFDCFCE7)
                : const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            masuk ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: warna,
          ),
        ),
        title: Text(
          item.title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${item.type} • ${formatTanggal(item.createdAt)}',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${masuk ? '+' : '-'}${rupiah(item.amount)}',
              style: TextStyle(
                color: warna,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onEdit != null || onHapus != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit?.call();
                  if (value == 'hapus') onHapus?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit transaksi'),
                  ),
                  PopupMenuItem(
                    value: 'hapus',
                    child: Text('Hapus transaksi'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ==================== FORM TRANSAKSI ====================

class FormTransaksi extends StatefulWidget {
  final String jenisAwal;
  final TransactionModel? transaksi;
  final Future<bool> Function(
    String judul,
    double nominal,
    String jenis,
  ) onSimpan;

  const FormTransaksi({
    super.key,
    this.jenisAwal = 'Pemasukan',
    this.transaksi,
    required this.onSimpan,
  });

  @override
  State<FormTransaksi> createState() => _FormTransaksiState();
}

class _FormTransaksiState extends State<FormTransaksi> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulController;
  late final TextEditingController _nominalController;

  late String jenis;
  bool _sedangMenyimpan = false;

  bool get sedangEdit => widget.transaksi != null;

  @override
  void initState() {
    super.initState();
    jenis = widget.jenisAwal;
    _judulController = TextEditingController(
      text: widget.transaksi?.title ?? '',
    );
    _nominalController = TextEditingController(
      text: widget.transaksi == null
          ? ''
          : widget.transaksi!.amount.round().toString(),
    );
  }

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    if (!_formKey.currentState!.validate() || _sedangMenyimpan) return;

    final judul = _judulController.text.trim();
    final nominal = double.parse(
      _nominalController.text.trim().replaceAll('.', ''),
    );

    setState(() => _sedangMenyimpan = true);

    final berhasil = await widget.onSimpan(judul, nominal, jenis);

    if (!mounted) return;

    setState(() => _sedangMenyimpan = false);

    if (berhasil) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            sedangEdit
                ? 'Transaksi berhasil diperbarui.'
                : 'Transaksi berhasil disimpan.',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Transaksi gagal disimpan. Periksa koneksi dan aturan Firestore.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        22,
        22,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                sedangEdit ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: const TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Masukkan detail transaksi Anda.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              const Text(
                'Nama transaksi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 9),
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  hintText: 'Contoh: Beli alat tulis',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama transaksi harus diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Nominal (Rp)',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 9),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 150000',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
                validator: (value) {
                  final angka = double.tryParse(
                    (value ?? '').trim().replaceAll('.', ''),
                  );
                  if (angka == null || angka <= 0) {
                    return 'Masukkan nominal yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 18),
              const Text(
                'Jenis transaksi',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 9),
              DropdownButtonFormField<String>(
                initialValue: jenis,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.swap_vert_rounded),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Pemasukan',
                    child: Text('Pemasukan'),
                  ),
                  DropdownMenuItem(
                    value: 'Pengeluaran',
                    child: Text('Pengeluaran'),
                  ),
                ],
                onChanged: _sedangMenyimpan
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => jenis = value);
                        }
                      },
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: _sedangMenyimpan ? null : simpan,
                  icon: _sedangMenyimpan
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _sedangMenyimpan
                        ? 'Menyimpan...'
                        : sedangEdit
                            ? 'Simpan Perubahan'
                            : 'Simpan Transaksi',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: warnaBiru,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== PROFIL ====================

class HalamanProfil extends StatelessWidget {
  const HalamanProfil({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? 'Pengguna Kas Kecil';

    return ListView(
      padding: const EdgeInsets.all(22),
      children: [
        const Text(
          'Profil',
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const CircleAvatar(
                radius: 43,
                backgroundColor: Color(0xFFDBEAFE),
                child: Icon(
                  Icons.person_rounded,
                  color: warnaBiru,
                  size: 48,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Pengguna Kas Kecil',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        const KartuMenuProfil(
          ikon: Icons.account_circle_outlined,
          judul: 'Informasi Akun',
          keterangan: 'Akun yang sedang login',
        ),
        const KartuMenuProfil(
          ikon: Icons.security_outlined,
          judul: 'Keamanan',
          keterangan: 'Dilindungi Firebase Authentication',
        ),
        const KartuMenuProfil(
          ikon: Icons.info_outline_rounded,
          judul: 'Tentang Aplikasi',
          keterangan: 'Kas Kecil versi 1.0',
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: OutlinedButton.icon(
            onPressed: () async {
              final setuju = await showDialog<bool>(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Keluar dari akun?'),
                  content: const Text(
                    'Anda perlu login kembali untuk mengakses transaksi.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, false),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () =>
                          Navigator.pop(dialogContext, true),
                      child: const Text('Keluar'),
                    ),
                  ],
                ),
              );

              if (setuju == true && context.mounted) {
                await context.read<AuthProvider>().logout();
                if (!context.mounted) return;
context.read<TransactionProvider>().listenTransactions();
              }
            },
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Keluar dari Akun'),
            style: OutlinedButton.styleFrom(
              foregroundColor: warnaMerah,
            ),
          ),
        ),
      ],
    );
  }
}

class KartuMenuProfil extends StatelessWidget {
  final IconData ikon;
  final String judul;
  final String keterangan;

  const KartuMenuProfil({
    super.key,
    required this.ikon,
    required this.judul,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(ikon, color: warnaBiru),
        title: Text(
          judul,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(keterangan),
      ),
    );
  }
}

// ==================== TAMPILAN KOSONG ====================

class KartuKosong extends StatelessWidget {
  final IconData ikon;
  final String pesan;

  const KartuKosong({
    super.key,
    required this.ikon,
    required this.pesan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 45, horizontal: 20),
      child: Column(
        children: [
          Icon(ikon, size: 55, color: Colors.grey.shade400),
          const SizedBox(height: 12),
          Text(
            pesan,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class KartuKesalahan extends StatelessWidget {
  final String pesan;
  final VoidCallback onUlangi;

  const KartuKesalahan({
    super.key,
    required this.pesan,
    required this.onUlangi,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: warnaMerah,
            size: 44,
          ),
          const SizedBox(height: 12),
          Text(
            pesan,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onUlangi,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }
}
