class LaporanModel {
  final String id;
  final String penghuniId;
  final String penghuniNama;
  final String nomorKamar;
  final String jenis; // 'kerusakan', 'kebersihan', 'keamanan', 'lainnya'
  final String judul;
  final String deskripsi;
  final String status; // 'menunggu', 'diproses', 'selesai', 'ditolak'
  final String? catatanAdmin;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LaporanModel({
    required this.id,
    required this.penghuniId,
    required this.penghuniNama,
    required this.nomorKamar,
    required this.jenis,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.catatanAdmin,
    required this.createdAt,
    this.updatedAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'] ?? '',
      penghuniId: json['penghuni_id'] ?? '',
      penghuniNama: json['penghuni_nama'] ?? '',
      nomorKamar: json['nomor_kamar'] ?? '',
      jenis: json['jenis'] ?? 'lainnya',
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      status: json['status'] ?? 'menunggu',
      catatanAdmin: json['catatan_admin'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'penghuni_id': penghuniId,
      'penghuni_nama': penghuniNama,
      'nomor_kamar': nomorKamar,
      'jenis': jenis,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': status,
      'catatan_admin': catatanAdmin,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'menunggu':
        return 'Menunggu';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String get jenisLabel {
    switch (jenis) {
      case 'kerusakan':
        return 'Kerusakan';
      case 'kebersihan':
        return 'Kebersihan';
      case 'keamanan':
        return 'Keamanan';
      case 'lainnya':
        return 'Lainnya';
      default:
        return jenis;
    }
  }

  static List<String> get jenisList => [
    'kerusakan',
    'kebersihan',
    'keamanan',
    'lainnya',
  ];
}
