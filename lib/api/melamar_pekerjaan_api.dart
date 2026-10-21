import 'package:shared_preferences/shared_preferences.dart';

class MelamarPekerjaanapi {
  final String apiUrl = 'dummy_mode';

  static final List<Map<String, dynamic>> _dummyHistory = [
    {
      'id_lamaran_pekerjaan': 1,
      'nama_perusahaan': 'PT Nusantara Sejahtera',
      'posisi': 'Software Engineer',
      'status_lamaran': 'diproses',
      'createdAt': '2024-10-15T08:30:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 2,
      'nama_perusahaan': 'CV Citra Teknologi',
      'posisi': 'Marketing Manager',
      'status_lamaran': 'diterima',
      'createdAt': '2024-10-12T10:00:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 3,
      'nama_perusahaan': 'PT Maju Jaya Abadi',
      'posisi': 'Data Analyst',
      'status_lamaran': 'ditolak',
      'createdAt': '2024-10-08T14:20:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
  ];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') ?? 'dummy_token_12345';
  }

  Future<List<Map<String, dynamic>>> gethistoryLamaran(int idPelamar) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _dummyHistory;
  }

  Future<Map<String, dynamic>> lamarPekerjaan(
      int idPostPekerjaan, int idPelamar) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _dummyHistory.insert(0, {
      'id_lamaran_pekerjaan': _dummyHistory.length + 1,
      'nama_perusahaan': 'PT Nusantara Sejahtera',
      'posisi': 'Lowongan Pekerjaan Industri',
      'status_lamaran': 'diproses',
      'createdAt': DateTime.now().toIso8601String(),
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    });

    return {
      "success": true,
      "message": "Lamaran berhasil dikirim (Mode Frontend)",
    };
  }

  Future<Map<String, dynamic>> getDetailPostinganByIdPostingan(
      int idPostingan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'id_post_pekerjaan': idPostingan,
      'posisi': 'Software Engineer',
      'nama_perusahaan': 'PT Nusantara Sejahtera',
      'status': 'tersedia',
      'lokasi': 'Jakarta',
      'job_details': 'Mengembangkan aplikasi berbasis mobile dan web.',
      'requirements': 'Pengalaman minimal 1 tahun.',
    };
  }

  Future<bool> ubahStatusPelamar(
    String status,
    int idLamaranPekerjaan,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _dummyHistory.indexWhere(
        (element) => element['id_lamaran_pekerjaan'] == idLamaranPekerjaan);
    if (index != -1) {
      _dummyHistory[index]['status_lamaran'] = status;
    }
    return true;
  }
}