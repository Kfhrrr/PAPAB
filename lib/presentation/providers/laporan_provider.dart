import 'package:flutter/material.dart';
import '../../data/models/laporan_model.dart';
import '../../data/services/laporan_service.dart';

class LaporanProvider extends ChangeNotifier {
  final LaporanService _service = LaporanService();

  List<LaporanModel> _laporan = [];
  bool _isLoading = false;
  String? _error;
  String _filterStatus = 'semua';
  Map<String, int> _summary = {};

  List<LaporanModel> get laporan => _laporan;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get filterStatus => _filterStatus;
  Map<String, int> get summary => _summary;

  Future<void> loadAll({String? status}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _laporan = await _service.getAllLaporan(
        status: _filterStatus == 'semua' ? null : _filterStatus,
      );
      _summary = await _service.getSummary();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyLaporan(String penghuniId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _laporan = await _service.getMyLaporan(penghuniId);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    loadAll();
  }

  Future<bool> create(LaporanModel laporan) async {
    try {
      await _service.create(laporan);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateStatus(String id, String status, {String? catatan}) async {
    try {
      await _service.updateStatus(id, status, catatanAdmin: catatan);
      // Reload data dulu sebelum notifyListeners, hindari rebuild di tengah proses
      _laporan = await _service.getAllLaporan(
        status: _filterStatus == 'semua' ? null : _filterStatus,
      );
      _summary = await _service.getSummary();
      notifyListeners();
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
