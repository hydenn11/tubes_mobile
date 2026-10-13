class PostingPekerjaan {
  final int idPostPekerjaan;
  final int idPerusahaan;
  final String posisi;
  final String lokasi;
  final String jobDetails;
  final String requirements;
  final String status;
  final DateTime createdAt;
  final String namaPerusahaan;

  PostingPekerjaan(
      {required this.idPostPekerjaan,
      required this.idPerusahaan,
      required this.posisi,
      required this.lokasi,
      required this.jobDetails,
      required this.requirements,
      required this.status,
      required this.createdAt,
      required this.namaPerusahaan});

  factory PostingPekerjaan.fromJson(Map<String, dynamic> json) {
    return PostingPekerjaan(
        idPostPekerjaan: json['id_post_pekerjaan'],
        idPerusahaan: json['id_perusahaan'],
        posisi: json['posisi'],
        lokasi: json['lokasi'],
        jobDetails: json['job_details'],
        requirements: json['requirements'],
        status: json['status'],
        createdAt: DateTime.parse(json['createdAt']),
        namaPerusahaan: json['nama_perusahaan']);
  }
}
