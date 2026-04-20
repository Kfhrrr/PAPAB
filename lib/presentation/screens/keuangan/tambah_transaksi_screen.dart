import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/keuangan_model.dart';
import '../../providers/keuangan_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/app_validator.dart';

class TambahTransaksiScreen extends StatefulWidget {
  const TambahTransaksiScreen({super.key});

  @override
  State<TambahTransaksiScreen> createState() => _TambahTransaksiScreenState();
}

class _TambahTransaksiScreenState extends State<TambahTransaksiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _keteranganCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController();
  final _sumberCtrl = TextEditingController(); // Ganti dari dropdown penghuni

  String _jenis = 'pemasukan';
  String? _selectedKategori;
  DateTime _tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _keteranganCtrl.dispose();
    _jumlahCtrl.dispose();
    _sumberCtrl.dispose();
    super.dispose();
  }

  List<String> get _kategoriList => _jenis == 'pemasukan'
      ? KeuanganModel.kategoriPemasukan
      : KeuanganModel.kategoriPengeluaran;

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.skyPrimary),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggal = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final sumber = _sumberCtrl.text.trim();
    final transaksi = KeuanganModel(
      id: const Uuid().v4(),
      jenis: _jenis,
      kategori: _selectedKategori!,
      keterangan: _keteranganCtrl.text.trim(),
      jumlah: int.tryParse(_jumlahCtrl.text.replaceAll('.', '')) ?? 0,
      penghuniId: null,
      penghuniNama: sumber.isEmpty ? null : sumber,
      tanggal: _tanggal,
      createdBy: '',
      createdAt: DateTime.now(),
    );

    final success = await context.read<KeuanganProvider>().create(transaksi);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transaksi berhasil disimpan'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) context.pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Transaksi'),
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
              // Jenis toggle
              const Text(
                'JENIS TRANSAKSI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _jenis = 'pemasukan';
                        _selectedKategori = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _jenis == 'pemasukan'
                              ? AppColors.successLight
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _jenis == 'pemasukan'
                                ? AppColors.success
                                : AppColors.gray200,
                            width: _jenis == 'pemasukan' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_downward_rounded,
                              color: _jenis == 'pemasukan'
                                  ? AppColors.success
                                  : AppColors.gray400,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pemasukan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _jenis == 'pemasukan'
                                    ? AppColors.success
                                    : AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() {
                        _jenis = 'pengeluaran';
                        _selectedKategori = null;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: _jenis == 'pengeluaran'
                              ? AppColors.dangerLight
                              : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _jenis == 'pengeluaran'
                                ? AppColors.danger
                                : AppColors.gray200,
                            width: _jenis == 'pengeluaran' ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.arrow_upward_rounded,
                              color: _jenis == 'pengeluaran'
                                  ? AppColors.danger
                                  : AppColors.gray400,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Pengeluaran',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _jenis == 'pengeluaran'
                                    ? AppColors.danger
                                    : AppColors.gray400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kategori
              const Text(
                'KATEGORI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                value: _selectedKategori,
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.label_outline,
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
                hint: const Text('Pilih kategori'),
                items: _kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKategori = v),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _keteranganCtrl,
                label: 'Keterangan',
                hint: 'Contoh: Iuran Bulanan April - Aulia',
                prefixIcon: Icons.notes,
                validator: (v) => AppValidator.combine([
                  AppValidator.requiredText,
                  AppValidator.noEmoji,
                ], v),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _jumlahCtrl,
                label: 'Jumlah (Rp)',
                hint: '150000',
                prefixIcon: Icons.attach_money_rounded,
                keyboardType: TextInputType.number,
                validator: AppValidator.number,
              ),
              const SizedBox(height: 16),
              const Text(
                'TANGGAL',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gray200),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: AppColors.gray400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_tanggal.day}/${_tanggal.month}/${_tanggal.year}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gray800,
                        ),
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.gray400),
                    ],
                  ),
                ),
              ),
              if (_jenis == 'pemasukan') ...[
                const SizedBox(height: 16),
                const Text(
                  'SUMBER / DARI (OPSIONAL)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gray600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contoh: nama penghuni, donatur, instansi, dll.',
                  style: TextStyle(fontSize: 11, color: AppColors.gray400),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _sumberCtrl,
                  decoration: InputDecoration(
                    hintText: 'Kosongkan jika tidak ada sumber spesifik',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.gray400,
                    ),
                    prefixIcon: const Icon(
                      Icons.person_outline,
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
                ),
              ],

              const SizedBox(height: 28),
              Consumer<KeuanganProvider>(
                builder: (context, prov, _) => CustomButton(
                  label: 'Simpan Transaksi',
                  isLoading: prov.isLoading,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
