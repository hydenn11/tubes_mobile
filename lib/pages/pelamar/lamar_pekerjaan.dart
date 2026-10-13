part of '../page.dart';

class LamarPekerjaan extends StatefulWidget {
  final int jobId;

  const LamarPekerjaan({super.key, required this.jobId});

  @override
  State<LamarPekerjaan> createState() => _LamarPekerjaanState();
}

class _LamarPekerjaanState extends State<LamarPekerjaan> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool isLoading = true;
  var user;
  Map<String, dynamic>? selectedJob;

  @override
  void initState() {
    super.initState();
    initUser();
    _fetchJobDetails();
    _initializeNotifications();
    _requestNotificationPermission();
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
          await Postingpekerjaanapi().detailsJob(widget.jobId);
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
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void _requestNotificationPermission() async {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && !granted) {
      print("Izin notifikasi ditolak oleh pengguna");
    }
  }

  void _showJobApplicationNotification(String jobTitle) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_channel',
      'Lamaran Pekerjaan',
      channelDescription: 'Notifikasi untuk lamaran pekerjaan',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Lamaran Diajukan',
      'Anda telah melamar pekerjaan: $jobTitle',
      platformChannelSpecifics,
    );
  }

  Future<void> lamarPekerjaan(
      int idPostPekerjaan,
      int idpelamar,
      ) async {
    bool? confirmSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Pengajuan Lamaran'),
          content: const Text(
            'Apakah Anda yakin ingin mengajukan lamaran untuk pekerjaan ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Tidak'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: thirdColor,
              ),
              child: const Text(
                'Ya, Ajukan',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmSubmit != true) return;

    setState(() {
      isLoading = true;
    });

    try {
      final result = await MelamarPekerjaanapi().lamarPekerjaan(
        idPostPekerjaan,
        idpelamar,
      );

      if (result["success"] == true) {
        _showJobApplicationNotification(
          selectedJob!['posisi'],
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/pagePelamar',
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"]),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: primaryColor,
        body: Center(
          child: CircularProgressIndicator(
            color: thirdColor,
          ),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Lamar Pekerjaan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(color: thirdColor),
          ),
        ),
        body: Center(
          child: Text("Pekerjaan tidak ditemukan."),
        ),
      );
    }

    Color statusColor;
    String statusText;

    // Determine the job status and corresponding color
    if (selectedJob!['status'] == 'terbuka') {
      statusColor = Colors.green; // Green for 'available'
      statusText = "terbuka";
    } else {
      statusColor = Colors.red; // Red for 'closed'
      statusText = "ditutup";
    }

    return Scaffold(
      backgroundColor: primaryColor,
      appBar: AppBar(
        title: const Text(
          "Lamar Pekerjaan",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(color: thirdColor),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          //crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
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
                      color: statusColor, // Using color based on status
                      borderRadius:
                          BorderRadius.circular(10), // Border radius 10
                    ),
                    child: Text(
                      "Status: $statusText",
                      style: TextStyle(
                          fontSize: 16,
                          color: Colors.white), // White text color
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),

            // Job details
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
                child: Text(
              "Deskripsi Pelamar",
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            )),
            SizedBox(height: 10),
            Align(
                alignment: Alignment.center,
                child: Text(
                  "Pastikan Anda mengecek persyartan pekerjaan dan semua data diri Anda sebelum melamar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: greyColor,
                    fontWeight: FontWeight.w400,
                  ),
                )),
            SizedBox(height: 40),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize
                    .min, // Use min to prevent it from taking extra space
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white,
                    backgroundImage: user['profile_pict'] != null &&
                            user['profile_pict'].isNotEmpty
                        ? NetworkImage(user['profile_pict'])
                        : null,
                    child: (user['profile_pict'] == null ||
                            user['profile_pict'].isEmpty)
                        ? Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.black,
                          )
                        : null,
                  ),

                  SizedBox(
                      height: 10), // Use height for spacing instead of width
                  Container(
                    width: 300, // Set your desired width here
                    child: TextField(
                      controller: TextEditingController(
                          text: user['first_name'] ??
                              'Nama tidak tersedia'),
                      readOnly: true, // Makes the field non-editable
                      decoration: InputDecoration(
                        labelText: 'Nama Depan',
                      ),
                    ),
                  ),
                  SizedBox(height: 10), // Space between text fields
                  // Non-editable TextField for last name
                  Container(
                    width: 300, // Set your desired width here
                    child: TextField(
                      controller: TextEditingController(
                          text: user['last_name'] ?? ''),
                      readOnly: true, // Makes the field non-editable
                      decoration: InputDecoration(
                        labelText: 'Nama Belakang',
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (user['curriculum_vitae'] == null ||
                      user['curriculum_vitae'].isEmpty)
                    Text(
                      "Anda belum mengupload CV",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    )
                  else if (user['profile_pict'] == null ||
                      user['profile_pict'].isEmpty)
                    Text(
                      "Anda belum mengupload Foto Profil",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    )
                  else
                    Text(
                      "Anda sudah mengupload semua data",
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Saya setuju dengan peraturan yang ditetapkan oleh perusahaan",
                  style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: greyColor),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Align(
                  child: (user['profile_pict'] != null &&
                          user['profile_pict'].isNotEmpty &&
                          user['curriculum_vitae'] != null &&
                          user['curriculum_vitae'].isNotEmpty &&
                          user['about_me'] != null &&
                          user['about_me'].isNotEmpty)
                      ? ElevatedButton(
                          onPressed: () {
                            int idpelamar = user['id_pelamar'];
                            int idpostpekerjaan = widget.jobId;
                            lamarPekerjaan(idpostpekerjaan, idpelamar);
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
                            'Ajukan Lamaran',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        )
                      : null,
                ),
              ],
            ),

            SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
