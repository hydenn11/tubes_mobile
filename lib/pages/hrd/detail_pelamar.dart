import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/melamar_pekerjaan_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailpelamar extends StatefulWidget {
  final int id_lamaran_perusahaan;

  const Detailpelamar({super.key, required this.id_lamaran_perusahaan});

  @override
  _DetailpelamarState createState() => _DetailpelamarState();
}

class _DetailpelamarState extends State<Detailpelamar> {
  var pelamar;
  bool isLoading = true;
  final String defaultFotoIMG = 'assets/img/defaultPict.png';

  @override
  void initState() {
    super.initState();
    fetchDetailPelamar(widget.id_lamaran_perusahaan);
  }

  Future<void> fetchDetailPelamar(int idLamaranPekerjaan) async {
    try {
      final data =
          await Postingpekerjaanapi().getDetailPelamar(idLamaranPekerjaan);
      setState(() {
        pelamar = data;
        isLoading = false;
        print("DETAIL PELAMAR:");
        print(data);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Future<void> updateStatus(String status, int idlamaranpekerjaan) async {
    try {
      bool result = await MelamarPekerjaanapi()
          .ubahStatusPelamar(status, idlamaranpekerjaan);

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lamaran $status')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  Color statusColors(String status) {
    if (status == "diproses") {
      return Colors.grey;
    } else if (status == "ditolak") {
      return Colors.red;
    } else if (status == "diterima") {
      return Colors.green;
    } else {
      return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detail Pelamar'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : pelamar != null
              ? SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      Center(
                        child: CircleAvatar(
                            radius: 50,
                            backgroundImage: pelamar?['profile_pict'] != null &&
                                    pelamar['profile_pict']
                                        .toString()
                                        .isNotEmpty
                                ? NetworkImage(pelamar['profile_pict'])
                                : AssetImage(defaultFotoIMG) as ImageProvider),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColors(
                            pelamar!['status'].toString(),
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          pelamar!['status'].toString(),
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller:
                            TextEditingController(text: pelamar!['first_name']),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller:
                            TextEditingController(text: pelamar!['last_name']),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      TextField(
                        controller:
                            TextEditingController(text: pelamar!['posisi']),
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Posisi yang dilamar',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: thirdColor),
                        onPressed: () =>
                            _launchCV(pelamar!['curriculum_vitae'], context),
                        child: const Text(
                          'Download CV',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 50),
                      pelamar['status'] != "diterima" &&
                              pelamar['status'] != "ditolak"
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    bool? confirm =
                                        await _showConfirmationDialogDiTolak(
                                            context);
                                    if (confirm ?? false) {
                                      int idlamaranpekerjaan =
                                          pelamar?['id_lamaran_pekerjaan'];
                                      await updateStatus(
                                          "ditolak", idlamaranpekerjaan);
                                      Navigator.pushNamed(context, '/pageHRD');
                                    }
                                  },
                                  child: const Text('Tolak Pelamar'),
                                ),
                                ElevatedButton(
                                  onPressed: () async {
                                    bool? confirm =
                                        await _showConfirmationDialogDiterima(
                                            context);
                                    if (confirm ?? false) {
                                      int idlamaranpekerjaan =
                                          pelamar?['id_lamaran_pekerjaan'];
                                      await updateStatus(
                                          "diterima", idlamaranpekerjaan);
                                      Navigator.pushNamed(context, '/pageHRD');
                                    }
                                  },
                                  child: const Text('Terima Pelamar'),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      // Tidak menampilkan apapun jika sudah diterima/ditolak
                    ],
                  ),
                )
              : Center(child: const Text('Data pelamar tidak ditemukan')),
    );
  }

  Future<void> _launchCV(String? cvUrl, BuildContext context) async {
    if (cvUrl != null && cvUrl.isNotEmpty) {
      final Uri uri = Uri.parse(cvUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka CV')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('CV tidak tersedia')),
      );
    }
  }
}

Future<bool?> _showConfirmationDialogDiterima(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menerima pelamar ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
}

Future<bool?> _showConfirmationDialogDiTolak(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Konfirmasi'),
        content: const Text('Apakah Anda yakin ingin menolak pelamar ini?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Tidak'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Ya'),
          ),
        ],
      );
    },
  );
}
