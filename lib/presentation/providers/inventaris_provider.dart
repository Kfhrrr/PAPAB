import 'package:flutter/material.dart';
import '../../data/models/inventaris_model.dart';
import '../../data/services/inventaris_service.dart';

class InventarisProvider extends ChangeNotifier {
  final InventarisService _service = InventarisService();

  List<InventarisModel> _items = [];
  bool _isLoading = false;
  String? _error;
  String _selectedKategori = 'Semua';
  Map<String, int> _summary = {};

  List<InventarisModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedKategori => _selectedKategori;
  Map<String, int> get summary => _summary;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.getAll(
        kategori: _selectedKategori == 'Semua' ? null : _selectedKategori,
      );
      _summary = await _service.getSummary();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setKategori(String kategori) {
    _selectedKategori = kategori;
    loadAll();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      loadAll();
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _service.search(query);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> create(InventarisModel item) async {
    try {
      await _service.create(item);

      _selectedKategori = 'Semua'; // 🔥 INI KUNCINYA
      await loadAll();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
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
