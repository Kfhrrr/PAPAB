import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/constants/supabase_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/inventaris_provider.dart';
import 'presentation/providers/keuangan_provider.dart';
import 'presentation/providers/penghuni_provider.dart';
import 'presentation/providers/laporan_provider.dart';
import 'presentation/providers/iuran_provider.dart';
import 'core/utils/router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await initializeDateFormatting('id_ID', null);
  await Supabase.initialize(
    url: SupabaseConstants.supabaseUrl,
    anonKey: SupabaseConstants.supabaseAnonKey,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => InventarisProvider()),
        ChangeNotifierProvider(create: (_) => KeuanganProvider()),
        ChangeNotifierProvider(create: (_) => PenghuniProvider()),
        ChangeNotifierProvider(create: (_) => LaporanProvider()),
        ChangeNotifierProvider(create: (_) => IuranProvider()),
      ],
      // PENTING: Builder di sini memastikan context yang masuk ke
      // MaterialApp.router sudah punya akses ke semua Provider di atas.
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'Asrama Paguntaka',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
