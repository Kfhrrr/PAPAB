import 'package:flutter/material.dart';
import '../../data/models/keuangan_model.dart';
import '../../data/services/keuangan_service.dart';
import '../../data/models/iuran_model.dart';

class KeuanganProvider extends ChangeNotifier {
  final KeuanganService _service = KeuanganService();

  List<KeuanganModel> _transaksi = [];
  bool _isLoading = false;
  String? _error;
  String _filter = 'semua';
  Map<String, int> _summary = {'saldo': 0, 'pemasukan': 0, 'pengeluaran': 0};

  List<KeuanganModel> get transaksi => _transaksi;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filter => _filter;
  Map<String, int> get summary => _summary;
  int get saldo => _summary['saldo'] ?? 0;
  int get totalPemasukan => _summary['pemasukan'] ?? 0;
  int get totalPengeluaran => _summary['pengeluaran'] ?? 0;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _transaksi = await _service.getAll(
        jenis: _filter == 'semua' ? null : _filter,
      );

      _summary = await _service.getSummary();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String filter) {
    _filter = filter;
    loadAll();
  }

  Future<bool> create(KeuanganModel transaksi) async {
    try {
      await _service.create(transaksi);
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
