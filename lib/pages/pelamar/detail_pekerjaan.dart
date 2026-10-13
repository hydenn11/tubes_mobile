part of '../page.dart';

class detailPekerjaan extends StatefulWidget {
  final int jobId;

  const detailPekerjaan({super.key, required this.jobId});

  @override
  State<detailPekerjaan> createState() => _detailPekerjaanState();
}

class _detailPekerjaanState extends State<detailPekerjaan> {
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
    _initializeNotifications();
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

  void _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void showJobSavedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_save_channel',
      'Job Save Notifications',
      channelDescription: 'Notifications for saved jobs',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      1,
      'Pekerjaan Disimpan',
      'Pekerjaan berhasil disimpan ke daftar favorit Anda!',
      platformChannelSpecifics,
    );
  }

  Future<void> savedJob(
    int idPostPekerjaan,
    int idpelamar,
  ) async {
    try {
      final result = await SavedJobsApi().savedJobs(idPostPekerjaan, idpelamar);

      if (result["success"] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
          ),
        );

        if (result["saved"] == true) {
          showJobSavedNotification();
        }

        Navigator.pushNamed(context, '/pagePelamar');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error menyimpan pekerjaan',
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
        selectedJob!['status'] == 'terbuka' ? "terbuka" : "ditutup";

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
                  Text(
                    formatTanggal(selectedJob!['createdAt']),
                    style: TextStyle(fontSize: 13),
                  ),
                  SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      "Status: $statusText",
                      style: TextStyle(fontSize: 16, color: Colors.white),
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
                            int idpostingan = widget.jobId;
                            int idPelamar = user['id_pelamar'];

                            savedJob(idpostingan, idPelamar);
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(
                              color: thirdColor, // Warna border
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
                            'Simpan Pekerjaan',
                            style: TextStyle(fontSize: 16, color: thirdColor),
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
