import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/dashboard/main_screen.dart';
import '../../presentation/screens/inventaris/inventaris_screen.dart';
import '../../presentation/screens/inventaris/tambah_inventaris_screen.dart';
import '../../presentation/screens/inventaris/detail_inventaris_screen.dart';
import '../../presentation/screens/keuangan/keuangan_screen.dart';
import '../../presentation/screens/keuangan/tambah_transaksi_screen.dart';
import '../../presentation/screens/keuangan/laporan_keuangan_screen.dart';
import '../../presentation/screens/iuran/iuran_screen.dart';
import '../../presentation/screens/iuran/buat_tagihan_screen.dart';
import '../../presentation/screens/iuran/iuran_saya_screen.dart';
import '../../presentation/screens/laporan/laporan_screen.dart';
import '../../presentation/screens/laporan/buat_laporan_screen.dart';
import '../../presentation/screens/laporan/detail_laporan_screen.dart';
import '../../presentation/screens/penghuni/penghuni_screen.dart';
import '../../presentation/screens/penghuni/tambah_penghuni_screen.dart';
import '../../presentation/screens/penghuni/detail_penghuni_screen.dart';
import '../../presentation/screens/profil/profil_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final loc = state.matchedLocation;
      final isAuthRoute =
          loc == '/login' || loc == '/register' || loc == '/splash';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && loc == '/login') return '/';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      ShellRoute(
        builder: (context, state, child) => MainScreen(child: child),
        routes: [
          GoRoute(path: '/', builder: (_, __) => const DashboardScreen()),
          GoRoute(
            path: '/inventaris',
            builder: (_, __) => const InventarisScreen(),
            routes: [
              GoRoute(
                path: 'tambah',
                builder: (_, __) => const TambahInventarisScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (_, s) =>
                    DetailInventarisScreen(id: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/keuangan',
            builder: (_, __) => const KeuanganScreen(),
            routes: [
              GoRoute(
                path: 'tambah',
                builder: (_, __) => const TambahTransaksiScreen(),
              ),
              GoRoute(
                path: 'laporan',
                builder: (_, __) => const LaporanKeuanganScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/iuran',
            builder: (_, __) => const IuranScreen(),
            routes: [
              GoRoute(
                path: 'buat',
                builder: (_, __) => const BuatTagihanScreen(),
              ),
              GoRoute(
                path: 'saya',
                builder: (_, __) => const IuranSayaScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/laporan',
            builder: (_, __) => const LaporanScreen(),
            routes: [
              GoRoute(
                path: 'buat',
                builder: (_, __) => const BuatLaporanScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (_, s) =>
                    DetailLaporanScreen(id: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(
            path: '/penghuni',
            builder: (_, __) => const PenghuniScreen(),
            routes: [
              GoRoute(
                path: 'tambah',
                builder: (_, __) => const TambahPenghuniScreen(),
              ),
              GoRoute(
                path: 'detail/:id',
                builder: (_, s) =>
                    DetailPenghuniScreen(id: s.pathParameters['id']!),
              ),
            ],
          ),
          GoRoute(path: '/profil', builder: (_, __) => const ProfilScreen()),
        ],
      ),
    ],
  );
}
