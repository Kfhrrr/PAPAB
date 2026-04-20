class AppValidator {
  /// 🔹 Required + trim
  static String? requiredText(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Wajib diisi';
    }
    return null;
  }

  /// 🔹 Hanya huruf & spasi (untuk nama)
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';

    final regex = RegExp(r'^[a-zA-Z\s]+$');
    if (!regex.hasMatch(v.trim())) {
      return 'Hanya boleh huruf';
    }

    return null;
  }

  /// 🔹 Email
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';

    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v.trim())) {
      return 'Format email tidak valid';
    }

    return null;
  }

  /// 🔹 Password
  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Wajib diisi';
    if (v.length < 6) return 'Minimal 6 karakter';
    return null;
  }

  /// 🔹 Angka (support 1.000)
  static String? number(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';

    final clean = v.replaceAll(RegExp(r'[^0-9]'), '');

    if (clean.isEmpty) return 'Harus berupa angka';

    return null;
  }

  /// 🔹 NIK (16 digit)
  static String? nik(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';

    if (!RegExp(r'^\d{16}$').hasMatch(v)) {
      return 'NIK harus 16 digit';
    }

    return null;
  }

  /// 🔹 Nomor HP
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Wajib diisi';

    if (!v.startsWith('08')) return 'Harus diawali 08';
    if (v.length < 10) return 'Nomor terlalu pendek';

    return null;
  }

  /// 🔥 BLOCK EMOJI & KARAKTER ANEH
  static String? noEmoji(String? v) {
    if (v == null || v.isEmpty) return null;

    final emojiRegex = RegExp(
      r'[\u{1F600}-\u{1F64F}]|'
      r'[\u{1F300}-\u{1F5FF}]|'
      r'[\u{1F680}-\u{1F6FF}]|'
      r'[\u{2600}-\u{26FF}]',
      unicode: true,
    );

    if (emojiRegex.hasMatch(v)) {
      return 'Tidak boleh mengandung emoji';
    }

    return null;
  }

  /// 🔥 COMBINE VALIDATOR
  static String? combine(
    List<String? Function(String?)> validators,
    String? v,
  ) {
    for (final validator in validators) {
      final result = validator(v);
      if (result != null) return result;
    }
    return null;
  }
}
