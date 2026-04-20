import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/iuran_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/iuran_provider.dart';

class IuranScreen extends StatefulWidget {
  const IuranScreen({super.key});

  @override
  State<IuranScreen> createState() => _IuranScreenState();
}

class _IuranScreenState extends State<IuranScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAdmin = context.read<AuthProvider>().isAdmin;
      if (!isAdmin) {
        context.go('/iuran/saya');
        return;
      }
      context.read<IuranProvider>().loadAll();
    });
  }

  Future<void> _tandaiLunas(IuranModel item) async {
    final keteranganCtrl = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tandai Lunas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tandai iuran ${item.periodLabel} untuk ${item.penghuniNama} sebagai lunas?',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keteranganCtrl,
              decoration: const InputDecoration(
                labelText: 'Keterangan (opsional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Tandai Lunas'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<IuranProvider>().tandaiLunas(
        item,
        keterangan: keteranganCtrl.text.trim().isEmpty
            ? null
            : keteranganCtrl.text.trim(),
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iuran lunas & bukti tersimpan ✓'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    }
  }

  Future<void> _showPeriodPicker() async {
    final provider = context.read<IuranProvider>();
    int tempBulan = provider.selectedBulan;
    int tempTahun = provider.selectedTahun;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Periode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bulan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(12, (i) {
                  final b = i + 1;
                  final selected = b == tempBulan;
                  return GestureDetector(
                    onTap: () => setLocal(() => tempBulan = b),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.skyPrimary
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        IuranModel.namaBulan[b],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.gray600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),
              const Text(
                'Tahun',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [2023, 2024, 2025, 2026].map((y) {
                  final selected = y == tempTahun;
                  return GestureDetector(
                    onTap: () => setLocal(() => tempTahun = y),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.skyPrimary
                            : AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : AppColors.gray600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    provider.setPeriod(tempBulan, tempTahun);
                    Navigator.pop(context);
                  },
                  child: const Text('Terapkan'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IuranProvider>();
    final summary = provider.summary;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: AppColors.navyGradient,
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
                            'Kelola Iuran',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Manajemen iuran bulanan penghuni',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: _showPeriodPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${IuranModel.namaBulan[provider.selectedBulan]} ${provider.selectedTahun}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _SummaryChip(
                      label: 'Total',
                      value: '${summary['total'] ?? 0}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Lunas',
                      value: '${summary['lunas'] ?? 0}',
                      color: AppColors.successLight,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Belum Bayar',
                      value: '${summary['belum_bayar'] ?? 0}',
                      color: AppColors.dangerLight,
                    ),
                    const SizedBox(width: 8),
                    _SummaryChip(
                      label: 'Terkumpul',
                      value: AppFormatter.formatCurrency(
                        summary['total_terkumpul'] ?? 0,
                      ),
                      color: AppColors.warningLight,
                    ),
                  ],
                ),
                if ((summary['total'] ?? 0) > 0) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (summary['persentase'] ?? 0) / 100,
                      backgroundColor: Colors.white.withOpacity(0.25),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${summary['persentase'] ?? 0}% sudah lunas',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: provider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.skyPrimary,
                    ),
                  )
                : provider.iuran.isEmpty
                ? _emptyState()
                : RefreshIndicator(
                    color: AppColors.skyPrimary,
                    onRefresh: () => provider.loadAll(),
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: provider.iuran.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) => _IuranCard(
                        item: provider.iuran[i],
                        onTandaiLunas: () => _tandaiLunas(provider.iuran[i]),
                        onHapus: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Hapus'),
                              content: const Text('Yakin hapus data ini?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(false),
                                  child: const Text('Batal'),
                                ),
                                ElevatedButton(
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(true),
                                  child: const Text('Hapus'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true && context.mounted) {
                            await context.read<IuranProvider>().delete(
                              provider.iuran[i].id,
                            );
                          }
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'buat',
            onPressed: () => context.push('/iuran/buat'),
            backgroundColor: AppColors.skyPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Buat Tagihan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.gray200),
          const SizedBox(height: 12),
          const Text(
            'Belum ada data iuran',
            style: TextStyle(color: AppColors.gray400, fontSize: 14),
          ),
          const SizedBox(height: 4),
          const Text(
            'Buat tagihan untuk bulan ini',
            style: TextStyle(color: AppColors.gray400, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _IuranCard extends StatelessWidget {
  final IuranModel item;
  final VoidCallback onTandaiLunas;
  final VoidCallback onHapus;

  const _IuranCard({
    required this.item,
    required this.onTandaiLunas,
    required this.onHapus,
  });

  Color get _statusColor {
    switch (item.status) {
      case 'lunas':
        return AppColors.success;
      case 'terlambat':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }

  Color get _statusBg {
    switch (item.status) {
      case 'lunas':
        return AppColors.successLight;
      case 'terlambat':
        return AppColors.dangerLight;
      default:
        return AppColors.warningLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: item.status == 'lunas'
            ? Border.all(color: AppColors.success.withOpacity(0.2))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.skyLighter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    item.penghuniNama.isNotEmpty
                        ? item.penghuniNama[0].toUpperCase()
                        : 'P',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppColors.skyDarker,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.penghuniNama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray800,
                      ),
                    ),
                    Text(
                      '${item.nomorKamar} · ${item.periodLabel}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.gray400,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: _statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Jumlah Tagihan',
                      style: TextStyle(fontSize: 10, color: AppColors.gray400),
                    ),
                    Text(
                      AppFormatter.formatCurrency(item.jumlah),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.gray800,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.status == 'lunas' && item.tanggalBayar != null)
                Text(
                  'Bayar: ${AppFormatter.formatDate(item.tanggalBayar!)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.success,
                  ),
                ),
            ],
          ),
          if (item.status != 'lunas') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onHapus,
                    icon: const Icon(Icons.delete_outline, size: 16),
                    label: const Text('Hapus'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      side: const BorderSide(color: AppColors.danger),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onTandaiLunas,
                    icon: const Icon(Icons.check_circle_outline, size: 16),
                    label: const Text('Tandai Lunas'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 8,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
