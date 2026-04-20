class IuranModel {
  final String id;
  final String penghuniId;
  final String penghuniNama;
  final String nomorKamar;
  final int bulan;
  final int tahun;
  final int jumlah;
  final String status; // 'lunas', 'belum_bayar', 'terlambat'
  final DateTime? tanggalBayar;
  final String? keteranganAdmin;
  final String? keuanganId; // relasi ke tabel keuangan jika lunas
  final DateTime createdAt;

  IuranModel({
    required this.id,
    required this.penghuniId,
    required this.penghuniNama,
    required this.nomorKamar,
    required this.bulan,
    required this.tahun,
    required this.jumlah,
    required this.status,
    this.tanggalBayar,
    this.keteranganAdmin,
    this.keuanganId,
    required this.createdAt,
  });

  factory IuranModel.fromJson(Map<String, dynamic> json) {
    return IuranModel(
      id: json['id'] ?? '',
      penghuniId: json['penghuni_id'] ?? '',
      penghuniNama: json['penghuni_nama'] ?? '',
      nomorKamar: json['nomor_kamar'] ?? '',
      bulan: json['bulan'] ?? 1,
      tahun: json['tahun'] ?? DateTime.now().year,
      jumlah: json['jumlah'] ?? 0,
      status: json['status'] ?? 'belum_bayar',
      tanggalBayar: json['tanggal_bayar'] != null
          ? DateTime.parse(json['tanggal_bayar'])
          : null,
      keteranganAdmin: json['keterangan_admin'],
      keuanganId: json['keuangan_id'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'penghuni_id': penghuniId,
      'penghuni_nama': penghuniNama,
      'nomor_kamar': nomorKamar,
      'bulan': bulan,
      'tahun': tahun,
      'jumlah': jumlah,
      'status': status,
      'tanggal_bayar': tanggalBayar?.toIso8601String(),
      'keterangan_admin': keteranganAdmin,
      'keuangan_id': keuanganId,
    };
  }

  String get statusLabel {
    switch (status) {
      case 'lunas':
        return 'Lunas';
      case 'belum_bayar':
        return 'Belum Bayar';
      case 'terlambat':
        return 'Terlambat';
      default:
        return status;
    }
  }

  static const List<String> namaBulan = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  String get periodLabel => '${namaBulan[bulan]} $tahun';
}
