import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/inventaris_model.dart';
import '../../providers/inventaris_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/utils/app_validator.dart';

class TambahInventarisScreen extends StatefulWidget {
  final InventarisModel? existing;
  const TambahInventarisScreen({super.key, this.existing});

  @override
  State<TambahInventarisScreen> createState() => _TambahInventarisScreenState();
}

class _TambahInventarisScreenState extends State<TambahInventarisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _jumlahCtrl = TextEditingController(text: '1');
  final _lokasiCtrl = TextEditingController();
  final _keteranganCtrl = TextEditingController();

  String? _selectedKategori;
  String _selectedSatuan = 'unit';
  String _selectedKondisi = 'baik';

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final e = widget.existing!;
      _namaCtrl.text = e.namaBarang;
      _jumlahCtrl.text = '${e.jumlah}';
      _lokasiCtrl.text = e.lokasi;
      _keteranganCtrl.text = e.keterangan ?? '';
      _selectedKategori = e.kategori;
      _selectedSatuan = e.satuan;
      _selectedKondisi = e.kondisi;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _jumlahCtrl.dispose();
    _lokasiCtrl.dispose();
    _keteranganCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<InventarisProvider>();
    bool success;

    if (_isEdit) {
      success = await provider.update(widget.existing!.id, {
        'nama_barang': _namaCtrl.text.trim(),
        'kategori': _selectedKategori,
        'jumlah': int.tryParse(_jumlahCtrl.text) ?? 1,
        'satuan': _selectedSatuan,
        'kondisi': _selectedKondisi,
        'lokasi': _lokasiCtrl.text.trim(),
        'keterangan': _keteranganCtrl.text.trim(),
      });
    } else {
      final item = InventarisModel(
        id: const Uuid().v4(),
        namaBarang: _namaCtrl.text.trim(),
        kategori: _selectedKategori!,
        jumlah: int.tryParse(_jumlahCtrl.text) ?? 1,
        satuan: _selectedSatuan,
        kondisi: _selectedKondisi,
        lokasi: _lokasiCtrl.text.trim(),
        keterangan: _keteranganCtrl.text.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      success = await provider.create(item);
    }

    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isEdit
                ? 'Data berhasil diperbarui'
                : 'Barang berhasil ditambahkan',
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
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
        title: Text(_isEdit ? 'Edit Inventaris' : 'Tambah Inventaris'),
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
              // Nama Barang
              CustomTextField(
                controller: _namaCtrl,
                label: 'Nama Barang',
                hint: 'Contoh: Beras, Sapu, TV',
                prefixIcon: Icons.inventory_2_outlined,
                validator: (v) => AppValidator.combine([
                  AppValidator.requiredText,
                  AppValidator.noEmoji,
                ], v),
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
                    Icons.category_outlined,
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
                items: InventarisModel.kategoriList
                    .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedKategori = v),
                validator: (v) => v == null ? 'Kategori wajib dipilih' : null,
              ),
              const SizedBox(height: 16),

              // Jumlah + Satuan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: CustomTextField(
                      controller: _jumlahCtrl,
                      label: 'Jumlah',
                      hint: '1',
                      prefixIcon: Icons.numbers,
                      keyboardType: TextInputType.number,
                      validator: AppValidator.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SATUAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.gray600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: _selectedSatuan,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.straighten,
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
                          items: InventarisModel.satuanList
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedSatuan = v!),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lokasiCtrl,
                label: 'Lokasi',
                hint: 'Contoh: Dapur, Kamar, Gudang',
                prefixIcon: Icons.location_on_outlined,
                validator: (v) => AppValidator.combine([
                  AppValidator.requiredText,
                  AppValidator.noEmoji,
                ], v),
              ),
              const SizedBox(height: 16),
              const Text(
                'KONDISI',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.gray600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: InventarisModel.kondisiList.map((k) {
                  final isSelected = _selectedKondisi == k;
                  final label = {
                    'baik': 'Baik',
                    'perlu_cek': 'Perlu Cek',
                    'rusak': 'Rusak',
                  }[k]!;
                  final bg = {
                    'baik': AppColors.successLight,
                    'perlu_cek': AppColors.warningLight,
                    'rusak': AppColors.dangerLight,
                  }[k]!;
                  final color = {
                    'baik': AppColors.success,
                    'perlu_cek': AppColors.warning,
                    'rusak': AppColors.danger,
                  }[k]!;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedKondisi = k),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? bg : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? color : AppColors.gray200,
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? color : AppColors.gray400,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Keterangan
              CustomTextField(
                controller: _keteranganCtrl,
                label: 'Keterangan (Opsional)',
                hint: 'Tambahkan catatan...',
                prefixIcon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 28),

              Consumer<InventarisProvider>(
                builder: (context, prov, _) => CustomButton(
                  label: _isEdit ? 'Simpan Perubahan' : 'Tambahkan Barang',
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
