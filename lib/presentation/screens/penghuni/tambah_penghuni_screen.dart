import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/supabase_constants.dart';
import '../../providers/penghuni_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/app_validator.dart';

class TambahPenghuniScreen extends StatefulWidget {
  const TambahPenghuniScreen({super.key});

  @override
  State<TambahPenghuniScreen> createState() => _TambahPenghuniScreenState();
}

class _TambahPenghuniScreenState extends State<TambahPenghuniScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _nikCtrl = TextEditingController();
  final _univCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _hpCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  List<Map<String, dynamic>> _kamarList = [];
  String? _selectedKamar;

  Future<void> _loadKamar() async {
    final supabase = Supabase.instance.client;
    final data = await supabase.from('kamar').select('*, users(count)');
    setState(() {
      _kamarList = List<Map<String, dynamic>>.from(data).map((k) {
        return {...k, 'jumlah_penghuni': k['users']?[0]?['count'] ?? 0};
      }).toList();

      _selectedKamar = null; // 🔥 TAMBAH DI SINI
    });
  }

  // 🔥 TARUH DI SINI PERSIS
  Future<void> _showTambahKamarDialog() async {
    final namaCtrl = TextEditingController();
    final kapasitasCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tambah Kamar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: namaCtrl,
              decoration: const InputDecoration(labelText: 'Nama Kamar'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: kapasitasCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kapasitas'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final nama = namaCtrl.text.trim();
              final kapasitas = int.tryParse(kapasitasCtrl.text);

              if (nama.isEmpty || kapasitas == null) return;

              final supabase = Supabase.instance.client;

              try {
                await supabase.from('kamar').insert({
                  'nomor_kamar': nama,
                  'kapasitas': kapasitas,
                });

                Navigator.pop(context, true); // ✅ cukup satu ini
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${e.toString()}')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );

    if (result == true) {
      _loadKamar();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadKamar();
  }

  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _nikCtrl.dispose();
    _univCtrl.dispose();
    _emailCtrl.dispose();
    _hpCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedKamar == null) {
      _showError('Kamar wajib dipilih');
      return;
    }
    final kamar = _kamarList.firstWhere(
      (k) => k['id'] == _selectedKamar,
      orElse: () => {},
    );
    if (kamar.isEmpty) {
      _showError('Kamar tidak ditemukan');
      return;
    }
    if ((kamar['jumlah_penghuni'] ?? 0) >= (kamar['kapasitas'] ?? 0)) {
      _showError('Kamar sudah penuh');
      return;
    }
    setState(() => _isLoading = true);
    final supabase = Supabase.instance.client;
    final existingNik = await supabase
        .from(SupabaseConstants.tableUsers)
        .select('id')
        .eq('nik', _nikCtrl.text.trim())
        .maybeSingle();

    if (existingNik != null) {
      _showError('NIK sudah digunakan, masukkan NIK lain');
      setState(() => _isLoading = false);
      return;
    }
    final adminSession = supabase.auth.currentSession;
    if (adminSession == null) {
      _showError('Sesi admin tidak ditemukan. Silakan login ulang.');
      setState(() => _isLoading = false);
      return;
    }
    final adminRefreshToken = adminSession.refreshToken;

    try {
      // 1. Sign up new penghuni (auto logs in as new user)
      final res = await supabase.auth.signUp(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      if (res.user == null) throw Exception('Gagal membuat akun');

      // 2. Insert profile row
      final kamar = _kamarList.firstWhere((k) => k['id'] == _selectedKamar);

      await supabase.from(SupabaseConstants.tableUsers).insert({
        'id': res.user!.id,
        'email': _emailCtrl.text.trim(),
        'nama_lengkap': _namaCtrl.text.trim(),
        'nim': _nimCtrl.text.trim(),
        'nik': _nikCtrl.text.trim(),
        'asal_universitas': _univCtrl.text.trim(),

        'kamar_id': _selectedKamar, // tetap
        'nomor_kamar': kamar['nomor_kamar'], // 🔥 TAMBAH INI

        'nomor_hp': _hpCtrl.text.trim(),
        'role': 'penghuni',
      });
      // 3. Sign out new user, restore admin session
      await supabase.auth.signOut();
      await supabase.auth.setSession(adminRefreshToken!);

      if (!mounted) return;
      await context.read<PenghuniProvider>().loadAll();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Penghuni berhasil ditambahkan'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } catch (e) {
      // Restore admin session on error
      try {
        await supabase.auth.setSession(adminRefreshToken!);
      } catch (_) {}
      if (mounted) {
        String msg = e.toString();
        if (msg.contains('already registered') ||
            msg.contains('already exists')) {
          msg = 'Email sudah terdaftar di sistem';
        } else if (msg.contains('network')) {
          msg = 'Tidak ada koneksi internet';
        } else {
          msg = 'Gagal menambah penghuni';
        }
        _showError(msg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Penghuni'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            // ✅ PINDAH KE SINI
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.4),
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: AppColors.warning,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Akun login akan dibuat untuk penghuni ini. Informasikan email dan kata sandi kepada yang bersangkutan.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: _namaCtrl,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama lengkap',
                  prefixIcon: Icons.person_outline,
                  validator: (v) => AppValidator.combine([
                    AppValidator.requiredText,
                    AppValidator.noEmoji,
                  ], v),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _nimCtrl,
                  label: 'NIM',
                  hint: '2021XXXXXXXXXX',
                  prefixIcon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  validator: AppValidator.number,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _nikCtrl,
                  label: 'NIK (KTP)',
                  hint: '16 digit nomor KTP',
                  prefixIcon: Icons.credit_card_outlined,
                  keyboardType: TextInputType.number,
                  validator: AppValidator.nik,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _univCtrl,
                  label: 'Asal Universitas',
                  hint: 'Nama universitas',
                  prefixIcon: Icons.school_outlined,
                  validator: (v) => AppValidator.combine([
                    AppValidator.requiredText,
                    AppValidator.noEmoji,
                  ], v),
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _hpCtrl,
                  label: 'Nomor HP',
                  hint: '08xxxxxxxxxx',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: AppValidator.phone,
                ),
                const SizedBox(height: 14),
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
                  value: _kamarList.any((k) => k['id'] == _selectedKamar)
                      ? _selectedKamar
                      : null,
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
                  hint: const Text('Pilih nomor kamar'),
                  items: _kamarList.map((k) {
                    final isi = k['jumlah_penghuni'] ?? 0;
                    final kapasitas = k['kapasitas'] ?? 0;
                    final penuh = isi >= kapasitas;

                    return DropdownMenuItem<String>(
                      value: k['id'],
                      enabled: !penuh,
                      child: Text(
                        '${k['nomor_kamar']} ($isi/$kapasitas)${penuh ? ' - penuh' : ''}',
                        style: TextStyle(
                          color: penuh ? Colors.grey : Colors.black,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedKamar = v),
                  validator: (v) => v == null ? 'Kamar wajib dipilih' : null,
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showTambahKamarDialog,
                    child: const Text('+ Tambah Kamar'),
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'DATA AKUN LOGIN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'email@mahasiswa.ac.id',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidator.email,
                ),
                const SizedBox(height: 14),
                CustomTextField(
                  controller: _passwordCtrl,
                  label: 'Kata Sandi Awal',
                  hint: 'Minimal 6 karakter',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscure,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.gray400,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: AppValidator.password,
                ),
                const SizedBox(height: 28),
                CustomButton(
                  label: 'Tambah Penghuni',
                  isLoading: _isLoading,
                  onPressed: _submit,
                  icon: Icons.person_add_outlined,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
