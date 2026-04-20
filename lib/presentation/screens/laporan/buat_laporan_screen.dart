import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/laporan_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/laporan_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/app_validator.dart';

class BuatLaporanScreen extends StatefulWidget {
  const BuatLaporanScreen({super.key});

  @override
  State<BuatLaporanScreen> createState() => _BuatLaporanScreenState();
}

class _BuatLaporanScreenState extends State<BuatLaporanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _deskripsiCtrl = TextEditingController();
  String _jenis = 'kerusakan';

  final _jenisOptions = {
    'kerusakan': {
      'label': 'Kerusakan',
      'icon': Icons.build_outlined,
      'color': AppColors.warning,
    },
    'kebersihan': {
      'label': 'Kebersihan',
      'icon': Icons.cleaning_services_outlined,
      'color': AppColors.skyDark,
    },
    'keamanan': {
      'label': 'Keamanan',
      'icon': Icons.security_outlined,
      'color': AppColors.danger,
    },
    'lainnya': {
      'label': 'Lainnya',
      'icon': Icons.notes_outlined,
      'color': AppColors.gray600,
    },
  };

  @override
  void dispose() {
    _judulCtrl.dispose();
    _deskripsiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    final laporan = LaporanModel(
      id: const Uuid().v4(),
      penghuniId: user.id,
      penghuniNama: user.namaLengkap,
      nomorKamar: user.nomorKamar,
      jenis: _jenis,
      judul: _judulCtrl.text.trim(),
      deskripsi: _deskripsiCtrl.text.trim(),
      status: 'menunggu',
      createdAt: DateTime.now(),
    );

    final ok = await context.read<LaporanProvider>().create(laporan);
    if (!mounted) return;
    if (ok) {
      // Reload laporan user
      context.read<LaporanProvider>().loadMyLaporan(user.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Laporan berhasil dikirim! Admin akan segera menindaklanjuti.',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim laporan, coba lagi'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kirim Laporan'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.skyUltra,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.skyLight),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.skyDark,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Laporan Anda akan diterima oleh admin/bendahara dan ditindaklanjuti secepatnya.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.skyDarker,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                'JENIS LAPORAN',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 3,
                children: _jenisOptions.entries.map((entry) {
                  final isSelected = _jenis == entry.key;
                  final color = entry.value['color'] as Color;
                  final icon = entry.value['icon'] as IconData;
                  final label = entry.value['label'] as String;
                  return GestureDetector(
                    onTap: () => setState(() => _jenis = entry.key),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? color.withOpacity(0.1)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? color : AppColors.gray200,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            icon,
                            color: isSelected ? color : AppColors.gray400,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? color : AppColors.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _judulCtrl,
                label: 'Judul Laporan',
                hint: 'Ringkasan singkat masalah',
                prefixIcon: Icons.title,
                validator: (v) => AppValidator.combine([
                  AppValidator.requiredText,
                  AppValidator.noEmoji,
                ], v),
              ),
              const SizedBox(height: 16),

              const Text(
                'DESKRIPSI LENGKAP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _deskripsiCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan masalah secara detail: lokasi kejadian, kondisi, kapan terjadi, dll.',
                  hintStyle: const TextStyle(
                    fontSize: 13,
                    color: AppColors.gray400,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                ),
                validator: (v) => AppValidator.combine([
                  AppValidator.requiredText,
                  AppValidator.noEmoji,
                  (v) => v!.trim().length < 20
                      ? 'Deskripsi minimal 20 karakter'
                      : null,
                ], v),
              ),
              const SizedBox(height: 28),
              Consumer<LaporanProvider>(
                builder: (context, prov, _) => CustomButton(
                  label: 'Kirim Laporan',
                  isLoading: prov.isLoading,
                  onPressed: _submit,
                  icon: Icons.send_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
