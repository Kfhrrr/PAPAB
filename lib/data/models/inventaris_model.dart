class InventarisModel {
  final String id;
  final String namaBarang;
  final String kategori;
  final int jumlah;
  final String satuan; // kg, liter, pcs, unit, lusin, pack
  final String kondisi; // 'baik', 'perlu_cek', 'rusak'
  final String lokasi;
  final String? keterangan;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventarisModel({
    required this.id,
    required this.namaBarang,
    required this.kategori,
    required this.jumlah,
    required this.satuan,
    required this.kondisi,
    required this.lokasi,
    this.keterangan,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventarisModel.fromJson(Map<String, dynamic> json) {
    return InventarisModel(
      id: json['id'] ?? '',
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? 'unit',
      kondisi: json['kondisi'] ?? 'baik',
      lokasi: json['lokasi'] ?? '',
      keterangan: json['keterangan'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nama_barang': namaBarang,
      'kategori': kategori,
      'jumlah': jumlah,
      'satuan': satuan,
      'kondisi': kondisi,
      'lokasi': lokasi,
      'keterangan': keterangan,
    };
  }

  String get kondisiLabel {
    switch (kondisi) {
      case 'baik':
        return 'Baik';
      case 'perlu_cek':
        return 'Perlu Cek';
      case 'rusak':
        return 'Rusak';
      default:
        return kondisi;
    }
  }

  String get jumlahDisplay => '$jumlah $satuan';

  static List<String> get kategoriList => [
    'Elektronik',
    'Kebersihan',
    'Dapur',
    'Perabotan', // ganti Furnitur + Perlengkapan Mandi → Perabotan
    'Lainnya',
  ];

  static List<String> get satuanList => [
    'unit',
    'pcs',
    'kg',
    'gram',
    'liter',
    'ml',
    'pack',
    'lusin',
    'set',
    'lembar',
  ];

  static List<String> get kondisiList => ['baik', 'perlu_cek', 'rusak'];
}
