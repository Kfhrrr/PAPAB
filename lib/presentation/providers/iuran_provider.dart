import 'package:flutter/material.dart';
import '../../data/models/iuran_model.dart';
import '../../data/services/iuran_service.dart';

class IuranProvider extends ChangeNotifier {
  final IuranService _service = IuranService();

  List<IuranModel> _iuran = [];
  bool _isLoading = false;
  String? _error;
  int _selectedBulan = DateTime.now().month;
  int _selectedTahun = DateTime.now().year;
  Map<String, dynamic> _summary = {};

  // 🔥 TAMBAHAN
  Set<String> _penghuniSudahAda = {};

  List<IuranModel> get iuran => _iuran;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get selectedBulan => _selectedBulan;
  int get selectedTahun => _selectedTahun;
  Map<String, dynamic> get summary => _summary;

  // 🔥 TAMBAHAN
  Set<String> get penghuniSudahAda => _penghuniSudahAda;

  Future<void> loadAll() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _iuran = await _service.getAll();

      _summary = await _service.getSummaryBulan(_selectedBulan, _selectedTahun);

      // 🔥 TAMBAHAN: ambil penghuni yang sudah punya iuran
      _penghuniSudahAda = _iuran.map((e) => e.penghuniId).toSet();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMyIuran(String penghuniId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _iuran = await _service.getMyIuran(penghuniId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  void setPeriod(int bulan, int tahun) {
    _selectedBulan = bulan;
    _selectedTahun = tahun;
    loadAll();
  }

  Future<bool> buatTagihan({
    required int bulan,
    required int tahun,
    required int jumlah,
    required List<Map<String, String>> penghuniList,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.buatTagihanBulanan(
        bulan: bulan,
        tahun: tahun,
        jumlah: jumlah,
        penghuniList: penghuniList,
      );

      // 🔥 FIX: sync periode
      _selectedBulan = bulan;
      _selectedTahun = tahun;

      await loadAll();

      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Tandai lunas + catat pemasukan
  Future<bool> tandaiLunas(IuranModel item, {String? keterangan}) async {
    try {
      await _service.tandaiLunasDanCatatPemasukan(item, keterangan: keterangan);

      _iuran = await _service.getAll(
        bulan: _selectedBulan,
        tahun: _selectedTahun,
      );

      _summary = await _service.getSummaryBulan(_selectedBulan, _selectedTahun);

      // 🔥 tetap sama
      _penghuniSudahAda = _iuran.map((e) => e.penghuniId).toSet();

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

  // 🔥 TAMBAHAN (OPSIONAL HELPER BIAR UI MUDAH)
  bool isPenghuniDisabled(String penghuniId) {
    return _penghuniSudahAda.contains(penghuniId);
  }
}
