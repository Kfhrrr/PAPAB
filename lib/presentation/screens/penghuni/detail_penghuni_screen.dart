import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/user_model.dart';
import '../../../data/services/penghuni_service.dart';
import '../../providers/penghuni_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class DetailPenghuniScreen extends StatefulWidget {
  final String id;
  const DetailPenghuniScreen({super.key, required this.id});

  @override
  State<DetailPenghuniScreen> createState() => _DetailPenghuniScreenState();
}

class _DetailPenghuniScreenState extends State<DetailPenghuniScreen> {
  final _service = PenghuniService();
  UserModel? _penghuni;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      _penghuni = await _service.getById(widget.id);
    } catch (_) {}
    setState(() => _loading = false);
  }

  Future<void> _showEditDialog() async {
    final namaCtrl = TextEditingController(text: _penghuni?.namaLengkap);
    final nimCtrl = TextEditingController(text: _penghuni?.nim);
    final hpCtrl = TextEditingController(text: _penghuni?.nomorHp);

    final List<String> kamarList = [
      'Kamar 1A',
      'Kamar 1B',
      'Kamar 1C',
      'Kamar 2A',
      'Kamar 2B',
      'Kamar 2C',
      'Kamar 3A',
      'Kamar 3B',
      'Kamar 3C',
      'Kamar 4A',
      'Kamar 4B',
      'Kamar 4C',
    ];
    String? selectedKamar = _penghuni?.nomorKamar;
    if (!kamarList.contains(selectedKamar)) selectedKamar = null;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Data Penghuni',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: namaCtrl,
                label: 'Nama Lengkap',
                hint: '',
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: nimCtrl,
                label: 'NIM',
                hint: '',
                prefixIcon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: hpCtrl,
                label: 'Nomor HP',
                hint: '',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              const Text(
                'NOMOR KAMAR',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: selectedKamar,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.door_back_door_outlined,
                    color: AppColors.gray400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                ),
                hint: const Text('Pilih kamar'),
                items: kamarList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setLocal(() => selectedKamar = v),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await context.read<PenghuniProvider>().update(widget.id, {
                      'nama_lengkap': namaCtrl.text.trim(),
                      'nim': nimCtrl.text.trim(),
                      'nomor_hp': hpCtrl.text.trim(),
                      'nomor_kamar':
                          selectedKamar?.replaceAll('Kamar ', '') ?? '',
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Data berhasil diperbarui'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    if (ctx.mounted) Navigator.pop(ctx);
                    await _load();
                  },
                  child: const Text('Simpan Perubahan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _delete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Hapus Penghuni',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Data penghuni dan akun login-nya akan dihapus permanen. Lanjutkan?',
        ),
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
      await context.read<PenghuniProvider>().delete(widget.id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penghuni berhasil dihapus'),
          backgroundColor: Colors.red,
        ),
      );

      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.skyPrimary),
            )
          : _penghuni == null
          ? const Center(child: Text('Data tidak ditemukan'))
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.navyGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.25),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                _penghuni!.initials,
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _penghuni!.namaLengkap,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            _penghuni!.nomorKamar,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.75),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    onPressed: () => context.pop(),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: _showEditDialog,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: _delete,
                      color: Colors.white70,
                      tooltip: 'Hapus',
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DATA DIRI',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray400,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildInfoCard([
                          _InfoRow(
                            icon: Icons.person_outline,
                            label: 'Nama Lengkap',
                            value: _penghuni!.namaLengkap,
                          ),
                          _InfoRow(
                            icon: Icons.badge_outlined,
                            label: 'NIM',
                            value: _penghuni!.nim,
                          ),
                          _InfoRow(
                            icon: Icons.credit_card_outlined,
                            label: 'NIK',
                            value: _penghuni!.nik.isEmpty
                                ? '-'
                                : _penghuni!.nik,
                          ),
                          _InfoRow(
                            icon: Icons.school_outlined,
                            label: 'Universitas',
                            value: _penghuni!.asalUniversitas.isEmpty
                                ? '-'
                                : _penghuni!.asalUniversitas,
                          ),
                          _InfoRow(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: _penghuni!.email,
                          ),
                          _InfoRow(
                            icon: Icons.phone_outlined,
                            label: 'No. HP',
                            value: _penghuni!.nomorHp,
                          ),
                          _InfoRow(
                            icon: Icons.door_back_door_outlined,
                            label: 'Nomor Kamar',
                            value: _penghuni!.nomorKamar,
                          ),
                          _InfoRow(
                            icon: Icons.calendar_today_outlined,
                            label: 'Terdaftar',
                            value: AppFormatter.formatDate(
                              _penghuni!.createdAt,
                            ),
                          ),
                        ]),
                        const SizedBox(height: 20),

                        // Tombol hapus besar
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _delete,
                            icon: const Icon(
                              Icons.person_remove_outlined,
                              color: AppColors.danger,
                            ),
                            label: const Text(
                              'Hapus Penghuni Ini',
                              style: TextStyle(color: AppColors.danger),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
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
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.gray600),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.gray800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
