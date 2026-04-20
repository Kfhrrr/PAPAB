import 'package:flutter/material.dart';
import '../../data/models/user_model.dart';
import '../../data/services/penghuni_service.dart';

class PenghuniProvider extends ChangeNotifier {
  final PenghuniService _service = PenghuniService();

  List<UserModel> _penghuni = [];
  bool _isLoading = false;
  String? _error;

  List<UserModel> get penghuni => _penghuni;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get total => _penghuni.length;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _penghuni = await _service.getAll();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      loadAll();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _penghuni = await _service.search(query);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> update(String id, Map<String, dynamic> data) async {
    try {
      await _service.update(id, data);
      await loadAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> delete(String id) async {
    try {
      await _service.delete(id);
      await loadAll();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
