class Perusahaan {
  int idPerusahaan;
  String namaPerusahaan;
  String email;
  String? aboutMe;
  String? profilePict;
  String? alamat;
  int jumlahPostingan;

  Perusahaan({
    required this.idPerusahaan,
    required this.namaPerusahaan,
    required this.email,
    this.aboutMe,
    this.profilePict,
    this.alamat,
    required this.jumlahPostingan,
  });

  factory Perusahaan.fromJson(Map<String, dynamic> json) {
    return Perusahaan(
        idPerusahaan: json['id_perusahaan'],
        namaPerusahaan: json['nama_perusahaan'] ?? '',
        email: json['email'],
        aboutMe: json['about_me'],
        profilePict: json['profile_pict'],
        alamat: json['alamat'] ?? '',
        jumlahPostingan: json['jumlah_posting'] ?? 0);
  }
}
