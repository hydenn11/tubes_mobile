import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/models/data_pelamar_pekerjaan.dart';
import 'package:rekanpabrik/pages/hrd/detail_pelamar.dart';
import 'package:rekanpabrik/shared/shared.dart';

class SearchBarPelamarPekerjaan extends StatefulWidget {
  const SearchBarPelamarPekerjaan({super.key});

  @override
  State<SearchBarPelamarPekerjaan> createState() =>
      _SearchBarPelamarPekerjaanState();
}

class _SearchBarPelamarPekerjaanState extends State<SearchBarPelamarPekerjaan> {
  String query = '';
  List<pelamarPekerjaan> dataDitampilkan = [];
  List<Map<String, dynamic>> resultsPelamar = [];
  dynamic user;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      var response = await meAPI().getUserProfile();

      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
        });

        await _fetchPelamar();
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'Anda Tidak Login';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
      });
    }
  }

  Future<void> _fetchPelamar() async {
    try {
      int? companyId;

      if (user != null) {
        companyId = user['id_perusahaan'];
      }

      if (companyId == null) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _errorMessage = 'ID Perusahaan tidak ditemukan';
        });
        return;
      }

      var data = await Postingpekerjaanapi().getPelamarByCompanyId(companyId);

      if (!mounted) return;
      setState(() {
        _isLoading = false;

        if (data.isNotEmpty) {
          resultsPelamar = data;

          dataDitampilkan = resultsPelamar.take(5).map((item) {
            return pelamarPekerjaan(
              namaPerusahaan: item['nama_perusahaan'].toString(),
              idPelamar: item['id_pelamar'],
              firstName: item['first_name'].toString(),
              lastName: item['last_name'].toString(),
              email: item['email'].toString(),
              linkCv: item['curriculum_vitae'].toString(),
              fotoProfil: item['profile_pict'].toString(),
              id_lamaran_pekerjaan: item['id_lamaran_pekerjaan'],
              statusLamaran: item['status'].toString(),
              posisiDilamar: item['posisi'].toString(),
            );
          }).toList();
        } else {
          _errorMessage = 'Anda belum mendapatkan pelamar';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Terjadi kesalahan saat mengambil data: ${e.toString()}';
      });
    }
  }

  Color statusColors(String status) {
    switch (status) {
      case "diproses":
        return Colors.grey;
      case "ditolak":
        return dangerColor;
      case "diterima":
        return succesColor;
      default:
        return primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(
        color: thirdColor,
      ));
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            onChanged: (value) {
              setState(() {
                query = value;
                dataDitampilkan = cariDataPelamar(value);
              });
            },
            decoration: InputDecoration(
              hintText: "Cari Disini...",
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(Icons.search, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: thirdColor),
              ),
            ),
          ),
        ),
        resultsPelamar.isEmpty
            ? const Center(
                child: Text(
                  'Pelamar Not Found',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: dataDitampilkan.map((pelamar) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Text('${pelamar.firstName} ${pelamar.lastName}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(pelamar.posisiDilamar),
                            const SizedBox(height: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColors(pelamar.statusLamaran),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                pelamar.statusLamaran,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Detailpelamar(
                                    id_lamaran_perusahaan:
                                        pelamar.id_lamaran_pekerjaan)),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  List<pelamarPekerjaan> cariDataPelamar(String query) {
    if (query.isEmpty) {
      return resultsPelamar.take(5).map((item) {
        return pelamarPekerjaan(
          namaPerusahaan: item['nama_perusahaan'].toString(),
          idPelamar: item['id_pelamar'],
          firstName: item['first_name'].toString(),
          lastName: item['last_name'].toString(),
          email: item['email'].toString(),
          linkCv: item['curriculum_vitae'].toString(),
          fotoProfil: item['profile_pict'].toString(),
          statusLamaran: item['status'].toString(),
          posisiDilamar: item['posisi'].toString(),
          id_lamaran_pekerjaan: item['id_lamaran_pekerjaan'],
        );
      }).toList();
    }

    return resultsPelamar.where((item) {
      var nama = item['first_name'] ?? '';
      return nama.toLowerCase().contains(query.toLowerCase());
    }).map((item) {
      return pelamarPekerjaan(
        namaPerusahaan: item['nama_perusahaan'].toString(),
        idPelamar: item['id_pelamar'],
        firstName: item['first_name'].toString(),
        lastName: item['last_name'].toString(),
        email: item['email'].toString(),
        linkCv: item['curriculum_vitae'].toString(),
        fotoProfil: item['profile_pict'].toString(),
        statusLamaran: item['status'].toString(),
        posisiDilamar: item['posisi'].toString(),
        id_lamaran_pekerjaan: item['id_lamaran_pekerjaan'],
      );
    }).toList();
  }
}
