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
    try {
      var response = await meAPI().getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
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
        if (!mounted) return;
        setState(() {
          selectedJob = jobDetails.first;
          isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading job details: $e");
      if (!mounted) return;
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
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
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
      'Anda telah melamar: $jobTitle',
      platformChannelSpecifics,
    );
  }

  Future<void> lamarPekerjaan(
    int idPostPekerjaan,
    int idpelamar,
    String companyName,
  ) async {
    bool? confirmSubmit = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: Colors.white,
          title: Text(
            'Kirim Lamaran?',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
          content: Text(
            'Berkas lamaran Anda akan dikirimkan ke $companyName untuk ditinjau.',
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Kirim',
                style: TextStyle(
                  fontFamily: 'poppins',
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
          selectedJob!['posisi'] ?? 'Lowongan Pabrik',
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              result["message"] ?? 'Lamaran berhasil diajukan.',
              style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
            ),
            backgroundColor: succesColor,
          ),
        );

        Navigator.pushNamedAndRemoveUntil(
          context,
          '/pagePelamar',
          (route) => false,
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            content: Text(result["message"] ?? 'Gagal mengajukan lamaran.'),
            backgroundColor: dangerColor,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text("Error: $e"),
          backgroundColor: dangerColor,
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Lamar Pekerjaan",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: darkMaroon),
        ),
      );
    }

    if (selectedJob == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: blackColor,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            "Lamar Pekerjaan",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blackColor,
            ),
          ),
        ),
        body: Center(
          child: Text(
            "Pekerjaan tidak ditemukan.",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 14,
              color: greyColor,
            ),
          ),
        ),
      );
    }

    String companyName = 'PT Manufaktur Industri';
    final int idPerusahaan = selectedJob!['id_perusahaan'] ?? 0;
    final matchedComp = dummyPerusahaan.firstWhere(
      (p) => p['id'] == idPerusahaan,
      orElse: () => <String, dynamic>{},
    );
    if (matchedComp.isNotEmpty) {
      companyName = matchedComp['namaPerusahaanAsli'] ??
          matchedComp['nama'] ??
          companyName;
    }

    final String posisi = selectedJob!['posisi'] ?? 'Lowongan Pekerjaan';
    final String lokasi = selectedJob!['lokasi'] ?? 'Kawasan Industri';

    final String firstName = user?['first_name']?.toString() ?? '';
    final String lastName = user?['last_name']?.toString() ?? '';
    final String? rawCv = user?['cv'] ?? user?['curriculum_vitae'] ?? user?['cv_path'];
    final String? cvName = (rawCv != null && rawCv.isNotEmpty)
        ? rawCv.split(RegExp(r'[\\/]')).last
        : null;
    final bool hasCV = cvName != null && cvName.isNotEmpty;

    final int idPelamar = user != null ? (user['id_pelamar'] ?? 1) : 1;
    final int idPostPekerjaan = selectedJob!['id_post_pekerjaan'] ?? widget.jobId;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: blackColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Lamar Pekerjaan",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFF1F5F9),
            height: 1,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            Text(
              posisi,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: blackColor,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              companyName,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 14,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 15,
                  color: Color(0xFF64748B),
                ),
                const SizedBox(width: 4),
                Text(
                  lokasi,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 22),

            const Text(
              "Data Pelamar",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 14),

            _buildInfoRow("Nama Depan", firstName.isNotEmpty ? firstName : "-"),
            const SizedBox(height: 10),
            _buildInfoRow("Nama Belakang", lastName.isNotEmpty ? lastName : "-"),

            const SizedBox(height: 22),
            const Divider(color: Color(0xFFE2E8F0), height: 1),
            const SizedBox(height: 22),

            const Text(
              "Berkas Terlampir",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            if (hasCV)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.description_outlined,
                      color: darkMaroon,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cvName!,
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            "Curriculum Vitae",
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFECACA)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFDC2626),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Belum ada CV terunggah",
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF991B1B),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            "Silakan unggah CV terlebih dahulu untuk melamar lowongan ini.",
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11,
                              color: Color(0xFFB91C1C),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UploadCv(),
                          ),
                        );
                        initUser();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkMaroon,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        visualDensity: VisualDensity.compact,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text(
                        "Upload",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),

            Text(
              "Dengan mengajukan lamaran, profil dan CV Anda akan diteruskan ke tim rekrutmen $companyName.",
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  if (!hasCV) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        behavior: SnackBarBehavior.floating,
                        content: const Text("Silakan unggah CV terlebih dahulu sebelum mengajukan lamaran."),
                        backgroundColor: dangerColor,
                      ),
                    );
                    return;
                  }
                  lamarPekerjaan(idPostPekerjaan, idPelamar, companyName);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Kirim Lamaran",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: Color(0xFF64748B),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
          ),
        ),
      ],
    );
  }
}
