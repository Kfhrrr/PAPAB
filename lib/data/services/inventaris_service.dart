import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/inventaris_model.dart';
import '../../core/constants/supabase_constants.dart';

class InventarisService {
  final _supabase = Supabase.instance.client;

  Future<List<InventarisModel>> getAll({String? kategori}) async {
    var query = _supabase
        .from(SupabaseConstants.tableInventaris)
        .select()
        .order('created_at', ascending: false);

    if (kategori != null && kategori.isNotEmpty && kategori != 'Semua') {
      query = _supabase
          .from(SupabaseConstants.tableInventaris)
          .select()
          .eq('kategori', kategori)
          .order('created_at', ascending: false);
    }

    final data = await query;
    return data.map((e) => InventarisModel.fromJson(e)).toList();
  }

  Future<InventarisModel?> getById(String id) async {
    final data = await _supabase
        .from(SupabaseConstants.tableInventaris)
        .select()
        .eq('id', id)
        .single();
    return InventarisModel.fromJson(data);
  }

  Future<void> create(InventarisModel item) async {
    await _supabase
        .from(SupabaseConstants.tableInventaris)
        .insert(item.toJson());
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase
        .from(SupabaseConstants.tableInventaris)
        .update({...data, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    final res = await _supabase
        .from(SupabaseConstants.tableInventaris)
        .delete()
        .eq('id', id)
        .select(); // 🔥 INI WAJIB

    if (res.isEmpty) {
      throw Exception('Data tidak terhapus');
    }
  }

  Future<List<InventarisModel>> search(String query) async {
    final data = await _supabase
        .from(SupabaseConstants.tableInventaris)
        .select()
        .ilike('nama_barang', '%$query%')
        .order('created_at', ascending: false);
    return data.map((e) => InventarisModel.fromJson(e)).toList();
  }

  Future<Map<String, int>> getSummary() async {
    final data = await _supabase
        .from(SupabaseConstants.tableInventaris)
        .select();
    final list = data.map((e) => InventarisModel.fromJson(e)).toList();
    return {
      'total': list.length,
      'baik': list.where((e) => e.kondisi == 'baik').length,
      'perlu_cek': list.where((e) => e.kondisi == 'perlu_cek').length,
      'rusak': list.where((e) => e.kondisi == 'rusak').length,
    };
  }
}
