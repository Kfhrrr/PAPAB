import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../core/constants/supabase_constants.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<UserModel?> signIn(String email, String password) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user != null) {
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  Future<UserModel?> signUp({
    required String email,
    required String password,
    required String namaLengkap,
    required String nim,
    required String nomorKamar,
    required String nomorHp,
    String nik = '',
    String asalUniversitas = '',
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user != null) {
      await _supabase.from(SupabaseConstants.tableUsers).insert({
        'id': response.user!.id,
        'email': email,
        'nama_lengkap': namaLengkap,
        'nim': nim,
        'nik': nik,
        'asal_universitas': asalUniversitas,
        'nomor_kamar': nomorKamar,
        'nomor_hp': nomorHp,
        'role': 'penghuni',
      });
      return await getUserProfile(response.user!.id);
    }
    return null;
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  Future<UserModel?> getUserProfile(String userId) async {
    final data = await _supabase
        .from(SupabaseConstants.tableUsers)
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromJson(data);
  }

  Future<UserModel?> getCurrentUser() async {
    final session = _supabase.auth.currentSession;
    if (session != null) {
      return await getUserProfile(session.user.id);
    }
    return null;
  }

  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await _supabase
        .from(SupabaseConstants.tableUsers)
        .update(data)
        .eq('id', userId);
  }

  Future<void> deleteUser(String userId) async {
    await _supabase
        .from(SupabaseConstants.tableUsers)
        .delete()
        .eq('id', userId);
  }

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
}
