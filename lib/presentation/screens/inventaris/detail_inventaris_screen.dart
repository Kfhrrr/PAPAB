import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/inventaris_model.dart';
import '../../../data/services/inventaris_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/inventaris_provider.dart';
import 'tambah_inventaris_screen.dart';

class DetailInventarisScreen extends StatefulWidget {
  final String id;
  const DetailInventarisScreen({super.key, required this.id});

  @override
  State<DetailInventarisScreen> createState() => _DetailInventarisScreenState();
}

class _DetailInventarisScreenState extends State<DetailInventarisScreen> {
  final _service = InventarisService();
  InventarisModel? _item;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _item = await _service.getById(widget.id);
    setState(() => _loading = false);
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Barang',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Yakin ingin menghapus data barang ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final success = await context.read<InventarisProvider>().delete(
        widget.id,
      );

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Barang berhasil dihapus'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );

        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menghapus data'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Color _kondisiColor(String k) {
    switch (k) {
      case 'baik':
        return AppColors.success;
      case 'perlu_cek':
        return AppColors.warning;
      default:
        return AppColors.danger;
    }
  }

  Color _kondisiBg(String k) {
    switch (k) {
      case 'baik':
        return AppColors.successLight;
      case 'perlu_cek':
        return AppColors.warningLight;
      default:
        return AppColors.dangerLight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.skyPrimary),
            )
          : _item == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 180,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 40),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.inventory_2_rounded,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  actions: isAdmin
                      ? [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    TambahInventarisScreen(existing: _item),
                              ),
                            ).then((_) => _load()),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.dangerLight,
                            ),
                            onPressed: _delete,
                          ),
                        ]
                      : null,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _item!.namaBarang,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.gray800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _kondisiBg(_item!.kondisi),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _item!.kondisiLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _kondisiColor(_item!.kondisi),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _InfoCard(
                          children: [
                            _InfoRow(
                              icon: Icons.category_outlined,
                              label: 'Kategori',
                              value: _item!.kategori,
                            ),
                            _InfoRow(
                              icon: Icons.numbers,
                              label: 'Jumlah',
                              value: '${_item!.jumlah} unit',
                            ),
                            _InfoRow(
                              icon: Icons.location_on_outlined,
                              label: 'Lokasi',
                              value: _item!.lokasi,
                            ),
                            _InfoRow(
                              icon: Icons.calendar_today_outlined,
                              label: 'Ditambahkan',
                              value: AppFormatter.formatDate(_item!.createdAt),
                            ),
                            _InfoRow(
                              icon: Icons.update,
                              label: 'Diperbarui',
                              value: AppFormatter.formatDate(_item!.updatedAt),
                            ),
                            if (_item!.keterangan != null &&
                                _item!.keterangan!.isNotEmpty)
                              _InfoRow(
                                icon: Icons.notes,
                                label: 'Keterangan',
                                value: _item!.keterangan!,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        children: List.generate(
          children.length,
          (i) => Column(
            children: [
              children[i],
              if (i < children.length - 1) const Divider(height: 1, indent: 50),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.skyPrimary),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.gray600),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.gray800,
            ),
          ),
        ],
      ),
    );
  }
}
