class KeuanganModel {
  final String id;
  final String jenis; // 'pemasukan' atau 'pengeluaran'
  final String kategori; // 'iuran', 'pengeluaran_umum', dll
  final String keterangan;
  final int jumlah;
  final String? penghuniId;
  final String? penghuniNama;
  final DateTime tanggal;
  final String createdBy;
  final DateTime createdAt;

  KeuanganModel({
    required this.id,
    required this.jenis,
    required this.kategori,
    required this.keterangan,
    required this.jumlah,
    this.penghuniId,
    this.penghuniNama,
    required this.tanggal,
    required this.createdBy,
    required this.createdAt,
  });

  factory KeuanganModel.fromJson(Map<String, dynamic> json) {
    return KeuanganModel(
      id: json['id'] ?? '',
      jenis: json['jenis'] ?? '',
      kategori: json['kategori'] ?? '',
      keterangan: json['keterangan'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      penghuniId: json['penghuni_id'],
      penghuniNama: json['penghuni_nama'],
      tanggal: DateTime.parse(
        json['tanggal'] ?? DateTime.now().toIso8601String(),
      ),
      createdBy: json['created_by'] ?? '',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'jenis': jenis,
      'kategori': kategori,
      'keterangan': keterangan,
      'jumlah': jumlah,
      'penghuni_id': penghuniId,
      'penghuni_nama': penghuniNama,
      'tanggal': tanggal.toIso8601String(),
    };
  }

  bool get isPemasukan => jenis == 'pemasukan';

  static List<String> get kategoriPemasukan => ['Kas', 'Denda', 'Lainnya'];

  static List<String> get kategoriPengeluaran => [
    'Listrik',
    'Air',
    'Kebersihan',
    'Perbaikan',
    'Pembelian Barang',
    'Lainnya',
  ];
}
