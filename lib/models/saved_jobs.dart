class SavedJobs {
  int idSavedJobs;
  int idPelamar;
  int idPostPekerjaan;
  String posisi;
  String lokasi;
  String jobDetails;
  String requirements;
  String statusPekerjaan;
  DateTime createdAt;

  SavedJobs({
    required this.idSavedJobs,
    required this.idPelamar,
    required this.idPostPekerjaan,
    required this.posisi,
    required this.lokasi,
    required this.jobDetails,
    required this.requirements,
    required this.statusPekerjaan,
    required this.createdAt,
  });

  factory SavedJobs.fromJson(Map<String, dynamic> json) {
    return SavedJobs(
      idSavedJobs: json['id_saved_jobs'],
      idPelamar: json['id_pelamar'],
      idPostPekerjaan: json['id_post_pekerjaan'],
      posisi: json['posisi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      jobDetails: json['job_details'] ?? '',
      requirements: json['requirements'] ?? '',
      statusPekerjaan: json['status'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
