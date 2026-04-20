class UserModel {
  final String id;
  final String email;
  final String namaLengkap;
  final String nim;
  final String nik;
  final String asalUniversitas;
  final String nomorKamar;
  final String nomorHp;
  final String role;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    required this.namaLengkap,
    required this.nim,
    required this.nik,
    required this.asalUniversitas,
    required this.nomorKamar,
    required this.nomorHp,
    required this.role,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      namaLengkap: json['nama_lengkap'] ?? '',
      nim: json['nim'] ?? '',
      nik: json['nik'] ?? '',
      asalUniversitas: json['asal_universitas'] ?? '',
      nomorKamar: json['nomor_kamar'] ?? '',
      nomorHp: json['nomor_hp'] ?? '',
      role: json['role'] ?? 'penghuni',
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama_lengkap': namaLengkap,
      'nim': nim,
      'nik': nik,
      'asal_universitas': asalUniversitas,
      'nomor_kamar': nomorKamar,
      'nomor_hp': nomorHp,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isAdmin => role == 'admin';

  String get initials {
    final parts = namaLengkap.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return namaLengkap.isNotEmpty ? namaLengkap[0].toUpperCase() : 'U';
  }
}
