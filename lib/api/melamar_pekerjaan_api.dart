import 'package:shared_preferences/shared_preferences.dart';

class MelamarPekerjaanapi {
  final String apiUrl = 'dummy_mode';

  static final List<Map<String, dynamic>> _dummyHistory = [
    {
      'id_lamaran_pekerjaan': 1,
      'nama_perusahaan': 'PT Astra Otoparts Tbk',
      'posisi': 'Operator Produksi (Assembly)',
      'status_lamaran': 'diterima',
      'createdAt': '2024-10-15T08:30:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 2,
      'nama_perusahaan': 'PT Mayora Indah Tbk',
      'posisi': 'Quality Control (QC) Inspector',
      'status_lamaran': 'diproses',
      'createdAt': '2024-10-12T10:00:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 3,
      'nama_perusahaan': 'PT Toyota Motor Manufacturing',
      'posisi': 'Teknisi Maintenance Mesin CNC',
      'status_lamaran': 'ditolak',
      'createdAt': '2024-10-08T14:20:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 4,
      'nama_perusahaan': 'PT Unilever Indonesia Tbk',
      'posisi': 'Operator Line Packaging',
      'status_lamaran': 'diproses',
      'createdAt': '2024-10-05T09:15:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 5,
      'nama_perusahaan': 'PT Kalbe Farma Tbk',
      'posisi': 'Operator Produksi Farmasi',
      'status_lamaran': 'diterima',
      'createdAt': '2024-10-02T11:00:00.000',
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
    },
    {
      'id_lamaran_pekerjaan': 6,
      'nama_perusahaan': 'PT Denso Indonesia',
      'posisi': 'Teknisi Stamping & Tooling',
      'status_lamaran': 'ditolak',
      'createdAt': '2024-09-28T16:30:00.000',
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

    final history = _dummyHistory.firstWhere(
      (element) => element['id_lamaran_pekerjaan'] == idPostingan,
      orElse: () => _dummyHistory.isNotEmpty
          ? _dummyHistory.first
          : {
              'id_lamaran_pekerjaan': idPostingan,
              'nama_perusahaan': 'PT Astra Otoparts Tbk',
              'posisi': 'Operator Produksi (Assembly)',
              'status_lamaran': 'diproses',
              'status': 'diproses',
              'createdAt': DateTime.now().toIso8601String(),
              'first_name': 'Rafif',
              'last_name': 'Purnomo',
            },
    );

    return {
      'id_lamaran_pekerjaan': history['id_lamaran_pekerjaan'] ?? idPostingan,
      'nama_perusahaan': history['nama_perusahaan'] ?? 'PT Rekan Pabrik',
      'posisi': history['posisi'] ?? 'Operator Produksi',
      'status': history['status_lamaran'] ?? history['status'] ?? 'diproses',
      'status_lamaran': history['status_lamaran'] ?? history['status'] ?? 'diproses',
      'createdAt': history['createdAt'] ?? DateTime.now().toIso8601String(),
      'first_name': history['first_name'] ?? 'Rafif',
      'last_name': history['last_name'] ?? 'Purnomo',
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