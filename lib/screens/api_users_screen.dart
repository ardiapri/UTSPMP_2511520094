
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import '../providers/api_provider.dart';
import '../providers/transaction_provider.dart';
import 'api_user_detail_screen.dart';

class ApiUsersScreen extends StatefulWidget {
  const ApiUsersScreen({super.key});

  @override
  State<ApiUsersScreen> createState() => _ApiUsersScreenState();
}

class _ApiUsersScreenState extends State<ApiUsersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ApiProvider>().fetchUsers();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final api = context.watch<ApiProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text(
          'Pengguna API',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Muat ulang',
            onPressed: api.fetchUsers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(api),
    );
  }

  Widget _buildBody(ApiProvider api) {
    switch (api.state) {
      case ViewState.loading:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Sedang mengambil data pengguna...'),
            ],
          ),
        );

      case ViewState.error:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off,
                  size: 64,
                  color: Colors.red,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Data gagal dimuat',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  api.errorMessage ?? 'Periksa koneksi internet kamu.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: api.fetchUsers,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );

      case ViewState.empty:
        return const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.people_outline, size: 64),
              SizedBox(height: 12),
              Text('Belum ada data pengguna.'),
            ],
          ),
        );

      case ViewState.loaded:
        return RefreshIndicator(
          onRefresh: api.fetchUsers,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: api.users.length,
            itemBuilder: (context, index) {
              final user = api.users[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: 1,
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFDBEAFE),
                    child: Text(
                      user.name.isNotEmpty
                          ? user.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        if (user.companyName.isNotEmpty)
                          Text('Perusahaan: ${user.companyName}'),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            ApiUserDetailScreen(user: user),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
    }
  }
}
