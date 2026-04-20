import 'package:supabase_flutter/supabase_flutter.dart';

class KamarService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getKamar() async {
    final data = await _supabase.from('kamar').select();
    return List<Map<String, dynamic>>.from(data);
  }
}
