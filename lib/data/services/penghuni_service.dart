import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/supabase_constants.dart';

class PenghuniService {
  final _supabase = Supabase.instance.client;

  Future<List<UserModel>> getAll() async {
    final data = await _supabase
        .from(SupabaseConstants.tableUsers)
        .select('*, kamar(nomor_kamar)')
        .eq('role', 'penghuni')
        .order('nama_lengkap');
    return data.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel?> getById(String id) async {
    final data = await _supabase
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('id', id)
        .single();
    return UserModel.fromJson(data);
  }

  Future<void> update(String id, Map<String, dynamic> data) async {
    await _supabase
        .from(SupabaseConstants.tableUsers)
        .update(data)
        .eq('id', id);
  }

  Future<void> delete(String id) async {
    await _supabase.from(SupabaseConstants.tableUsers).delete().eq('id', id);
  }

  Future<List<UserModel>> search(String query) async {
    final data = await _supabase
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('role', 'penghuni')
        .or('nama_lengkap.ilike.%$query%,nim.ilike.%$query%')
        .order('nama_lengkap');
    return data.map((e) => UserModel.fromJson(e)).toList();
  }
}
