import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/iuran_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/iuran_provider.dart';

class IuranSayaScreen extends StatefulWidget {
  const IuranSayaScreen({super.key});

  @override
  State<IuranSayaScreen> createState() => _IuranSayaScreenState();
}

class _IuranSayaScreenState extends State<IuranSayaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.id;
      if (uid != null) context.read<IuranProvider>().loadMyIuran(uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<IuranProvider>();
    final user = context.watch<AuthProvider>().currentUser;
    final lunas = provider.iuran.where((i) => i.status == 'lunas').length;
    final belum = provider.iuran.where((i) => i.status != 'lunas').length;

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
                const Text(
                  'Status Iuran Saya',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                Text(
                  user?.nomorKamar ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatBox(
                        label: 'Lunas',
                        value: '$lunas',
                        icon: Icons.check_circle_outline,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'Belum Bayar',
                        value: '$belum',
                        icon: Icons.pending_outlined,
                        color: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatBox(
                        label: 'Total Bayar',
                        value: AppFormatter.formatCurrency(
                          provider.iuran
                              .where((i) => i.status == 'lunas')
                              .fold(0, (s, i) => s + i.jumlah),
                        ),
                        icon: Icons.payments_outlined,
                        color: AppColors.skyLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.skyUltra,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.skyLight),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.skyDark,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Hubungi admin/bendahara untuk konfirmasi pembayaran iuran.',
                    style: TextStyle(fontSize: 12, color: AppColors.skyDarker),
                  ),
                ),
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
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.gray200,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada data iuran',
                          style: TextStyle(color: AppColors.gray400),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    color: AppColors.skyPrimary,
                    onRefresh: () {
                      final uid = context.read<AuthProvider>().currentUser?.id;
                      if (uid != null)
                        return context.read<IuranProvider>().loadMyIuran(uid);
                      return Future.value();
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
                      itemCount: provider.iuran.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final item = provider.iuran[i];
                        final isLunas = item.status == 'lunas';
                        return Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: isLunas
                                ? Border.all(
                                    color: AppColors.success.withOpacity(0.25),
                                  )
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: isLunas
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isLunas
                                      ? Icons.check_circle_rounded
                                      : Icons.pending_rounded,
                                  color: isLunas
                                      ? AppColors.success
                                      : AppColors.warning,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.periodLabel,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gray800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      AppFormatter.formatCurrency(item.jumlah),
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.skyDarker,
                                      ),
                                    ),
                                    if (isLunas && item.tanggalBayar != null)
                                      Text(
                                        'Dibayar: ${AppFormatter.formatDate(item.tanggalBayar!)}',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: AppColors.success,
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
                                  color: isLunas
                                      ? AppColors.successLight
                                      : AppColors.warningLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: isLunas
                                        ? AppColors.success
                                        : AppColors.warning,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatBox({
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
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.75),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
