part of '../page.dart';

class Postjob extends StatefulWidget {
  const Postjob({super.key});

  @override
  State<Postjob> createState() => _PostjobState();
}

class _PostjobState extends State<Postjob> {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final TextEditingController posisiController = TextEditingController();
  final TextEditingController lokasiPekerjaanController =
      TextEditingController();
  final TextEditingController jobDetailsController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();
  var user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestNotificationPermission();
    initUser();
  }

  Future<void> initUser() async {
    var response = await meAPI().getUserProfile();

    if (response['status'] == true && response['data'] != null) {
      if (!mounted) return;
      setState(() {
        user = response['data'];
        print("USER DATA:");
        print(response['data']);
        isLoading = false;
      });
    } else {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Anda tidak login ')));
    }
  }

  void _requestNotificationPermission() async {
    final bool? granted = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    if (granted != null && !granted) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Izin notifikasi ditolak oleh pengguna ')));
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

  void showJobPostedNotification() async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_channel',
      'Job Posting Notifications',
      channelDescription: 'Notifications for new job postings',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Lowongan Pekerjaan Diposting',
      'Lowongan pekerjaan baru telah berhasil diposting.',
      platformChannelSpecifics,
    );
  }

  Future<void> postJob(int idPerusahaan, String posisi, String lokasi,
      String jobDetails, String requirements) async {
    try {
      bool status = await Postingpekerjaanapi().postingPekerjaann(
          idPerusahaan, posisi, lokasi, jobDetails, requirements);

      if (status) {
        showJobPostedNotification();
        Navigator.pushNamed(context, '/pageHRD');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memposting pekerjaan ')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error memposting pekerjaan ')));
    }
  }

  bool cekDataPerusahaan() {
    if (user['about_me'] != null &&
        user['profile_pict'] != null &&
        user['alamat'] != null) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: thirdColor,
          ),
        ),
      );
    }

    bool isLengkap = cekDataPerusahaan();

    return Scaffold(
        backgroundColor: primaryColor,
        body: SafeArea(
            bottom: true,
            child: isLengkap
                ? ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    children: [
                      SizedBox(
                        height: 50,
                      ),
                      Container(
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Unggah Lowongan Pekerjaan",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: thirdColor),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                width: 350,
                                child: RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text:
                                            "Temukan Kandidat Sempurna untuk Tim Anda ",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: thirdColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            "Di Rekan Pabrik, kami memudahkan Anda untuk memasang lowongan pekerjaan dan terhubung dengan talenta terbaik di industri ini. Baik Anda ingin mengisi satu posisi atau memperluas seluruh tim, platform kami memberi Anda alat untuk menarik kandidat yang memenuhi syarat dengan cepat dan efisien.",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                          color: thirdColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: posisiController,
                        decoration: const InputDecoration(
                          labelText: 'Posisi',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: lokasiPekerjaanController,
                        decoration: const InputDecoration(
                          labelText: 'Lokasi Pekerjaan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: jobDetailsController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Detail Pekerjaan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: requirementsController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Persyaratan',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.center,
                        child: ElevatedButton(
                          onPressed: () {
                            int idPerusahaan = user['id_perusahaan'];
                            String posisi = posisiController.text;
                            String lokasi = lokasiPekerjaanController.text;
                            String jobDetails = jobDetailsController.text;
                            String requirements = requirementsController.text;

                            postJob(idPerusahaan, posisi, lokasi, jobDetails,
                                requirements);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: succesColor,
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 50,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Unggah Lowongan',
                            style: TextStyle(
                              fontSize: 16,
                              color: primaryColor,
                              fontFamily: 'poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 200),
                    ],
                  )
                : ListView(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    children: [
                        SizedBox(
                          height: 50,
                        ),
                        Container(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Unggah Lowongan Pekerjaan",
                                  style: TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                      color: thirdColor),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: 350,
                                  child: RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              "Temukan Kandidat Sempurna untuk Tim Anda ",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: thirdColor,
                                          ),
                                        ),
                                        TextSpan(
                                          text:
                                              "Di Rekan Pabrik, kami memudahkan Anda untuk memasang lowongan pekerjaan dan terhubung dengan talenta terbaik di industri ini. Baik Anda ingin mengisi satu posisi atau memperluas seluruh tim, platform kami memberi Anda alat untuk menarik kandidat yang memenuhi syarat dengan cepat dan efisien.",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.normal,
                                            color: thirdColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Wahh, belum bisa posting pekerjaan nih",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.red,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      "Harap lengkapi data perusahaan dulu yaaa",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ])));
  }
}
