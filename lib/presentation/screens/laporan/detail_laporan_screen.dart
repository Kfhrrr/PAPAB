import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/laporan_model.dart';
import '../../../data/services/laporan_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';

class DetailLaporanScreen extends StatefulWidget {
  final String id;
  const DetailLaporanScreen({super.key, required this.id});

  @override
  State<DetailLaporanScreen> createState() => _DetailLaporanScreenState();
}

class _DetailLaporanScreenState extends State<DetailLaporanScreen> {
  final _service = LaporanService();
  final _catatanCtrl = TextEditingController();
  LaporanModel? _laporan;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    try {
      final data = await _service.getById(widget.id);
      if (!mounted) return;
      setState(() {
        _laporan = data;
        _catatanCtrl.text = _laporan?.catatanAdmin ?? '';
      });
    } catch (_) {}
    if (!mounted) return;
    setState(() => _loading = false);
  }

  @override
  void dispose() {
    _catatanCtrl.dispose();
    super.dispose();
  }

  Future<void> _updateStatus(String status) async {
    // Simpan context sebelum async gap agar tidak stale
    final ctx = context;
    final label = {
      'diproses': 'Diproses',
      'selesai': 'Selesai',
      'ditolak': 'Ditolak',
    }[status];

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Ubah Status ke "$label"',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Yakin ubah status laporan ini menjadi "$label"?'),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Catatan Admin (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
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
            style: ElevatedButton.styleFrom(
              backgroundColor: status == 'ditolak'
                  ? AppColors.danger
                  : AppColors.skyPrimary,
            ),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final ok = await context.read<LaporanProvider>().updateStatus(
        widget.id,
        status,
        catatan: _catatanCtrl.text.trim().isEmpty
            ? null
            : _catatanCtrl.text.trim(),
      );

      if (ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status laporan diubah ke "$label"'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        await _load();
      }
    }
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Laporan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Yakin ingin menghapus laporan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<LaporanProvider>().delete(widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil dihapus'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );

      if (mounted) context.pop();
    }
  }

  Color _statusColor(String s) {
    switch (s) {
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

  Color _statusBg(String s) {
    switch (s) {
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
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.skyPrimary),
            )
          : _laporan == null
          ? const Center(child: Text('Laporan tidak ditemukan'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 160,
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
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.report_rounded,
                                color: Colors.white,
                                size: 34,
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
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _delete,
                            color: Colors.white70,
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
                        // Status + Jenis
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: _statusBg(_laporan!.status),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _laporan!.statusLabel,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _statusColor(_laporan!.status),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.gray100,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _laporan!.jenisLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Judul
                        Text(
                          _laporan!.judul,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.gray800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppFormatter.formatDateTime(_laporan!.createdAt),
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.gray400,
                          ),
                        ),

                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Info penghuni
                        _InfoRow(
                          Icons.person_outline,
                          'Nama',
                          _laporan!.penghuniNama,
                        ),
                        const SizedBox(height: 8),
                        _InfoRow(
                          Icons.door_back_door_outlined,
                          'Kamar',
                          _laporan!.nomorKamar,
                        ),
                        const SizedBox(height: 16),

                        // Deskripsi
                        const Text(
                          'DESKRIPSI LAPORAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.gray50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.gray200),
                          ),
                          child: Text(
                            _laporan!.deskripsi,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.gray800,
                              height: 1.6,
                            ),
                          ),
                        ),

                        // Catatan Admin
                        if (_laporan!.catatanAdmin != null &&
                            _laporan!.catatanAdmin!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          const Text(
                            'CATATAN ADMIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.skyUltra,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.skyLight),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.admin_panel_settings_outlined,
                                  color: AppColors.skyDark,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _laporan!.catatanAdmin!,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.skyDarker,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Admin actions
                        if (isAdmin &&
                            _laporan!.status != 'selesai' &&
                            _laporan!.status != 'ditolak') ...[
                          const SizedBox(height: 24),
                          const Text(
                            'TINDAKAN ADMIN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.gray400,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          if (_laporan!.status == 'menunggu')
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _updateStatus('diproses'),
                                icon: const Icon(Icons.engineering_outlined),
                                label: const Text('Tandai Sedang Diproses'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.skyPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _updateStatus('ditolak'),
                                  icon: const Icon(
                                    Icons.close_rounded,
                                    size: 18,
                                  ),
                                  label: const Text('Tolak'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.danger,
                                    side: const BorderSide(
                                      color: AppColors.danger,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateStatus('selesai'),
                                  icon: const Icon(
                                    Icons.check_circle_outline,
                                    size: 18,
                                  ),
                                  label: const Text('Selesai'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.success,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (!isAdmin &&
                            (_laporan!.status == 'selesai' ||
                                _laporan!.status == 'ditolak')) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: _laporan!.status == 'selesai'
                                  ? AppColors.successLight
                                  : AppColors.dangerLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _laporan!.status == 'selesai'
                                      ? Icons.check_circle_rounded
                                      : Icons.cancel_rounded,
                                  color: _laporan!.status == 'selesai'
                                      ? AppColors.success
                                      : AppColors.danger,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _laporan!.status == 'selesai'
                                      ? 'Laporan Anda telah diselesaikan oleh admin.'
                                      : 'Laporan Anda ditolak oleh admin.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: _laporan!.status == 'selesai'
                                        ? AppColors.success
                                        : AppColors.danger,
                                  ),
                                ),
                              ],
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
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(this.icon, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.skyPrimary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, color: AppColors.gray600),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.gray800,
          ),
        ),
      ],
    );
  }
}
