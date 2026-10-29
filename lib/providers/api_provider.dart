
import 'package:flutter/foundation.dart';

import '../models/api_user_model.dart';
import '../services/api_service.dart';
import 'transaction_provider.dart' show ViewState;

class ApiProvider extends ChangeNotifier {
  final ApiService _service = ApiService();

  List<ApiUserModel> _users = [];
  ViewState _state = ViewState.loading;
  String? _errorMessage;

  List<ApiUserModel> get users => _users;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.getUsers();

      _users = result;
      _state = result.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (error) {
      _state = ViewState.error;
      _errorMessage = error.toString();
    }

    notifyListeners();
  }
}
