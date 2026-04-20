import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/laporan_model.dart';

class LaporanService {
  final _supabase = Supabase.instance.client;

  // Ambil satu laporan by id (admin & penghuni pemilik)
  Future<LaporanModel?> getById(String id) async {
    final data = await _supabase.from('laporan').select().eq('id', id).single();
    return LaporanModel.fromJson(data);
  }

  // Penghuni: ambil laporan milik sendiri
  Future<List<LaporanModel>> getMyLaporan(String penghuniId) async {
    final data = await _supabase
        .from('laporan')
        .select()
        .eq('penghuni_id', penghuniId)
        .order('created_at', ascending: false);
    return data.map((e) => LaporanModel.fromJson(e)).toList();
  }

  // Admin: ambil semua laporan
  Future<List<LaporanModel>> getAllLaporan({String? status}) async {
    var query = _supabase
        .from('laporan')
        .select()
        .order('created_at', ascending: false);
    if (status != null && status != 'semua') {
      query = _supabase
          .from('laporan')
          .select()
          .eq('status', status)
          .order('created_at', ascending: false);
    }
    final data = await query;
    return data.map((e) => LaporanModel.fromJson(e)).toList();
  }

  // Penghuni: kirim laporan baru
  Future<void> create(LaporanModel laporan) async {
    await _supabase.from('laporan').insert(laporan.toJson());
  }

  // Admin: update status laporan
  Future<void> updateStatus(
    String id,
    String status, {
    String? catatanAdmin,
  }) async {
    await _supabase
        .from('laporan')
        .update({
          'status': status,
          'catatan_admin': catatanAdmin,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  // Admin: hapus laporan
  Future<void> delete(String id) async {
    await _supabase.from('laporan').delete().eq('id', id);
  }

  Future<Map<String, int>> getSummary() async {
    // Only called by admin, RLS allows full table access
    try {
      final data = await _supabase.from('laporan').select('status');
      final list = data.map((e) => e['status'] as String).toList();
      return {
        'total': list.length,
        'menunggu': list.where((s) => s == 'menunggu').length,
        'diproses': list.where((s) => s == 'diproses').length,
        'selesai': list.where((s) => s == 'selesai').length,
      };
    } catch (_) {
      return {'total': 0, 'menunggu': 0, 'diproses': 0, 'selesai': 0};
    }
  }
}
