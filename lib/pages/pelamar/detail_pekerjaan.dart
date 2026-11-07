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
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
    initUser();
    _initializeNotifications();
  }

  Future<void> initUser() async {
    try {
      var response = await meAPI().getUserProfile();
      if (response['status'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          user = response['data'];
        });
        _checkIfSaved();
      }
    } catch (e) {
      debugPrint("Error loading user profile: $e");
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchJobDetails() async {
    try {
      List<Map<String, dynamic>> jobDetails =
          await postingpekerjaanapi.detailsJob(widget.jobId);
      if (jobDetails.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          selectedJob = jobDetails.first;
          isLoading = false;
        });
        _checkIfSaved();
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

  Future<void> _checkIfSaved() async {
    try {
      final int pelamarId = user != null ? (user['id_pelamar'] ?? 1) : 1;
      final savedList =
          await SavedJobsApi().getSavedJobsByIDPelamar(pelamarId);
      if (mounted) {
        setState(() {
          isSaved = savedList.any((s) => s['id_post_pekerjaan'] == widget.jobId);
        });
      }
    } catch (_) {}
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

  Future<void> _toggleSaved() async {
    try {
      final int pelamarId = user != null ? (user['id_pelamar'] ?? 1) : 1;
      final result =
          await SavedJobsApi().savedJobs(widget.jobId, pelamarId);

      if (result["success"] == true && mounted) {
        setState(() {
          isSaved = result["saved"] == true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Text(
              isSaved
                  ? 'Pekerjaan berhasil disimpan ke favorit.'
                  : 'Pekerjaan dihapus dari favorit.',
              style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
            ),
          ),
        );

        if (isSaved) {
          showJobSavedNotification();
        }
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error mengubah status simpan.'),
        ),
      );
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
            "Detail Lowongan",
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
            "Detail Lowongan",
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
            "Data lowongan tidak ditemukan.",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 14,
              color: greyColor,
            ),
          ),
        ),
      );
    }

    final bool isOpen = selectedJob!['status'] == 'terbuka' ||
        selectedJob!['status'] == 'tersedia';

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
    final String? gaji = selectedJob!['gaji'];
    final String? tipe = selectedJob!['tipe'];

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
          "Detail Lowongan",
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                children: [
                  Text(
                    posisi,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    companyName,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lokasi,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOpen
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOpen ? "Lowongan Buka" : "Ditutup",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: isOpen ? succesColor : dangerColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (gaji != null || tipe != null) ...[
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (gaji != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.payments_outlined,
                                  size: 14,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  gaji,
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (tipe != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.work_outline_rounded,
                                  size: 14,
                                  color: Color(0xFF475569),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  tipe,
                                  style: TextStyle(
                                    fontFamily: 'poppins',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: blackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),
                  const Divider(color: Color(0xFFE2E8F0), height: 1),
                  const SizedBox(height: 22),

                  Text(
                    "Deskripsi Pekerjaan",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedJob!['job_details'] ??
                        "Tidak ada deskripsi pekerjaan.",
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    "Persyaratan",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    selectedJob!['requirements'] ??
                        "Tidak ada persyaratan khusus.",
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13.5,
                      color: Color(0xFF475569),
                      height: 1.55,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        onPressed: _toggleSaved,
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: isSaved
                                ? darkMaroon
                                : const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        child: Text(
                          isSaved ? "Disimpan" : "Simpan",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isSaved ? darkMaroon : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        onPressed: isOpen
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LamarPekerjaan(
                                      jobId: selectedJob!['id_post_pekerjaan'] ??
                                          widget.jobId,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkMaroon,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          disabledBackgroundColor: const Color(0xFFCBD5E1),
                        ),
                        child: const Text(
                          "Lamar Sekarang",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
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
