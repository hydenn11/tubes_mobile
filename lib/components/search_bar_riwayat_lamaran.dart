import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/melamar_pekerjaan_api.dart';
import 'package:rekanpabrik/models/melamar_pekerjaan.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';
import 'package:rekanpabrik/dummy/dummy_melamar_pekerjaan.dart';
import 'package:rekanpabrik/dummy/dummy_postingan_pekerjaan.dart';

class searchBarRiwayatLamaran extends StatefulWidget {
  const searchBarRiwayatLamaran({super.key});

  @override
  _searchBarRiwayatLamaran createState() => _searchBarRiwayatLamaran();
}

class _searchBarRiwayatLamaran extends State<searchBarRiwayatLamaran> {
  String query = '';
  List<MelamarPekerjaan> results = [];
  List<MelamarPekerjaan> allresults = [];
  var user;
  bool _isLoading = true;

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
        await _fetchHistory();
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchHistory() async {
    try {
      int idpelamar = user['id_pelamar'];

      final pekerjaanData =
          await MelamarPekerjaanapi().gethistoryLamaran(idpelamar);

      print("DATA API:");
      print(pekerjaanData);

      final parsed =
          pekerjaanData.map((job) => MelamarPekerjaan.fromJson(job)).toList();

      print("HASIL PARSE:");
      print(parsed.length);

      setState(() {
        allresults = parsed;
        results = parsed;
        _isLoading = false;
      });
    } catch (e, s) {
      print("ERROR HISTORY:");
      print(e);
      print(s);

      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'diproses':
        return Colors.grey;
      case 'diterima':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      default:
        return Colors.black;
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                query = value;
                results = cariPekerjaan(query);
              });
            },
            decoration: InputDecoration(
              hintText: "Cari Disini...",
              hintStyle: TextStyle(color: Colors.grey),
              prefixIcon: Icon(Icons.search, color: Colors.black),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide(color: thirdColor),
              ),
            ),
          ),
          SizedBox(height: 10),
          results.isEmpty
              ? Container(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 30,
                      ),
                      Center(
                          child: Text(
                        'No jobs found',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w500,
                        ),
                      ))
                    ],
                  ),
                )
              : Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
                  height: 600,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Detailhistorylamaran(
                                    idLamaranPekerjaan:
                                        results[index].idLamaranpPekerjaan),
                              ),
                            );
                          },
                          child: ListTile(
                            title:
                                Text(results[index].namaPerusahaan.toString()),
                            subtitle: Text(results[index].posisi.toString()),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(
                                    results[index].statusLamaran),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                results[index].statusLamaran,
                                // Tampilkan status ('diproses', 'diterima', 'ditolak')
                                style: TextStyle(
                                  color: Colors.white, // Warna teks putih
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ),
    );
  }

  List<MelamarPekerjaan> cariPekerjaan(String query) {
    if (query.isEmpty) {
      return allresults;
    }

    return allresults.where((job) {
      return job.posisi.toLowerCase().contains(query.toLowerCase()) ||
          job.namaDepanPelamar.toLowerCase().contains(query.toLowerCase()) ||
          job.namaBelakangPelamar.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
