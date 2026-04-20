import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

class MainScreen extends StatelessWidget {
  final Widget child;
  const MainScreen({super.key, required this.child});

  int _locationToIndex(String location, bool isAdmin) {
    if (location.startsWith('/inventaris')) return 1;
    if (location.startsWith('/keuangan')) return 2;
    if (location.startsWith('/iuran')) return 3;
    if (location.startsWith('/laporan')) return 4;
    if (isAdmin && location.startsWith('/penghuni')) return 5;
    if (location.startsWith('/profil')) return isAdmin ? 6 : 5;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    final currentIdx = _locationToIndex(location, isAdmin);

    // Admin: 7 tab — gunakan icon tanpa label teks panjang
    // User:  6 tab
    final List<_NavItem> adminNav = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda', '/'),
      _NavItem(
        Icons.inventory_2_outlined,
        Icons.inventory_2_rounded,
        'Inventaris',
        '/inventaris',
      ),
      _NavItem(
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        'Keuangan',
        '/keuangan',
      ),
      _NavItem(
        Icons.receipt_long_outlined,
        Icons.receipt_long_rounded,
        'Iuran',
        '/iuran',
      ),
      _NavItem(
        Icons.report_outlined,
        Icons.report_rounded,
        'Laporan',
        '/laporan',
      ),
      _NavItem(
        Icons.group_outlined,
        Icons.group_rounded,
        'Penghuni',
        '/penghuni',
      ),
      _NavItem(
        Icons.person_outline_rounded,
        Icons.person_rounded,
        'Profil',
        '/profil',
      ),
    ];

    final List<_NavItem> userNav = [
      _NavItem(Icons.home_outlined, Icons.home_rounded, 'Beranda', '/'),
      _NavItem(
        Icons.inventory_2_outlined,
        Icons.inventory_2_rounded,
        'Inventaris',
        '/inventaris',
      ),
      _NavItem(
        Icons.account_balance_wallet_outlined,
        Icons.account_balance_wallet_rounded,
        'Keuangan',
        '/keuangan',
      ),
      _NavItem(
        Icons.receipt_long_outlined,
        Icons.receipt_long_rounded,
        'Iuran',
        '/iuran/saya',
      ),
      _NavItem(
        Icons.report_outlined,
        Icons.report_rounded,
        'Laporan',
        '/laporan',
      ),
      _NavItem(
        Icons.person_outline_rounded,
        Icons.person_rounded,
        'Profil',
        '/profil',
      ),
    ];

    final navItems = isAdmin ? adminNav : userNav;
    // For admin with 7 tabs, hide labels to save space
    final showLabels = navItems.length <= 6;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: showLabels ? 62 : 54,
            child: Row(
              children: List.generate(navItems.length, (i) {
                final item = navItems[i];
                final isActive = currentIdx == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => context.go(item.route),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: EdgeInsets.symmetric(
                            horizontal: showLabels ? 10 : 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.skyLighter
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isActive ? item.activeIcon : item.icon,
                            color: isActive
                                ? AppColors.skyDark
                                : AppColors.gray400,
                            size: showLabels ? 22 : 20,
                          ),
                        ),
                        if (showLabels) ...[
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: isActive
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isActive
                                  ? AppColors.skyDark
                                  : AppColors.gray400,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon, activeIcon;
  final String label, route;
  _NavItem(this.icon, this.activeIcon, this.label, this.route);
}
