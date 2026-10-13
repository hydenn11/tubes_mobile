part of '../page.dart';

class Detailsavedjobs extends StatefulWidget {
  final int jobId;
  final int savedJobsId;

  const Detailsavedjobs(
      {super.key, required this.jobId, required this.savedJobsId});

  @override
  State<Detailsavedjobs> createState() => _DetailsavedjobsState();
}

class _DetailsavedjobsState extends State<Detailsavedjobs> {
  final Postingpekerjaanapi postingpekerjaanapi = Postingpekerjaanapi();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final meAPI meapi = meAPI();
  var user;
  Map<String, dynamic>? selectedJob;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
    initUser();
  }

  Future<void> initUser() async {
    var response = await meAPI().getUserProfile();
    try {
      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        isLoading = false;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Anda belum login ')));
        Navigator.pushNamed(context, '/login');
        print("Failed to retrieve user data: ${response['message']}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Anda belum login ')));
      Navigator.pushNamed(context, '/login');
      print("Failed to retrieve user data: ${response['message']}");
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      List<Map<String, dynamic>> jobDetails =
          await postingpekerjaanapi.detailsJob(widget.jobId);
      if (jobDetails.isNotEmpty) {
        setState(() {
          selectedJob = jobDetails.first;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading job details: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _DeleteSavedJobs() async {
    bool status = await SavedJobsApi().toggleSavedJobs(
      user['id_pelamar'],
      selectedJob!['id_post_pekerjaan'],
    );

    if (status) {
      Navigator.pushNamed(context, '/pagePelamar');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pekerjaan berhasil dihapus dari saved jobs',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text("Detail Pekerjaan"),
        ),
        body: Center(
          child: CircularProgressIndicator(color: thirdColor),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        backgroundColor: primaryColor,
        appBar: AppBar(
          title: Text("Detail Pekerjaan"),
        ),
        body: Center(
          child: Text(
            "Data pekerjaan tidak ditemukan.",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      );
    }

    Color statusColor =
        selectedJob!['status'] == 'terbuka' ? Colors.green : Colors.red;
    String statusText =
        selectedJob!['status'] == 'terbuka' ? "Terbuka" : "Berakhir";
    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: Text("Detail Pekerjaan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 30,
            ),
            Align(
              child: Text(
                selectedJob!['posisi'],
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 10),
            Align(
              child: Column(
                children: [
                  Text(
                    "Lokasi: ${selectedJob!['lokasi']}",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color:
                          statusColor, // Menggunakan warna berdasarkan status
                      borderRadius:
                          BorderRadius.circular(10), // Border radius 10
                    ),
                    child: Text(
                      "Status: $statusText",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white), // Warna teks putih
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50),
            Text(
              "Deskripsi Pekerjaan:",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              selectedJob!['job_details'] ?? "Tidak ada deskripsi pekerjaan.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              "Persyaratan:",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              selectedJob!['requirements'] ?? "Tidak ada persyaratan.",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 50),
            Align(
              child: selectedJob!['status'] == 'ditutup'
                  ? SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _DeleteSavedJobs();
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: dangerColor, // Warna border
                              width: 2, // Lebar border
                            ),
                            backgroundColor: primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Hapus Pekerjaan',
                            style: TextStyle(fontSize: 16, color: dangerColor),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LamarPekerjaan(
                                  jobId: selectedJob!['id_post_pekerjaan'],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: thirdColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            'Lamar Pekerjaan',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
