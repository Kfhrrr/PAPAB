import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/iuran_model.dart';
import '../../../data/models/keuangan_model.dart';
import '../../providers/keuangan_provider.dart';
import '../../providers/iuran_provider.dart';

class LaporanKeuanganScreen extends StatefulWidget {
  const LaporanKeuanganScreen({super.key});
  @override
  State<LaporanKeuanganScreen> createState() => _LaporanKeuanganScreenState();
}

class _LaporanKeuanganScreenState extends State<LaporanKeuanganScreen> {
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<KeuanganProvider>().loadAll();
      context.read<IuranProvider>().loadAll();
      context.read<IuranProvider>().setPeriod(_bulan, _tahun); // ← TAMBAH INI
    });
  }

  List<KeuanganModel> get _filtered {
    final all = context.read<KeuanganProvider>().transaksi;
    return all
        .where((t) => t.tanggal.month == _bulan && t.tanggal.year == _tahun)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KeuanganProvider>();
    final iuranProvider = context.watch<IuranProvider>();
    final semuaData = [
      ...provider.transaksi,

      ...iuranProvider.iuran
          .where((i) => i.status == 'lunas')
          .map(
            (i) => KeuanganModel(
              id: i.id,
              jenis: 'pemasukan',
              kategori: "Iuran",
              keterangan: "Iuran",
              jumlah: i.jumlah,
              tanggal: DateTime(i.tahun, i.bulan), // ✅ FIX DI SINI
              createdBy: 'system',
              createdAt: DateTime.now(),
            ),
          ),
    ];

    final transaksi = semuaData.where((t) {
      return t.tanggal.month == _bulan && t.tanggal.year == _tahun;
    }).toList();

    final pemasukan = transaksi
        .where((t) => t.isPemasukan)
        .fold(0, (s, t) => s + t.jumlah);
    final pengeluaran = transaksi
        .where((t) => !t.isPemasukan)
        .fold(0, (s, t) => s + t.jumlah);
    final saldo = pemasukan - pengeluaran;
    final Map<String, int> pemasukanByKat = {};
    final Map<String, int> pengeluaranByKat = {};
    for (final t in transaksi) {
      if (t.isPemasukan) {
        pemasukanByKat[t.kategori] =
            (pemasukanByKat[t.kategori] ?? 0) + t.jumlah;
      } else {
        pengeluaranByKat[t.kategori] =
            (pengeluaranByKat[t.kategori] ?? 0) + t.jumlah;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 0,
            backgroundColor: AppColors.skyDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text(
              'Laporan Keuangan',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month),
                onPressed: _showPeriodPicker,
                tooltip: 'Pilih Periode',
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.skyLighter,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.skyLight),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.skyDark,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Laporan ${IuranModel.namaBulan[_bulan]} $_tahun',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.skyDarker,
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _showPeriodPicker,
                          child: const Text(
                            'Ganti',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.skyDark,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Pemasukan',
                          value: AppFormatter.formatCurrency(pemasukan),
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.success,
                          bg: AppColors.successLight,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SummaryCard(
                          label: 'Total Pengeluaran',
                          value: AppFormatter.formatCurrency(pengeluaran),
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.danger,
                          bg: AppColors.dangerLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.skyPrimary, AppColors.skyDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saldo Bersih Bulan Ini',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
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
                        const SizedBox(height: 4),
                        Text(
                          '${transaksi.length} transaksi',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (transaksi.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Column(
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 64,
                              color: AppColors.gray200,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Tidak ada transaksi di ${IuranModel.namaBulan[_bulan]} $_tahun',
                              style: const TextStyle(color: AppColors.gray400),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else ...[
                    if (pemasukanByKat.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Rincian Pemasukan',
                        total: AppFormatter.formatCurrency(pemasukan),
                        color: AppColors.success,
                      ),
                      const SizedBox(height: 8),
                      ...pemasukanByKat.entries.map(
                        (e) => _KategoriRow(
                          label: e.key,
                          amount: e.value,
                          total: pemasukan,
                          color: AppColors.success,
                          bg: AppColors.successLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (pengeluaranByKat.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Rincian Pengeluaran',
                        total: AppFormatter.formatCurrency(pengeluaran),
                        color: AppColors.danger,
                      ),
                      const SizedBox(height: 8),
                      ...pengeluaranByKat.entries.map(
                        (e) => _KategoriRow(
                          label: e.key,
                          amount: e.value,
                          total: pengeluaran,
                          color: AppColors.danger,
                          bg: AppColors.dangerLight,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      'SEMUA TRANSAKSI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.gray400,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...transaksi.map(
                      (t) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: t.isPemasukan
                                    ? AppColors.successLight
                                    : AppColors.dangerLight,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                t.isPemasukan
                                    ? Icons.arrow_downward_rounded
                                    : Icons.arrow_upward_rounded,
                                color: t.isPemasukan
                                    ? AppColors.success
                                    : AppColors.danger,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.keterangan,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.gray800,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${t.kategori} · ${AppFormatter.formatDate(t.tanggal)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppColors.gray400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${t.isPemasukan ? "+" : "-"}${AppFormatter.formatCurrency(t.jumlah)}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: t.isPemasukan
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showPeriodPicker() async {
    int tempBulan = _bulan;
    int tempTahun = _tahun;
    context.read<IuranProvider>().setPeriod(tempBulan, tempTahun);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih Periode',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 14),
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
                  final sel = b == tempBulan;
                  return GestureDetector(
                    onTap: () => setLocal(() => tempBulan = b),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.skyPrimary : AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        IuranModel.namaBulan[b],
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.gray600,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),
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
                children: [2024, 2025, 2026].map((y) {
                  final sel = y == tempTahun;
                  return GestureDetector(
                    onTap: () => setLocal(() => tempTahun = y),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: sel ? AppColors.skyPrimary : AppColors.gray100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$y',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: sel ? Colors.white : AppColors.gray600,
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
                    setState(() {
                      _bulan = tempBulan;
                      _tahun = tempTahun;
                    });

                    Navigator.pop(ctx);

                    Future.delayed(const Duration(milliseconds: 200), () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Menampilkan laporan ${IuranModel.namaBulan[_bulan]} $_tahun',
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    });
                  },
                  child: const Text('Tampilkan Laporan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color, bg;
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.bg,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bg),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6),
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
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.gray400),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title, total;
  final Color color;
  const _SectionHeader({
    required this.title,
    required this.total,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.gray400,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          total,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _KategoriRow extends StatelessWidget {
  final String label;
  final int amount, total;
  final Color color, bg;
  const _KategoriRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
    required this.bg,
  });
  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? amount / total : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray800,
                ),
              ),
              Text(
                AppFormatter.formatCurrency(amount),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor: bg,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(pct * 100).round()}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
