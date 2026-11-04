import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/dummy/dummy_postingan_pekerjaan.dart';

class SavedJobsApi {
  final String apiUrl = 'dummy_mode';

  static final List<Map<String, dynamic>> _dummySaved = [
    {
      'id_saved_jobs': 1,
      'id_pelamar': 1,
      'id_post_pekerjaan': 1,
      'posisi': 'Operator Produksi (Assembly)',
      'lokasi': 'Kawasan GIIC Cikarang',
      'job_details':
          'Melakukan perakitan komponen suku cadang otomotif di lini perakitan conveyor sesuai instruksi kerja (SOP), menjaga target ritme produksi harian, dan menerapkan prinsip 5S di area workshop.',
      'requirements':
          'Lulusan SMK/SMA sederajat (Teknik Otomotif/Mesin diutamakan). Usia 18-24 tahun, teliti, tidak buta warna, dan siap bekerja sistem 3 shift.',
      'status': 'tersedia',
      'createdAt': '2024-10-01T08:00:00.000',
    },
    {
      'id_saved_jobs': 2,
      'id_pelamar': 1,
      'id_post_pekerjaan': 2,
      'posisi': 'Teknisi Maintenance Mesin CNC',
      'lokasi': 'Kawasan KIIC Karawang',
      'job_details':
          'Melakukan perawatan preventif dan perbaikan mesin bubut/milling CNC, trouble-shooting sistem pneumatik & hidrolik, serta meminimalkan downtime mesin di lini produksi otomotif.',
      'requirements':
          'Pendidikan D3/SMK Teknik Mesin / Mekatronika. Pengalaman minimal 1 tahun merawat mesin industri, mampu membaca wiring diagram & PLC dasar.',
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
      final matched = dummyPostPekerjaan.firstWhere(
        (j) => j['id_post_pekerjaan'] == idPostPekerjaan,
        orElse: () => <String, dynamic>{},
      );

      _dummySaved.add({
        'id_saved_jobs': _dummySaved.length + 1,
        'id_pelamar': idPelamar,
        'id_post_pekerjaan': idPostPekerjaan,
        'posisi': matched['posisi'] ?? 'Lowongan Pekerjaan Industri',
        'lokasi': matched['lokasi'] ?? 'Kawasan Industri',
        'job_details': matched['job_details'] ?? 'Deskripsi lowongan industri manufaktur.',
        'requirements': matched['requirements'] ?? 'Pengalaman relevan.',
        'status': matched['status'] ?? 'tersedia',
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
      final matched = dummyPostPekerjaan.firstWhere(
        (j) => j['id_post_pekerjaan'] == idPostPekerjaan,
        orElse: () => <String, dynamic>{},
      );

      _dummySaved.add({
        'id_saved_jobs': _dummySaved.length + 1,
        'id_pelamar': idPelamar,
        'id_post_pekerjaan': idPostPekerjaan,
        'posisi': matched['posisi'] ?? 'Lowongan Pekerjaan Industri',
        'lokasi': matched['lokasi'] ?? 'Kawasan Industri',
        'job_details': matched['job_details'] ?? 'Deskripsi lowongan industri manufaktur.',
        'requirements': matched['requirements'] ?? 'Pengalaman relevan.',
        'status': matched['status'] ?? 'tersedia',
        'createdAt': DateTime.now().toIso8601String(),
      });
    }
    return true;
  }
}
