import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/models/posting_pekerjaan.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class searchBarCariPekerjaan extends StatefulWidget {
  const searchBarCariPekerjaan({super.key});

  @override
  _searchBarCariPekerjaan createState() => _searchBarCariPekerjaan();
}

class _searchBarCariPekerjaan extends State<searchBarCariPekerjaan> {
  String query = '';
  List<PostingPekerjaan> results = [];
  List<PostingPekerjaan> allresults = [];
  dynamic user;
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

        await _fetchPekerjaan();
      } else {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Harap Login Kembali"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi Error"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchPekerjaan() async {
    try {
      final pekerjaanData = await Postingpekerjaanapi().getAllPostPekerjaan();
      if (!mounted) return;

      setState(() {
        allresults =
            pekerjaanData.map((job) => PostingPekerjaan.fromJson(job)).toList();
        results = allresults;
        results = results.take(5).toList();
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
                  height: 300,
                  child: ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white, // Background color
                        ),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => detailPekerjaan(
                                    jobId: results[index].idPostPekerjaan),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(results[index].posisi),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(results[index].lokasi),
                                SizedBox(
                                    height:
                                        4), // Optional: Spacing between location and company name
                                Text(
                                  results[index].namaPerusahaan,
                                  style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey),
                                ),
                              ],
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

  List<PostingPekerjaan> cariPekerjaan(String query) {
    if (query.isEmpty) {
      return allresults;
    }

    return allresults.where((job) {
      return job.posisi.toLowerCase().contains(query.toLowerCase()) ||
          job.lokasi.toLowerCase().contains(query.toLowerCase()) ||
          job.namaPerusahaan.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
