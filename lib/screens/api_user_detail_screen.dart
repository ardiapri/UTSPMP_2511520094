
import 'package:flutter/material.dart';

import '../models/api_user_model.dart';

class ApiUserDetailScreen extends StatelessWidget {
  final ApiUserModel user;

  const ApiUserDetailScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 16),
          Center(
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFDBEAFE),
              child: Text(
                user.name.isNotEmpty
                    ? user.name[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 36,
                  color: Color(0xFF2563EB),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              user.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '@${user.username}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          _detailItem(
            icon: Icons.badge_outlined,
            label: 'ID Pengguna',
            value: user.id.toString(),
          ),
          _detailItem(
            icon: Icons.email_outlined,
            label: 'Email',
            value: user.email,
          ),
          _detailItem(
            icon: Icons.phone_outlined,
            label: 'Nomor Telepon',
            value: user.phone,
          ),
          _detailItem(
            icon: Icons.language,
            label: 'Situs Web',
            value: user.website,
          ),
          _detailItem(
            icon: Icons.business_outlined,
            label: 'Perusahaan',
            value: user.companyName.isEmpty
                ? 'Tidak tersedia'
                : user.companyName,
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF2563EB),
        ),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value.isEmpty ? 'Tidak tersedia' : value,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
            ),
          ),
        ),
      ),
    );
  }
}
