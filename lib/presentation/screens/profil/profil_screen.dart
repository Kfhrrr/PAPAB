import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';

// FIX: StatefulWidget agar context selalu segar dan tidak stale
class ProfilScreen extends StatefulWidget {
  const ProfilScreen({super.key});

  @override
  State<ProfilScreen> createState() => _ProfilScreenState();
}

class _ProfilScreenState extends State<ProfilScreen> {
  // ── Edit Profil ──────────────────────────────────────────────────────────
  Future<void> _showEditDialog() async {
    // Simpan outer context sebelum masuk ke builder
    final outerContext = context;
    final user = outerContext.read<AuthProvider>().currentUser;

    final namaCtrl = TextEditingController(text: user?.namaLengkap);
    final hpCtrl = TextEditingController(text: user?.nomorHp);
    final nikCtrl = TextEditingController(text: user?.nik);
    final univCtrl = TextEditingController(text: user?.asalUniversitas);

    await showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // FIX: pakai 'ctx' bukan 'context' agar tidak shadow outer context
      builder: (ctx) => Padding(
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
              'Edit Profil',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            _buildField(namaCtrl, 'Nama Lengkap', Icons.person_outline),
            const SizedBox(height: 10),
            _buildField(
              hpCtrl,
              'Nomor HP',
              Icons.phone_outlined,
              type: TextInputType.phone,
            ),
            const SizedBox(height: 10),
            _buildField(
              nikCtrl,
              'NIK (Nomor Induk Kependudukan)',
              Icons.badge_outlined,
              type: TextInputType.number,
            ),
            const SizedBox(height: 10),
            _buildField(univCtrl, 'Asal Universitas', Icons.school_outlined),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // FIX: gunakan outerContext bukan ctx
                  await outerContext.read<AuthProvider>().updateProfile({
                    'nama_lengkap': namaCtrl.text.trim(),
                    'nomor_hp': hpCtrl.text.trim(),
                    'nik': nikCtrl.text.trim(),
                    'asal_universitas': univCtrl.text.trim(),
                  });
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (outerContext.mounted) {
                    ScaffoldMessenger.of(outerContext).showSnackBar(
                      const SnackBar(
                        content: Text('Profil berhasil diperbarui'),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                child: const Text('Simpan Perubahan'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }

  Future<void> _showGantiPasswordDialog() async {
    final outerContext = context;
    final passwordCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    await showModalBottomSheet(
      context: outerContext,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        bool obscure1 = true;
        bool obscure2 = true;
        bool isLoading = false;

        return StatefulBuilder(
          builder: (ctx, setLocal) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ganti Kata Sandi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: passwordCtrl,
                  obscureText: obscure1,
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi Baru',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure1
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setLocal(() => obscure1 = !obscure1),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: confirmCtrl,
                  obscureText: obscure2,
                  decoration: InputDecoration(
                    labelText: 'Konfirmasi Kata Sandi',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure2
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () => setLocal(() => obscure2 = !obscure2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            if (passwordCtrl.text.length < 6) {
                              ScaffoldMessenger.of(outerContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Minimal 6 karakter'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            if (passwordCtrl.text != confirmCtrl.text) {
                              ScaffoldMessenger.of(outerContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Kata sandi tidak cocok'),
                                  backgroundColor: AppColors.danger,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }
                            setLocal(() => isLoading = true);
                            try {
                              await Supabase.instance.client.auth.updateUser(
                                UserAttributes(password: passwordCtrl.text),
                              );
                              if (ctx.mounted) Navigator.pop(ctx);
                              if (outerContext.mounted) {
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Kata sandi berhasil diubah'),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } catch (_) {
                              if (outerContext.mounted) {
                                ScaffoldMessenger.of(outerContext).showSnackBar(
                                  const SnackBar(
                                    content: Text('Gagal mengubah kata sandi'),
                                    backgroundColor: AppColors.danger,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            } finally {
                              setLocal(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Simpan Kata Sandi Baru'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Bantuan ──────────────────────────────────────────────────────────────
  void _showBantuanDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Bantuan',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aplikasi Asrama Putri Tarakan Paguntaka',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              'Versi: 1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.gray600),
            ),
            SizedBox(height: 12),
            Text(
              'Jika mengalami kendala, hubungi admin asrama atau bendahara secara langsung.',
              style: TextStyle(fontSize: 12),
            ),
            SizedBox(height: 8),
            Text(
              'Admin/Bendahara dapat mengelola:\n'
              '• Data inventaris asrama\n'
              '• Keuangan & iuran\n'
              '• Data penghuni\n'
              '• Laporan pengaduan',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar dari Akun',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Yakin ingin keluar dari akun Anda?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      // 🔥 FIX: signOut dulu
      await context.read<AuthProvider>().signOut();

      // 🔥 FIX: pastikan widget masih hidup
      if (!mounted) return;

      // 🔥 FIX: delay tipis pakai microtask (bukan Future.delayed)
      Future.microtask(() {
        if (mounted) context.go('/login');
      });
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: CustomScrollView(
        slivers: [
          // ── Header ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.navyGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 28,
                left: 20,
                right: 20,
              ),
              child: Column(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
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
                        user?.initials ?? 'U',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.namaLengkap ?? '',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.isAdmin == true
                          ? '🔑 Admin / Bendahara'
                          : '🏠 Penghuni',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  if ((user?.nomorKamar ?? '').isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.nomorKamar,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Stat cards
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(label: 'NIM', value: user?.nim ?? '-'),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'No. HP',
                          value: user?.nomorHp ?? '-',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _StatCard(
                          label: 'NIK',
                          value: (user?.nik ?? '').isEmpty ? '-' : user!.nik,
                        ),
                      ),
                    ],
                  ),
                  if ((user?.asalUniversitas ?? '').isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.school_outlined,
                            color: Colors.white.withOpacity(0.8),
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            user!.asalUniversitas,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Menu Items ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'AKUN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuSection(
                    items: [
                      _MenuItem(
                        icon: Icons.person_outline,
                        label: 'Edit Profil',
                        onTap: _showEditDialog,
                      ),
                      _MenuItem(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        trailing: Text(
                          user?.email ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                          ),
                        ),
                        onTap: null,
                      ),
                      _MenuItem(
                        icon: Icons.lock_outline,
                        label: 'Ganti Kata Sandi',
                        onTap: _showGantiPasswordDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'TENTANG APLIKASI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gray400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _MenuSection(
                    items: [
                      _MenuItem(
                        icon: Icons.info_outline,
                        label: 'Versi Aplikasi',
                        trailing: const Text(
                          'v1.0.0',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                          ),
                        ),
                        onTap: null,
                      ),
                      _MenuItem(
                        icon: Icons.help_outline,
                        label: 'Bantuan',
                        onTap: _showBantuanDialog,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _MenuSection(
                    items: [
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Keluar dari Akun',
                        labelColor: AppColors.danger,
                        iconColor: AppColors.danger,
                        onTap: _confirmLogout,
                      ),
                    ],
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
}

// ── Reusable Widgets ─────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value;
  const _StatCard({required this.label, required this.value});

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
          Text(
            label,
            style: TextStyle(fontSize: 9, color: Colors.white.withOpacity(0.7)),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8),
        ],
      ),
      child: Column(
        children: List.generate(
          items.length,
          (i) => Column(
            children: [
              items[i],
              if (i < items.length - 1) const Divider(height: 1, indent: 54),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? labelColor, iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    this.labelColor,
    this.iconColor,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: (iconColor ?? AppColors.skyPrimary).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor ?? AppColors.skyPrimary, size: 20),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: labelColor ?? AppColors.gray800,
        ),
      ),
      trailing:
          trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.gray400)
              : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
