import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/laporan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      final uid = context.read<AuthProvider>().currentUser?.id;
      if (isAdmin) {
        context.read<LaporanProvider>().loadAll();
      } else if (uid != null) {
        context.read<LaporanProvider>().loadMyLaporan(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;
    return isAdmin ? const _AdminLaporanView() : const _UserLaporanView();
  }
}

// ===================== ADMIN VIEW =====================
class _AdminLaporanView extends StatelessWidget {
  const _AdminLaporanView();

  final _filterOptions = const {
    'semua': 'Semua',
    'menunggu': 'Menunggu',
    'diproses': 'Diproses',
    'selesai': 'Selesai',
  };

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kelola Laporan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const Text(
                  'Laporan masuk dari penghuni',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _Chip('Total', '${summary['total'] ?? 0}', Colors.white),
                    const SizedBox(width: 8),
                    _Chip(
                      'Menunggu',
                      '${summary['menunggu'] ?? 0}',
                      AppColors.warningLight,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      'Diproses',
                      '${summary['diproses'] ?? 0}',
                      AppColors.skyLighter,
                    ),
                    const SizedBox(width: 8),
                    _Chip(
                      'Selesai',
                      '${summary['selesai'] ?? 0}',
                      AppColors.successLight,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filter tabs
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: _filterOptions.entries.map((e) {
                final isSelected = provider.filterStatus == e.key;
                return GestureDetector(
                  onTap: () => provider.setFilter(e.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.skyPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.skyPrimary
                            : AppColors.gray200,
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.gray600,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.skyPrimary,
                    ),
                  )
                : provider.laporan.isEmpty
                ? _emptyState('Tidak ada laporan', 'Belum ada laporan masuk')
                : RefreshIndicator(
                    color: AppColors.skyPrimary,
                    onRefresh: () async {
                      await provider.loadAll();

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data laporan berhasil diperbarui'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: provider.laporan.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _LaporanCard(
                        item: provider.laporan[i],
                        isAdmin: true,
                        onTap: () => context.push(
                          '/laporan/detail/${provider.laporan[i].id}',
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ===================== USER VIEW =====================
class _UserLaporanView extends StatelessWidget {
  const _UserLaporanView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LaporanProvider>();

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Laporan Saya',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Laporan & pengaduan yang saya kirim',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/laporan/buat'),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.skyDarker,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.skyUltra,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.skyLight),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.skyDark, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Anda dapat melaporkan kerusakan, masalah kebersihan, keamanan, atau hal lainnya kepada admin.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.skyDarker,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.skyPrimary,
                    ),
                  )
                : provider.laporan.isEmpty
                ? _emptyState(
                    'Belum ada laporan',
                    'Tekan tombol "Kirim Laporan" untuk membuat laporan baru',
                  )
                : RefreshIndicator(
                    color: AppColors.skyPrimary,
                    onRefresh: () {
                      final uid = context.read<AuthProvider>().currentUser?.id;
                      if (uid != null)
                        return context.read<LaporanProvider>().loadMyLaporan(
                          uid,
                        );
                      return Future.value();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                      itemCount: provider.laporan.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _LaporanCard(
                        item: provider.laporan[i],
                        isAdmin: false,
                        onTap: () => context.push(
                          '/laporan/detail/${provider.laporan[i].id}',
                        ),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// ===================== SHARED WIDGETS =====================
Widget _emptyState(String title, String sub) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.report_off_outlined, size: 64, color: AppColors.gray200),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppColors.gray600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          sub,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.gray400),
        ),
      ],
    ),
  );
}

class _Chip extends StatelessWidget {
  final String label, value;
  final Color color;
  const _Chip(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }
}

class _LaporanCard extends StatelessWidget {
  final LaporanModel item;
  final bool isAdmin;
  final VoidCallback onTap;
  const _LaporanCard({
    required this.item,
    required this.isAdmin,
    required this.onTap,
  });

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

  IconData get _jenisIcon {
    switch (item.jenis) {
      case 'kerusakan':
        return Icons.build_outlined;
      case 'kebersihan':
        return Icons.cleaning_services_outlined;
      case 'keamanan':
        return Icons.security_outlined;
      default:
        return Icons.notes_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.skyLighter,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_jenisIcon, color: AppColors.skyDark, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gray100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              item.jenisLabel,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gray600,
                              ),
                            ),
                          ),
                          if (isAdmin)
                            Text(
                              '${item.penghuniNama} · ${item.nomorKamar}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.gray400,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
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
                    const SizedBox(height: 4),
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.gray400,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.deskripsi,
              style: const TextStyle(fontSize: 11, color: AppColors.gray600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              AppFormatter.timeAgo(item.createdAt),
              style: const TextStyle(fontSize: 10, color: AppColors.gray400),
            ),
          ],
        ),
      ),
    );
  }
}
