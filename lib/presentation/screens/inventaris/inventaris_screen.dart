import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventaris_provider.dart';
import '../../../data/models/inventaris_model.dart';

class InventarisScreen extends StatefulWidget {
  const InventarisScreen({super.key});

  @override
  State<InventarisScreen> createState() => _InventarisScreenState();
}

class _InventarisScreenState extends State<InventarisScreen> {
  final _searchCtrl = TextEditingController();

  final List<String> _kategoriList = ['Semua', ...InventarisModel.kategoriList];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventarisProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _kondisiColor(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return AppColors.success;
      case 'perlu_cek':
        return AppColors.warning;
      case 'rusak':
        return AppColors.danger;
      default:
        return AppColors.gray400;
    }
  }

  Color _kondisiBg(String kondisi) {
    switch (kondisi) {
      case 'baik':
        return AppColors.successLight;
      case 'perlu_cek':
        return AppColors.warningLight;
      case 'rusak':
        return AppColors.dangerLight;
      default:
        return AppColors.gray100;
    }
  }

  IconData _kategoriIcon(String kategori) {
    switch (kategori) {
      case 'Furnitur':
        return Icons.chair_rounded;
      case 'Elektronik':
        return Icons.tv_rounded;
      case 'Kebersihan':
        return Icons.cleaning_services_rounded;
      case 'Dapur':
        return Icons.kitchen_rounded;
      case 'Perlengkapan Mandi':
        return Icons.shower_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _kategoriColor(String kategori) {
    switch (kategori) {
      case 'Furnitur':
        return AppColors.skyLighter;
      case 'Elektronik':
        return AppColors.purpleLight;
      case 'Kebersihan':
        return AppColors.successLight;
      case 'Dapur':
        return AppColors.warningLight;
      default:
        return AppColors.gray100;
    }
  }

  Color _kategoriIconColor(String kategori) {
    switch (kategori) {
      case 'Furnitur':
        return AppColors.skyDark;
      case 'Elektronik':
        return AppColors.purple;
      case 'Kebersihan':
        return AppColors.success;
      case 'Dapur':
        return AppColors.warning;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<InventarisProvider>();
    final isAdmin = context.watch<AuthProvider>().isAdmin;

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
                            'Inventaris Asrama',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'Kelola barang-barang asrama',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _StatChip(
                      label: 'Total',
                      value: '${provider.summary['total'] ?? 0}',
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Baik',
                      value: '${provider.summary['baik'] ?? 0}',
                      color: AppColors.successLight,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Perlu Cek',
                      value: '${provider.summary['perlu_cek'] ?? 0}',
                      color: AppColors.warningLight,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      label: 'Rusak',
                      value: '${provider.summary['rusak'] ?? 0}',
                      color: AppColors.dangerLight,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.35)),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Cari nama barang...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 13,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withOpacity(0.7),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Colors.white.withOpacity(0.7),
                                size: 18,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                provider.loadAll();
                              },
                            )
                          : null,
                    ),
                    onChanged: (v) => provider.search(v),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _kategoriList.length,
              itemBuilder: (context, i) {
                final k = _kategoriList[i];
                final isSelected = provider.selectedKategori == k;
                return GestureDetector(
                  onTap: () => provider.setKategori(k),
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
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.skyPrimary.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : [],
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : AppColors.gray600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          if (!isAdmin)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.skyUltra,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.skyLight),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.visibility_outlined,
                    color: AppColors.skyDark,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Mode lihat saja. Hubungi admin untuk perubahan data inventaris.',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.skyDarker,
                      ),
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
                : provider.items.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 64,
                          color: AppColors.gray200,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada data inventaris',
                          style: TextStyle(color: AppColors.gray400),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: provider.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final item = provider.items[i];
                      return GestureDetector(
                        onTap: () =>
                            context.push('/inventaris/detail/${item.id}'),
                        child: Container(
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
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: _kategoriColor(item.kategori),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  _kategoriIcon(item.kategori),
                                  color: _kategoriIconColor(item.kategori),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.namaBarang,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.gray800,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${item.kategori} · ${item.lokasi}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.gray400,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.skyLighter,
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                          ),
                                          child: Text(
                                            item.jumlahDisplay,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.skyDarker,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                  color: _kondisiBg(item.kondisi),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.kondisiLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: _kondisiColor(item.kondisi),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => context.push('/inventaris/tambah'),
              backgroundColor: AppColors.skyPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
