import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/iuran_model.dart';
import '../../providers/iuran_provider.dart';
import '../../providers/penghuni_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/app_validator.dart';

class BuatTagihanScreen extends StatefulWidget {
  const BuatTagihanScreen({super.key});

  @override
  State<BuatTagihanScreen> createState() => _BuatTagihanScreenState();
}

class _BuatTagihanScreenState extends State<BuatTagihanScreen> {
  final _jumlahCtrl = TextEditingController(text: '150000');
  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;
  final Set<String> _selectedIds = {};
  bool _selectAll = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PenghuniProvider>().loadAll();
      context.read<IuranProvider>().loadAll();
    });
  }

  @override
  void dispose() {
    _jumlahCtrl.dispose();
    super.dispose();
  }

  void _toggleSelectAll(List penghuni) {
    final iuranProvider = context.read<IuranProvider>();

    setState(() {
      if (_selectAll) {
        _selectedIds.clear();
        _selectAll = false;
      } else {
        _selectedIds.addAll(
          penghuni
              .where(
                (p) => !iuranProvider.isPenghuniDisabled(p.id),
              ) // 🔥 FILTER
              .map((p) => p.id as String),
        );
        _selectAll = true;
      }
    });
  }

  Future<void> _submit() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal satu penghuni'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    final jumlah = int.tryParse(_jumlahCtrl.text.replaceAll('.', ''));
    if (jumlah == null || jumlah <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Masukkan jumlah yang valid'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final penghuni = context.read<PenghuniProvider>().penghuni;
    final selected = penghuni
        .where((p) => _selectedIds.contains(p.id))
        .toList();
    final penghuniList = selected
        .map((p) => {'id': p.id, 'nama': p.namaLengkap, 'kamar': p.nomorKamar})
        .toList();

    final ok = await context.read<IuranProvider>().buatTagihan(
      bulan: _bulan,
      tahun: _tahun,
      jumlah: jumlah,
      penghuniList: penghuniList,
    );

    if (!mounted) return;
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tagihan berhasil dibuat untuk ${selected.length} penghuni',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final penghuni = context.watch<PenghuniProvider>().penghuni;
    final iuranProvider = context.watch<IuranProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Tagihan Iuran'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: AppColors.navyGradient),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
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
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Tagihan akan dibuat untuk penghuni yang dipilih. Jika sudah ada tagihan di bulan yang sama, akan diperbarui.',
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
              'PERIODE',
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
                  child: DropdownButtonFormField<int>(
                    value: _bulan,
                    decoration: InputDecoration(
                      labelText: 'Bulan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(IuranModel.namaBulan[i + 1]),
                      ),
                    ),
                    onChanged: (v) => setState(() => _bulan = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: _tahun,
                    decoration: InputDecoration(
                      labelText: 'Tahun',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                    ),
                    items: [2024, 2025, 2026]
                        .map(
                          (y) => DropdownMenuItem(value: y, child: Text('$y')),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _tahun = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _jumlahCtrl,
              label: 'Jumlah Iuran (Rp)',
              hint: '150000',
              prefixIcon: Icons.attach_money_rounded,
              keyboardType: TextInputType.number,
              validator: AppValidator.number,
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PILIH PENGHUNI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gray600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Centang penghuni yang akan ditagih',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.gray400,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _toggleSelectAll(penghuni),
                  icon: Icon(
                    _selectAll ? Icons.deselect : Icons.select_all,
                    size: 16,
                  ),
                  label: Text(_selectAll ? 'Batal Semua' : 'Pilih Semua'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.skyDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (penghuni.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    'Belum ada penghuni terdaftar',
                    style: TextStyle(color: AppColors.gray400),
                  ),
                ),
              )
            else
              ...penghuni.map((p) {
                final isSelected = _selectedIds.contains(p.id);
                final isDisabled = iuranProvider.isPenghuniDisabled(p.id);
                return GestureDetector(
                  onTap: isDisabled
                      ? null
                      : () => setState(() {
                          if (isSelected)
                            _selectedIds.remove(p.id);
                          else
                            _selectedIds.add(p.id);
                          _selectAll = _selectedIds.length == penghuni.length;
                        }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.skyUltra : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.skyPrimary
                            : AppColors.gray200,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected
                                ? AppColors.skyPrimary
                                : Colors.transparent,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.skyPrimary
                                  : AppColors.gray300,
                            ),
                          ),
                          child: isSelected
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                )
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.namaLengkap,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.gray800,
                                ),
                              ),
                              Text(
                                'NIM: ${p.nim} · ${p.nomorKamar}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

            const SizedBox(height: 20),
            if (_selectedIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.summarize_outlined,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_selectedIds.length} penghuni dipilih',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.success,
                            ),
                          ),
                          Text(
                            'Total: ${AppFormatter.formatCurrency((int.tryParse(_jumlahCtrl.text.replaceAll('.', '').replaceAll(',', '')) ?? 0) * _selectedIds.length)}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            Consumer<IuranProvider>(
              builder: (context, prov, _) => CustomButton(
                label: 'Buat Tagihan',
                isLoading: prov.isLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
