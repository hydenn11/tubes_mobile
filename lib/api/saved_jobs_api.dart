import 'package:shared_preferences/shared_preferences.dart';

class SavedJobsApi {
  final String apiUrl = 'dummy_mode';

  static final List<Map<String, dynamic>> _dummySaved = [
    {
      'id_saved_jobs': 1,
      'id_pelamar': 1,
      'id_post_pekerjaan': 1,
      'posisi': 'Software Engineer',
      'lokasi': 'Jakarta',
      'job_details': 'Mengembangkan aplikasi berbasis web dengan framework modern.',
      'requirements': 'Pengalaman minimal 2 tahun dalam pengembangan web.',
      'status': 'tersedia',
      'createdAt': '2024-10-01T08:00:00.000',
    },
    {
      'id_saved_jobs': 2,
      'id_pelamar': 1,
      'id_post_pekerjaan': 2,
      'posisi': 'Marketing Manager',
      'lokasi': 'Bandung',
      'job_details': 'Bertanggung jawab atas strategi pemasaran perusahaan.',
      'requirements': 'Pengalaman minimal 5 tahun dalam bidang pemasaran.',
      'status': 'tersedia',
      'createdAt': '2024-10-02T09:00:00.000',
    },
  ];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? 'dummy_token_12345';
  }

  Future<List<Map<String, dynamic>>> getSavedJobsByIDPelamar(int idPelamar) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummySaved;
  }

  Future<Map<String, dynamic>> savedJobs(
    int idPostPekerjaan,
    int idPelamar,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final exists = _dummySaved.any((s) => s['id_post_pekerjaan'] == idPostPekerjaan);
    if (!exists) {
      _dummySaved.add({
        'id_saved_jobs': _dummySaved.length + 1,
        'id_pelamar': idPelamar,
        'id_post_pekerjaan': idPostPekerjaan,
        'posisi': 'Lowongan Pekerjaan Industri',
        'lokasi': 'Cikarang',
        'job_details': 'Deskripsi lowongan industri manufaktur.',
        'requirements': 'Pengalaman relevan.',
        'status': 'tersedia',
        'createdAt': DateTime.now().toIso8601String(),
      });
      return {
        "success": true,
        "saved": true,
        "message": "Pekerjaan disimpan",
      };
    } else {
      _dummySaved.removeWhere((s) => s['id_post_pekerjaan'] == idPostPekerjaan);
      return {
        "success": true,
        "saved": false,
        "message": "Pekerjaan dihapus dari simpanan",
      };
    }
  }

  Future<bool> toggleSavedJobs(
    int idPelamar,
    int idPostPekerjaan,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final exists = _dummySaved.any((s) => s['id_post_pekerjaan'] == idPostPekerjaan);
    if (exists) {
      _dummySaved.removeWhere((s) => s['id_post_pekerjaan'] == idPostPekerjaan);
    } else {
      _dummySaved.add({
        'id_saved_jobs': _dummySaved.length + 1,
        'id_pelamar': idPelamar,
        'id_post_pekerjaan': idPostPekerjaan,
        'posisi': 'Lowongan Pekerjaan Industri',
        'lokasi': 'Cikarang',
        'job_details': 'Deskripsi lowongan industri manufaktur.',
        'requirements': 'Pengalaman relevan.',
        'status': 'tersedia',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    return true;
  }
}
