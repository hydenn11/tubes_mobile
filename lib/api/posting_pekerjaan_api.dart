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
        'tipe': item['tipe'] ?? 'Penuh Waktu',
        'gaji': item['gaji'] ?? 'Rp 5.2 - 6.5 Juta',
        'bidang': item['bidang'] ?? 'Manufaktur & Pabrik',
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
    String requirements, {
    String tipe = 'Penuh Waktu',
    String gaji = 'Rp 5.2 - 6.5 Juta',
    String bidang = 'Manufaktur & Pabrik',
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    dummyPostPekerjaan.insert(0, {
      'id_post_pekerjaan': dummyPostPekerjaan.length + 1,
      'id_perusahaan': idPerusahaan,
      'posisi': posisi,
      'lokasi': lokasi,
      'tipe': tipe,
      'gaji': gaji,
      'bidang': bidang,
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

  Future<bool> hapusPekerjaan(int idPostPekerjaan) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = dummyPostPekerjaan.indexWhere(
        (element) => element['id_post_pekerjaan'] == idPostPekerjaan);
    if (index != -1) {
      dummyPostPekerjaan.removeAt(index);
      return true;
    }
    return false;
  }

  static final List<Map<String, dynamic>> dummyPelamar = [
    {
      'id_lamaran_pekerjaan': 1,
      'id_pelamar': 1,
      'id_post_pekerjaan': 1,
      'first_name': 'Rafif',
      'last_name': 'Purnomo',
      'email': 'rafif@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_rafif.pdf',
      'status_lamaran': 'diproses',
      'posisi_dilamar': 'Operator Produksi (Assembly)',
      'posisi': 'Operator Produksi (Assembly)',
      'nama_perusahaan': 'PT Astra Otoparts Tbk',
      'createdAt': '2024-10-15T08:30:00.000',
    },
    {
      'id_lamaran_pekerjaan': 2,
      'id_pelamar': 2,
      'id_post_pekerjaan': 1,
      'first_name': 'Budi',
      'last_name': 'Santoso',
      'email': 'budi@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_budi.pdf',
      'status_lamaran': 'diterima',
      'posisi_dilamar': 'Operator Produksi (Assembly)',
      'posisi': 'Operator Produksi (Assembly)',
      'nama_perusahaan': 'PT Astra Otoparts Tbk',
      'createdAt': '2024-10-16T09:15:00.000',
    },
    {
      'id_lamaran_pekerjaan': 3,
      'id_pelamar': 3,
      'id_post_pekerjaan': 2,
      'first_name': 'Siti',
      'last_name': 'Aminah',
      'email': 'siti@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_siti.pdf',
      'status_lamaran': 'ditolak',
      'posisi_dilamar': 'Teknisi Maintenance Mesin CNC',
      'posisi': 'Teknisi Maintenance Mesin CNC',
      'nama_perusahaan': 'PT Toyota Motor Manufacturing',
      'createdAt': '2024-10-17T11:00:00.000',
    },
    {
      'id_lamaran_pekerjaan': 4,
      'id_pelamar': 4,
      'id_post_pekerjaan': 1,
      'first_name': 'Agus',
      'last_name': 'Pratama',
      'email': 'agus.pratama@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_agus.pdf',
      'status_lamaran': 'diproses',
      'posisi_dilamar': 'Operator Produksi (Assembly)',
      'posisi': 'Operator Produksi (Assembly)',
      'nama_perusahaan': 'PT Astra Otoparts Tbk',
      'createdAt': '2024-10-18T14:20:00.000',
    },
    {
      'id_lamaran_pekerjaan': 5,
      'id_pelamar': 5,
      'id_post_pekerjaan': 3,
      'first_name': 'Dewi',
      'last_name': 'Lestari',
      'email': 'dewi.lestari@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_dewi.pdf',
      'status_lamaran': 'diproses',
      'posisi_dilamar': 'Quality Control (QC) Inspector',
      'posisi': 'Quality Control (QC) Inspector',
      'nama_perusahaan': 'PT Mayora Indah Tbk',
      'createdAt': '2024-10-19T10:00:00.000',
    },
    {
      'id_lamaran_pekerjaan': 6,
      'id_pelamar': 6,
      'id_post_pekerjaan': 2,
      'first_name': 'Hendra',
      'last_name': 'Kusuma',
      'email': 'hendra.kusuma@gmail.com',
      'profile_pict': 'assets/img/defaultPict.png',
      'link_cv': 'assets/docs/cv_hendra.pdf',
      'status_lamaran': 'diproses',
      'posisi_dilamar': 'Teknisi Maintenance Mesin CNC',
      'posisi': 'Teknisi Maintenance Mesin CNC',
      'nama_perusahaan': 'PT Toyota Motor Manufacturing',
      'createdAt': '2024-10-20T13:45:00.000',
    },
  ];

  Future<List<Map<String, dynamic>>> getPelamarByCompanyId(
      int idPerusahaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final companyJobIds = dummyPostPekerjaan
        .where((j) => (j['id_perusahaan'] ?? 1) == idPerusahaan)
        .map((j) => j['id_post_pekerjaan'])
        .toSet();

    final filtered = dummyPelamar
        .where((p) => companyJobIds.contains(p['id_post_pekerjaan']))
        .toList();

    return filtered;
  }

  Future<List<Map<String, dynamic>>> getPelamarByJob(
      int idPostPekerjaan, String jobTitle) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final matchById = dummyPelamar
        .where((p) => p['id_post_pekerjaan'] == idPostPekerjaan)
        .toList();
    if (matchById.isNotEmpty) return matchById;

    final jobTitleClean = jobTitle.trim().toLowerCase();
    final matchByTitle = dummyPelamar.where((p) {
      final pos = (p['posisi_dilamar'] ?? p['posisi'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      return pos == jobTitleClean || pos.contains(jobTitleClean) || jobTitleClean.contains(pos);
    }).toList();
    if (matchByTitle.isNotEmpty) return matchByTitle;

    return [];
  }

  Future<Map<String, dynamic>> getDetailPelamar(int idLamaranPekerjaan) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final match = dummyPelamar.firstWhere(
      (p) => p['id_lamaran_pekerjaan'] == idLamaranPekerjaan,
      orElse: () => dummyPelamar.first,
    );
    return {
      ...match,
      'about_me':
          'Lulusan dengan pengalaman di manufaktur industri dan pemahaman SOP & K3 yang baik.',
      'nomor_telpon': '081234567890',
      'alamat': 'Jl. Industri No. 10, Cikarang',
    };
  }

  Future<List<Map<String, dynamic>>> getAllPostPekerjaan() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _formatJobsList();
  }
}
