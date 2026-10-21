import 'package:shared_preferences/shared_preferences.dart';
import 'package:rekanpabrik/dummy/dummy_postingan_pekerjaan.dart';
import 'package:rekanpabrik/dummy/dummy_perusahaan.dart';

class Postingpekerjaanapi {
  final String apiUrl = 'dummy_mode';

  List<Map<String, dynamic>> _formatJobsList() {
    return dummyPostPekerjaan.map((item) {
      final idPost = item['id_post_pekerjaan'] ?? 1;
      final idPerusahaan = item['id_perusahaan'] ?? 1;
      final matchCompany = dummyPerusahaan.firstWhere(
        (c) => c['id'] == idPerusahaan,
        orElse: () => {'nama': 'PT Nusantara Sejahtera', 'namaPerusahaanAsli': 'PT Nusantara Sejahtera'},
      );
      final namaPerusahaan = matchCompany['namaPerusahaanAsli'] ?? matchCompany['nama'] ?? 'PT Nusantara Sejahtera';

      String createdAtStr = '2024-10-01T08:00:00.000';
      if (item['createdAt'] is DateTime) {
        createdAtStr = (item['createdAt'] as DateTime).toIso8601String();
      }

      return {
        'id_post_pekerjaan': idPost,
        'id_perusahaan': idPerusahaan,
        'posisi': item['posisi'] ?? 'Operator Produksi',
        'lokasi': item['lokasi'] ?? 'Cikarang, Jawa Barat',
        'job_details': item['job_details'] ?? 'Menjalankan operasional produksi sesuai SOP.',
        'requirements': item['requirements'] ?? 'Pendidikan minimal SMA/SMK sederajat.',
        'status': item['status'] ?? 'tersedia',
        'createdAt': createdAtStr,
        'nama_perusahaan': namaPerusahaan,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getPostPekerjaan(int idPerusahaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _formatJobsList();
    final filtered = list.where((j) => j['id_perusahaan'] == idPerusahaan).toList();
    if (filtered.isNotEmpty) return filtered;
    return list;
  }

  Future<List<Map<String, dynamic>>> detailsJob(int idPostingan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final list = _formatJobsList();
    final match = list.where((j) => j['id_post_pekerjaan'] == idPostingan).toList();
    if (match.isNotEmpty) return match;
    return list.take(1).toList();
  }

  Future<bool> postingPekerjaann(
    int idPerusahaan,
    String posisi,
    String lokasi,
    String jobDetails,
    String requirements,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    // Menambahkan secara lokal ke list
    dummyPostPekerjaan.insert(0, {
      'id_post_pekerjaan': dummyPostPekerjaan.length + 1,
      'id_perusahaan': idPerusahaan,
      'posisi': posisi,
      'lokasi': lokasi,
      'job_details': jobDetails,
      'requirements': requirements,
      'status': 'tersedia',
      'createdAt': DateTime.now(),
    });
    return true;
  }

  Future<bool> ubahStatusPekerjaann(int idPostPekerjaan, String status) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = dummyPostPekerjaan.indexWhere(
        (element) => element['id_post_pekerjaan'] == idPostPekerjaan);
    if (index != -1) {
      dummyPostPekerjaan[index]['status'] = status;
    }
    return true;
  }

  Future<List<Map<String, dynamic>>> getPelamarByCompanyId(
      int idPerusahaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return [
      {
        'id_lamaran_pekerjaan': 1,
        'id_pelamar': 1,
        'first_name': 'Rafif',
        'last_name': 'Purnomo',
        'email': 'rafif@gmail.com',
        'profile_pict': 'assets/img/defaultPict.png',
        'link_cv': 'assets/docs/cv_rafif.pdf',
        'status_lamaran': 'diproses',
        'posisi_dilamar': 'Software Engineer',
        'posisi': 'Software Engineer',
        'nama_perusahaan': 'PT Nusantara Sejahtera',
        'createdAt': '2024-10-15T08:30:00.000',
      },
      {
        'id_lamaran_pekerjaan': 2,
        'id_pelamar': 2,
        'first_name': 'Budi',
        'last_name': 'Santoso',
        'email': 'budi@gmail.com',
        'profile_pict': 'assets/img/defaultPict.png',
        'link_cv': 'assets/docs/cv_budi.pdf',
        'status_lamaran': 'diterima',
        'posisi_dilamar': 'Marketing Manager',
        'posisi': 'Marketing Manager',
        'nama_perusahaan': 'PT Nusantara Sejahtera',
        'createdAt': '2024-10-16T09:15:00.000',
      },
      {
        'id_lamaran_pekerjaan': 3,
        'id_pelamar': 3,
        'first_name': 'Siti',
        'last_name': 'Aminah',
        'email': 'siti@gmail.com',
        'profile_pict': 'assets/img/defaultPict.png',
        'link_cv': 'assets/docs/cv_siti.pdf',
        'status_lamaran': 'ditolak',
        'posisi_dilamar': 'Data Analyst',
        'posisi': 'Data Analyst',
        'nama_perusahaan': 'PT Nusantara Sejahtera',
        'createdAt': '2024-10-17T11:00:00.000',
      },
    ];
  }

  Future<Map<String, dynamic>> getDetailPelamar(int idLamaranPekerjaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'id_lamaran_pekerjaan': idLamaranPekerjaan,
      'id_pelamar': 1,
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
      'email': 'rafif@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_rafif.pdf',
      'status_lamaran': 'diproses',
      'posisi_dilamar': 'Software Engineer',
      'about_me': 'Lulusan Teknik Mesin dengan sertifikasi K3 dan pengalaman 2 tahun di manufaktur.',
      'nomor_telpon': '081234567890',
      'alamat': 'Jl. Industri No. 10, Cikarang',
      'createdAt': '2024-10-15T08:30:00.000',
    };
  }

  Future<List<Map<String, dynamic>>> getAllPostPekerjaan() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _formatJobsList();
  }
}
