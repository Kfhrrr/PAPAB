import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventaris_provider.dart';
import '../../providers/keuangan_provider.dart';
import '../../providers/penghuni_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../providers/iuran_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAll());
  }

  Future<void> _loadAll() async {
    final isAdmin = context.read<AuthProvider>().isAdmin;
    final uid = context.read<AuthProvider>().currentUser?.id;
    context.read<InventarisProvider>().loadAll();
    context.read<KeuanganProvider>().loadAll();
    if (isAdmin) {
      context.read<PenghuniProvider>().loadAll();
      context.read<LaporanProvider>().loadAll();
      context.read<IuranProvider>().loadAll();
    } else if (uid != null) {
      context.read<LaporanProvider>().loadMyLaporan(uid);
      context.read<IuranProvider>().loadMyIuran(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final inv = context.watch<InventarisProvider>();
    final keu = context.watch<KeuanganProvider>();
    final pen = context.watch<PenghuniProvider>();
    final lap = context.watch<LaporanProvider>();
    final iuran = context.watch<IuranProvider>();
    final user = auth.currentUser;
    final isAdmin = auth.isAdmin;

    final laporanMenunggu = lap.summary['menunggu'] ?? 0;
    final iuranBelumBayar = iuran.iuran
        .where((i) => i.status != 'lunas')
        .length;
    final inventarisRusak = inv.summary['rusak'] ?? 0;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: RefreshIndicator(
        color: AppColors.skyPrimary,
        onRefresh: _loadAll,
        child: CustomScrollView(
          slivers: [
            // ── HEADER ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.navy, AppColors.skyDark],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top bar
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _greeting(),
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                  Text(
                                    user?.namaLengkap.split(' ').first ??
                                        'Pengguna',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Avatar + badge role
                            GestureDetector(
                              onTap: () => context.go('/profil'),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white.withOpacity(0.2),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.4),
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        user?.initials ?? 'U',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        color: isAdmin
                                            ? AppColors.warning
                                            : AppColors.success,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Kas / Info utama
                        if (isAdmin)
                          _KasCard(
                            saldo: keu.saldo,
                            pemasukan: keu.totalPemasukan,
                            pengeluaran: keu.totalPengeluaran,
                          )
                        else
                          _UserInfoCard(
                            user: user,
                            iuranBelum: iuranBelumBayar,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // ── ALERT BANNERS ──────────────────────────────────────────────
            if (isAdmin && (laporanMenunggu > 0 || inventarisRusak > 0))
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    children: [
                      if (laporanMenunggu > 0)
                        _AlertBanner(
                          icon: Icons.report_outlined,
                          message: '$laporanMenunggu laporan menunggu tindakan',
                          color: AppColors.warning,
                          bg: AppColors.warningLight,
                          onTap: () => context.go('/laporan'),
                        ),
                      if (inventarisRusak > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _AlertBanner(
                            icon: Icons.build_outlined,
                            message:
                                '$inventarisRusak barang inventaris perlu perhatian',
                            color: AppColors.danger,
                            bg: AppColors.dangerLight,
                            onTap: () => context.go('/inventaris'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

            if (!isAdmin && iuranBelumBayar > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: _AlertBanner(
                    icon: Icons.payment_outlined,
                    message: '$iuranBelumBayar iuran belum dibayar',
                    color: AppColors.danger,
                    bg: AppColors.dangerLight,
                    onTap: () => context.go('/iuran/saya'),
                  ),
                ),
              ),

            // ── STATISTIK ADMIN ────────────────────────────────────────────
            if (isAdmin)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Statistik Asrama'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _StatCard(
                              icon: Icons.group_rounded,
                              label: 'Penghuni',
                              value: '${pen.total}',
                              sub: 'terdaftar',
                              color: AppColors.skyPrimary,
                              bg: AppColors.skyLighter,
                              onTap: () => context.go('/penghuni'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.inventory_2_rounded,
                              label: 'Inventaris',
                              value: '${inv.summary['total'] ?? 0}',
                              sub: 'barang',
                              color: AppColors.purple,
                              bg: AppColors.purpleLight,
                              onTap: () => context.go('/inventaris'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _StatCard(
                              icon: Icons.receipt_long_rounded,
                              label: 'Iuran Lunas',
                              value:
                                  '${iuran.summary['lunas'] ?? 0}/${iuran.summary['total'] ?? 0}',
                              sub: 'bulan ini',
                              color: AppColors.success,
                              bg: AppColors.successLight,
                              onTap: () => context.go('/iuran'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // ── MENU UTAMA ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionTitle('Menu'),
                    const SizedBox(height: 10),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.9,
                      children: isAdmin
                          ? _adminMenuItems(context)
                          : _userMenuItems(context),
                    ),
                  ],
                ),
              ),
            ),

            // ── AKTIVITAS TERBARU ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(
                      isAdmin ? 'Transaksi Terbaru' : 'Laporan Saya',
                    ),
                    TextButton(
                      onPressed: () =>
                          context.go(isAdmin ? '/keuangan' : '/laporan'),
                      child: const Text(
                        'Lihat semua',
                        style: TextStyle(
                          color: AppColors.skyDark,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (isAdmin)
              keu.isLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.skyPrimary,
                          ),
                        ),
                      ),
                    )
                  : keu.transaksi.isEmpty
                  ? SliverToBoxAdapter(child: _emptyCard('Belum ada transaksi'))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (ctx, i) => Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: _TransaksiTile(item: keu.transaksi[i]),
                        ),
                        childCount: keu.transaksi.take(5).length,
                      ),
                    )
            else
              lap.isLoading
                  ? const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.skyPrimary,
                          ),
                        ),
                      ),
                    )
                  : lap.laporan.isEmpty
                  ? SliverToBoxAdapter(
                      child: _emptyCard('Belum ada laporan dikirim'),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate((ctx, i) {
                        final item = lap.laporan[i];
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: _LaporanTile(
                            item: item,
                            onTap: () =>
                                context.push('/laporan/detail/${item.id}'),
                          ),
                        );
                      }, childCount: lap.laporan.take(5).length),
                    ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 11) return 'Selamat pagi,';
    if (h < 15) return 'Selamat siang,';
    if (h < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  List<Widget> _adminMenuItems(BuildContext context) => [
    _MenuItem(
      'Inventaris',
      Icons.inventory_2_rounded,
      AppColors.skyLighter,
      AppColors.skyDark,
      () => context.go('/inventaris'),
    ),
    _MenuItem(
      'Keuangan',
      Icons.account_balance_wallet_rounded,
      AppColors.successLight,
      AppColors.success,
      () => context.go('/keuangan'),
    ),
    _MenuItem(
      'Iuran',
      Icons.receipt_long_rounded,
      AppColors.warningLight,
      AppColors.warning,
      () => context.go('/iuran'),
    ),
    _MenuItem(
      'Laporan',
      Icons.report_rounded,
      AppColors.dangerLight,
      AppColors.danger,
      () => context.go('/laporan'),
    ),
    _MenuItem(
      'Penghuni',
      Icons.group_rounded,
      AppColors.purpleLight,
      AppColors.purple,
      () => context.go('/penghuni'),
    ),
    _MenuItem(
      'Laporan Keu.',
      Icons.bar_chart_rounded,
      AppColors.skyLighter,
      AppColors.skyDarker,
      () => context.push('/keuangan/laporan'),
    ),
    _MenuItem(
      'Profil',
      Icons.person_rounded,
      AppColors.gray100,
      AppColors.gray600,
      () => context.go('/profil'),
    ),
  ];

  List<Widget> _userMenuItems(BuildContext context) => [
    _MenuItem(
      'Inventaris',
      Icons.inventory_2_rounded,
      AppColors.skyLighter,
      AppColors.skyDark,
      () => context.go('/inventaris'),
    ),
    _MenuItem(
      'Keuangan',
      Icons.account_balance_wallet_rounded,
      AppColors.successLight,
      AppColors.success,
      () => context.go('/keuangan'),
    ),
    _MenuItem(
      'Iuran Saya',
      Icons.receipt_long_rounded,
      AppColors.warningLight,
      AppColors.warning,
      () => context.go('/iuran/saya'),
    ),
    _MenuItem(
      'Laporan',
      Icons.report_rounded,
      AppColors.dangerLight,
      AppColors.danger,
      () => context.go('/laporan'),
    ),
    _MenuItem(
      'Kirim Laporan',
      Icons.add_circle_outline_rounded,
      AppColors.purpleLight,
      AppColors.purple,
      () => context.push('/laporan/buat'),
    ),
    _MenuItem(
      'Profil',
      Icons.person_rounded,
      AppColors.gray100,
      AppColors.gray600,
      () => context.go('/profil'),
    ),
  ];

  Widget _emptyCard(String msg) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 40, color: AppColors.gray200),
            const SizedBox(height: 8),
            Text(
              msg,
              style: const TextStyle(color: AppColors.gray400, fontSize: 13),
            ),
          ],
        ),
      ),
    ),
  );
}

