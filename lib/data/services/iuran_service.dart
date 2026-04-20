import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/iuran_model.dart';
import '../../core/constants/supabase_constants.dart';

class IuranService {
  final _supabase = Supabase.instance.client;

  Future<List<IuranModel>> getAll({int? bulan, int? tahun}) async {
    var query = _supabase
        .from('iuran')
        .select()
        .order('created_at', ascending: false);

    if (bulan != null && tahun != null) {
      query = _supabase
          .from('iuran')
          .select()
          .eq('bulan', bulan)
          .eq('tahun', tahun)
          .order('nomor_kamar');
    }

    final data = await query;
    return data.map((e) => IuranModel.fromJson(e)).toList();
  }

  Future<List<IuranModel>> getMyIuran(String penghuniId) async {
    final data = await _supabase
        .from('iuran')
        .select()
        .eq('penghuni_id', penghuniId)
        .order('tahun', ascending: false)
        .order('bulan', ascending: false);

    return data.map((e) => IuranModel.fromJson(e)).toList();
  }

  /// ✅ FIX DI SINI
  Future<void> buatTagihanBulanan({
    required int bulan,
    required int tahun,
    required int jumlah,
    required List<Map<String, String>> penghuniList,
  }) async {
    // 1. Ambil data iuran yang sudah ada di periode ini
    final existing = await _supabase
        .from('iuran')
        .select('penghuni_id')
        .eq('bulan', bulan)
        .eq('tahun', tahun);

    final existingIds = existing.map((e) => e['penghuni_id']).toSet();

    // 2. Filter penghuni yang BELUM punya tagihan
    final filtered = penghuniList.where((p) {
      return !existingIds.contains(p['id']);
    }).toList();

    // ❗ Jika semua sudah ada → hentikan
    if (filtered.isEmpty) {
      throw Exception(
        'Semua penghuni sudah memiliki tagihan pada bulan $bulan tahun $tahun',
      );
    }

    // 3. Mapping data
    final rows = filtered
        .map(
          (p) => {
            'penghuni_id': p['id'],
            'penghuni_nama': p['nama'],
            'nomor_kamar': p['kamar'],
            'bulan': bulan,
            'tahun': tahun,
            'jumlah': jumlah,
            'status': 'belum_bayar',
          },
        )
        .toList();

    // 4. Insert (TIDAK pakai upsert lagi)
    await _supabase.from('iuran').insert(rows);
  }

  Future<String?> tandaiLunasDanCatatPemasukan(
    IuranModel item, {
    String? keterangan,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    final now = DateTime.now().toIso8601String();

    // 1. Insert ke keuangan
    final keuanganRes = await _supabase
        .from(SupabaseConstants.tableKeuangan)
        .insert({
          'jenis': 'pemasukan',
          'kategori': 'Kas',
          'keterangan':
              'Iuran ${item.periodLabel} - ${item.penghuniNama} (${item.nomorKamar})',
          'jumlah': item.jumlah,
          'penghuni_id': item.penghuniId,
          'penghuni_nama': item.penghuniNama,
          'tanggal': now,
          'created_by': userId,
        })
        .select('id')
        .single();

    final keuanganId = keuanganRes['id'] as String?;

    // 2. Update iuran
    await _supabase
        .from('iuran')
        .update({
          'status': 'lunas',
          'tanggal_bayar': now,
          'keuangan_id': keuanganId,
          'keterangan_admin': keterangan,
        })
        .eq('id', item.id);

    return keuanganId;
  }

  Future<void> updateStatus(String id, String status) async {
    await _supabase.from('iuran').update({'status': status}).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from('iuran').delete().eq('id', id);
  }

  Future<Set<String>> getPenghuniSudahAdaIuran(int bulan, int tahun) async {
    final data = await _supabase
        .from('iuran')
        .select('penghuni_id')
        .eq('bulan', bulan)
        .eq('tahun', tahun);

    return data.map<String>((e) => e['penghuni_id'] as String).toSet();
  }

  Future<Map<String, dynamic>> getSummaryBulan(int bulan, int tahun) async {
    final data = await _supabase
        .from('iuran')
        .select()
        .eq('bulan', bulan)
        .eq('tahun', tahun);

    final list = data.map((e) => IuranModel.fromJson(e)).toList();

    final lunas = list.where((e) => e.status == 'lunas').length;
    final total = list.length;

    final totalTerkumpul = list
        .where((e) => e.status == 'lunas')
        .fold(0, (sum, e) => sum + e.jumlah);

    return {
      'total': total,
      'lunas': lunas,
      'belum_bayar': total - lunas,
      'total_terkumpul': totalTerkumpul,
      'persentase': total > 0 ? ((lunas / total) * 100).round() : 0,
    };
  }
}
