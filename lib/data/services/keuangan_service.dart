import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/keuangan_model.dart';
import '../../core/constants/supabase_constants.dart';

class KeuanganService {
  final _supabase = Supabase.instance.client;

  Future<List<KeuanganModel>> getAll({String? jenis}) async {
    var query = _supabase
        .from(SupabaseConstants.tableKeuangan)
        .select()
        .order('tanggal', ascending: false);

    if (jenis != null && jenis.isNotEmpty) {
      query = _supabase
          .from(SupabaseConstants.tableKeuangan)
          .select()
          .eq('jenis', jenis)
          .order('tanggal', ascending: false);
    }

    final data = await query;
    return data.map((e) => KeuanganModel.fromJson(e)).toList();
  }

  Future<void> create(KeuanganModel transaksi) async {
    final userId = _supabase.auth.currentUser?.id;
    await _supabase.from(SupabaseConstants.tableKeuangan).insert({
      ...transaksi.toJson(),
      'created_by': userId,
    });
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase
        .from(SupabaseConstants.tableKeuangan)
        .update(data)
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from(SupabaseConstants.tableKeuangan).delete().eq('id', id);
  }

  Future<Map<String, int>> getSummary() async {
    final data = await _supabase.from(SupabaseConstants.tableKeuangan).select();
    final list = data.map((e) => KeuanganModel.fromJson(e)).toList();

    int pemasukan = 0;
    int pengeluaran = 0;
    for (final item in list) {
      if (item.isPemasukan) {
        pemasukan += item.jumlah;
      } else {
        pengeluaran += item.jumlah;
      }
    }

    return {
      'saldo': pemasukan - pengeluaran,
      'pemasukan': pemasukan,
      'pengeluaran': pengeluaran,
    };
  }
}