// ── Kas Card ─────────────────────────────────────────────────────────────────
class _KasCard extends StatelessWidget {
  final int saldo, pemasukan, pengeluaran;
  const _KasCard({
    required this.saldo,
    required this.pemasukan,
    required this.pengeluaran,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Saldo Kas Asrama',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppFormatter.formatCurrency(saldo),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _KasStat(
                  label: 'Pemasukan',
                  value: AppFormatter.formatCurrency(pemasukan),
                  icon: Icons.arrow_downward_rounded,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _KasStat(
                  label: 'Pengeluaran',
                  value: AppFormatter.formatCurrency(pengeluaran),
                  icon: Icons.arrow_upward_rounded,
                  color: AppColors.danger,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _KasStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _KasStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── User Info Card ────────────────────────────────────────────────────────────
class _UserInfoCard extends StatelessWidget {
  final dynamic user;
  final int iuranBelum;
  const _UserInfoCard({required this.user, required this.iuranBelum});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.home_work_rounded, color: Colors.white, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.nomorKamar ?? '-',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.asalUniversitas?.isNotEmpty == true
                      ? user!.asalUniversitas
                      : 'Asrama Putri Paguntaka',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          if (iuranBelum > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.dangerLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$iuranBelum iuran pending',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.danger,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Alert Banner ──────────────────────────────────────────────────────────────
class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color, bg;
  final VoidCallback onTap;
  const _AlertBanner({
    required this.icon,
    required this.message,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Stat Card ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value, sub;
  final Color color, bg;
  final VoidCallback onTap;
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
    required this.bg,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.gray800,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Menu Item ─────────────────────────────────────────────────────────────────
class _MenuItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color, iconColor;
  final VoidCallback onTap;
  const _MenuItem(
    this.label,
    this.icon,
    this.color,
    this.iconColor,
    this.onTap,
  );
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Transaksi Tile ────────────────────────────────────────────────────────────
class _TransaksiTile extends StatelessWidget {
  final dynamic item;
  const _TransaksiTile({required this.item});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: item.isPemasukan
                  ? AppColors.successLight
                  : AppColors.dangerLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              item.isPemasukan
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: item.isPemasukan ? AppColors.success : AppColors.danger,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.keterangan,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  AppFormatter.timeAgo(item.tanggal),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.gray400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.isPemasukan ? "+" : "-"}${AppFormatter.formatCurrency(item.jumlah)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: item.isPemasukan ? AppColors.success : AppColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Laporan Tile ──────────────────────────────────────────────────────────────
class _LaporanTile extends StatelessWidget {
  final dynamic item;
  final VoidCallback onTap;
  const _LaporanTile({required this.item, required this.onTap});

  Color get _statusColor {
    switch (item.status) {
      case 'menunggu':
        return AppColors.warning;
      case 'diproses':
        return AppColors.skyDark;
      case 'selesai':
        return AppColors.success;
      case 'ditolak':
        return AppColors.danger;
      default:
        return AppColors.gray400;
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'menunggu':
        return AppColors.warningLight;
      case 'diproses':
        return AppColors.skyLighter;
      case 'selesai':
        return AppColors.successLight;
      case 'ditolak':
        return AppColors.dangerLight;
      default:
        return AppColors.gray100;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.skyLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.report_outlined,
                color: AppColors.skyDark,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.judul,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    AppFormatter.timeAgo(item.createdAt),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.gray400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _statusBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.statusLabel,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Title ─────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.gray800,
      ),
    );
  }
}
