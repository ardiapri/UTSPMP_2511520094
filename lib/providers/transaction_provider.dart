
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/transaction_model.dart';
import '../services/firestore_service.dart';

enum ViewState {
  loading,
  loaded,
  error,
  empty,
}

class TransactionProvider extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  StreamSubscription<List<TransactionModel>>? _subscription;

  List<TransactionModel> _transactions = [];
  ViewState _state = ViewState.loading;
  String? _errorMessage;
  bool _isSaving = false;

  List<TransactionModel> get transactions => _transactions;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isSaving => _isSaving;

  double get totalPemasukan => _transactions
      .where((item) => item.type == 'Pemasukan')
      .fold(0, (total, item) => total + item.amount);

  double get totalPengeluaran => _transactions
      .where((item) => item.type == 'Pengeluaran')
      .fold(0, (total, item) => total + item.amount);

  double get saldo => totalPemasukan - totalPengeluaran;

  String? get _userId => FirebaseAuth.instance.currentUser?.uid;

  void listenTransactions() {
    final userId = _userId;

    _subscription?.cancel();
    _transactions = [];
    _errorMessage = null;

    if (userId == null) {
      _state = ViewState.error;
      _errorMessage = 'Silakan login terlebih dahulu.';
      notifyListeners();
      return;
    }

    _state = ViewState.loading;
    notifyListeners();

    _subscription = _service.watchTransactions(userId).listen(
      (data) {
        _transactions = data;
        _state = data.isEmpty ? ViewState.empty : ViewState.loaded;
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        _state = ViewState.error;
        _errorMessage = 'Gagal memuat transaksi: $error';
        notifyListeners();
      },
    );
  }

  Future<bool> addTransaction({
    required String title,
    required double amount,
    required String type,
  }) async {
    final userId = _userId;

    if (userId == null || title.trim().isEmpty || amount <= 0) {
      _errorMessage = 'Data transaksi belum valid.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.addTransaction(
        TransactionModel(
          title: title.trim(),
          amount: amount,
          type: type,
          createdAt: DateTime.now(),
          userId: userId,
        ),
      );
      return true;
    } catch (error) {
      _errorMessage = 'Gagal menyimpan transaksi: $error';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      if (_userId == null || transaction.userId != _userId) {
        _errorMessage = 'Transaksi tidak dapat diubah.';
        notifyListeners();
        return false;
      }

      await _service.updateTransaction(transaction);
      return true;
    } catch (error) {
      _errorMessage = 'Gagal mengubah transaksi: $error';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTransaction(TransactionModel transaction) async {
    try {
      if (_userId == null || transaction.userId != _userId) {
        _errorMessage = 'Transaksi tidak dapat dihapus.';
        notifyListeners();
        return false;
      }

      await _service.deleteTransaction(transaction.id);
      return true;
    } catch (error) {
      _errorMessage = 'Gagal menghapus transaksi: $error';
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
