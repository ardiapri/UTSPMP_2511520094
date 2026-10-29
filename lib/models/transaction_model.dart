
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String type;
  final DateTime createdAt;
  final String userId;

  const TransactionModel({
    this.id = '',
    required this.title,
    required this.amount,
    required this.type,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory TransactionModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final waktu = map['createdAt'];

    return TransactionModel(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      type: map['type'] as String? ?? 'Pemasukan',
      createdAt: waktu is Timestamp
          ? waktu.toDate()
          : DateTime.now(),
      userId: map['userId'] as String? ?? '',
    );
  }
}
