import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseConstants {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static const String tableUsers = 'users';
  static const String tableInventaris = 'inventaris';
  static const String tableKategoriInventaris = 'kategori_inventaris';
  static const String tableIuran = 'iuran';
  static const String tableKeuangan = 'keuangan';
  static const String tablePenghuni = 'penghuni';
}
