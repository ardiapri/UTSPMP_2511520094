
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/transaction_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _transactions =>
      _db.collection('transactions');

  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _transactions
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final data = snapshot.docs
          .map(
            (doc) => TransactionModel.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();

      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return data;
    });
  }

  Future<void> addTransaction(TransactionModel transaction) async {
    await _transactions.add(transaction.toMap());
  }

  Future<void> updateTransaction(
    TransactionModel transaction,
  ) async {
    if (transaction.id.isEmpty) {
      throw ArgumentError('ID transaksi tidak boleh kosong');
    }

    await _transactions
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  Future<void> deleteTransaction(String id) async {
    await _transactions.doc(id).delete();
  }
}
