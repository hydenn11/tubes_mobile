import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/perusahaan_api.dart';
import 'package:rekanpabrik/models/perusahaan.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class searchBarCariPabrik extends StatefulWidget {
  const searchBarCariPabrik({super.key});

  @override
  _searchBarCariPabrik createState() => _searchBarCariPabrik();
}

class _searchBarCariPabrik extends State<searchBarCariPabrik> {
  String query = '';
  List<Perusahaan> results = [];
  List<Perusahaan> allresults = [];
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
        await _fetchPerusahaan();
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

  Future<void> _fetchPerusahaan() async {
    try {
      final pekerjaanData = await PerusahaanAPI().getAllPerusahaan();
      print(pekerjaanData);
      if (!mounted) return;
      setState(() {
        allresults =
            pekerjaanData.map((job) => Perusahaan.fromJson(job)).toList();
        results = allresults;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
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
                results = CariPabrik(query);
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
                        'No companies found',
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
                  height: 300,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius:
                              BorderRadius.circular(10), // Rounded corners
                          color: Colors.white,
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPerusahaan(
                                    companyId: results[index].idPerusahaan),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(results[index].namaPerusahaan),
                            subtitle: Text(
                                '${results[index].jumlahPostingan} Lowongan'),
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

  List<Perusahaan> CariPabrik(String query) {
    if (query.isEmpty) {
      return allresults;
    }

    return allresults.where((company) {
      return company.namaPerusahaan.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
