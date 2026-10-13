class MelamarPekerjaan {
  String namaPerusahaan;
  String posisi;
  String statusLamaran;
  DateTime createdAt;
  int idLamaranpPekerjaan;
  String namaDepanPelamar;
  String namaBelakangPelamar;

  MelamarPekerjaan({
    required this.namaPerusahaan,
    required this.posisi,
    required this.statusLamaran,
    required this.createdAt,
    required this.idLamaranpPekerjaan,
    required this.namaDepanPelamar,
    required this.namaBelakangPelamar,
  });

  factory MelamarPekerjaan.fromJson(
      Map<String, dynamic> json) {
    return MelamarPekerjaan(
      namaPerusahaan:
      json['nama_perusahaan']?.toString() ?? '',

      posisi:
      json['posisi']?.toString() ?? '',

      statusLamaran:
      json['status_lamaran']?.toString() ?? '',

      createdAt: DateTime.tryParse(
          json['createdAt']?.toString() ?? '') ??
          DateTime.now(),

      idLamaranpPekerjaan:
      json['id_lamaran_pekerjaan'] ?? 0,

      namaDepanPelamar:
      json['first_name']?.toString() ?? '',

      namaBelakangPelamar:
      json['last_name']?.toString() ?? '',
    );
  }
}