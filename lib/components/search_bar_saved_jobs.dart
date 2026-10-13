import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/saved_jobs_api.dart';
import 'package:rekanpabrik/models/saved_jobs.dart';
import 'package:rekanpabrik/pages/page.dart';
import 'package:rekanpabrik/shared/shared.dart';

class searchBarSavedJobs extends StatefulWidget {
  const searchBarSavedJobs({super.key});

  @override
  _searchBarSavedJobs createState() => _searchBarSavedJobs();
}

class _searchBarSavedJobs extends State<searchBarSavedJobs> {
  String query = '';
  List<SavedJobs> results = [];
  List<SavedJobs> allresults = [];
  var user;
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
        await _fetchPekerjaan();
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

  Future<void> _fetchPekerjaan() async {
    try {
      int idpelamar = user['id_pelamar'];

      final pekerjaanData =
          await SavedJobsApi().getSavedJobsByIDPelamar(idpelamar);

      print("DATA SAVED JOBS:");
      print(pekerjaanData);

      if (!mounted) return;

      setState(() {
        allresults =
            pekerjaanData.map((job) => SavedJobs.fromJson(job)).toList();

        results = allresults;
        _isLoading = false;
      });
    } catch (e, stack) {
      print("ERROR SAVED JOBS:");
      print(e);
      print(stack);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
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
                      Align(
                          child: Text(
                        'Anda belum menyimpan pekerjaan',
                        style: TextStyle(
                          fontSize: 20,
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
                                builder: (context) => Detailsavedjobs(
                                    savedJobsId: results[index].idSavedJobs,
                                    jobId: results[index].idPostPekerjaan),
                              ),
                            );
                          },
                          child: ListTile(
                            title: Text(results[index].posisi),
                            subtitle: Text(results[index].lokasi),
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

  List<SavedJobs> cariPekerjaan(String query) {
    if (query.isEmpty) {
      return allresults;
    }

    return allresults.where((job) {
      return job.posisi.toLowerCase().contains(query.toLowerCase()) ||
          job.lokasi.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
