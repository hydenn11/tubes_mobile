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

  dynamic user;
  bool isLoading = true;
  bool isPosting = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _requestNotificationPermission();
    initUser();
  }

  @override
  void dispose() {
    posisiController.dispose();
    lokasiPekerjaanController.dispose();
    jobDetailsController.dispose();
    requirementsController.dispose();
    super.dispose();
  }

  Future<void> initUser() async {
    try {
      final response = await meAPI().getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage = 'Gagal mengambil data profil perusahaan.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Terjadi kesalahan saat mengambil data profil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _requestNotificationPermission() async {
    try {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (granted == false && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin notifikasi ditolak oleh pengguna.'),
          ),
        );
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    try {
      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> showJobPostedNotification() async {
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

  Future<void> postJob(
    int idPerusahaan,
    String posisi,
    String lokasi,
    String jobDetails,
    String requirements,
  ) async {
    if (isPosting) return;

    if (posisi.trim().isEmpty ||
        lokasi.trim().isEmpty ||
        jobDetails.trim().isEmpty ||
        requirements.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mohon lengkapi seluruh informasi lowongan.'),
        ),
      );
      return;
    }

    setState(() {
      isPosting = true;
    });

    try {
      final bool status = await Postingpekerjaanapi().postingPekerjaann(
        idPerusahaan,
        posisi.trim(),
        lokasi.trim(),
        jobDetails.trim(),
        requirements.trim(),
      );

      if (!mounted) return;

      if (status) {
        await showJobPostedNotification();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Lowongan pekerjaan berhasil diposting.'),
          ),
        );

        Navigator.pushNamed(context, '/pageHRD');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memposting pekerjaan. Silakan coba lagi.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat memposting pekerjaan.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  bool cekDataPerusahaan() {
    if (user == null) return false;

    return user['about_me'] != null &&
        user['about_me'].toString().trim().isNotEmpty &&
        user['profile_pict'] != null &&
        user['profile_pict'].toString().trim().isNotEmpty &&
        user['alamat'] != null &&
        user['alamat'].toString().trim().isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: darkMaroon,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: _buildErrorState(),
        ),
      );
    }

    final bool isLengkap = cekDataPerusahaan();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: () async {
            setState(() {
              isLoading = true;
            });
            await initUser();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildInformationCard(),
              const SizedBox(height: 24),
              if (isLengkap) ...[
                _buildFormSection(),
              ] else ...[
                _buildIncompleteProfileCard(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: darkMaroon.withOpacity(0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            Icons.work_outline_rounded,
            color: darkMaroon,
            size: 26,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Manajemen Lowongan',
                style: TextStyle(
                  fontSize: 13,
                  color: greyColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
              Text(
                'Unggah Lowongan',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkMaroon,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInformationCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMaroon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.16),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'REKRUTMEN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
                fontFamily: 'Poppins',
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Temukan Kandidat Sempurna untuk Tim Anda',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              height: 1.4,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Di RekanPabrik, kami memudahkan Anda untuk '
            'memasang lowongan pekerjaan dan terhubung '
            'dengan talenta terbaik. Buat informasi lowongan '
            'yang jelas agar kandidat yang sesuai dapat '
            'menemukan dan melamar pekerjaan Anda.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
              height: 1.7,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Mulai temukan talenta terbaik',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Informasi Lowongan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Lengkapi informasi pekerjaan yang ingin Anda tawarkan.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: greyColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 24),
          _buildTextField(
            controller: posisiController,
            label: 'Posisi Pekerjaan',
            hint: 'Contoh: Staff Administrasi',
            icon: Icons.work_outline_rounded,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: lokasiPekerjaanController,
            label: 'Lokasi Pekerjaan',
            hint: 'Contoh: Bandung, Jawa Barat',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: jobDetailsController,
            label: 'Detail Pekerjaan',
            hint: 'Jelaskan tanggung jawab dan deskripsi pekerjaan...',
            icon: Icons.description_outlined,
            maxLines: 5,
          ),
          const SizedBox(height: 18),
          _buildTextField(
            controller: requirementsController,
            label: 'Persyaratan',
            hint: 'Tuliskan kualifikasi dan persyaratan kandidat...',
            icon: Icons.checklist_rounded,
            maxLines: 5,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isPosting
                  ? null
                  : () {
                      final int? idPerusahaan =
                          int.tryParse(user['id_perusahaan'].toString());

                      if (idPerusahaan == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('ID perusahaan tidak valid.'),
                          ),
                        );
                        return;
                      }

                      postJob(
                        idPerusahaan,
                        posisiController.text,
                        lokasiPekerjaanController.text,
                        jobDetailsController.text,
                        requirementsController.text,
                      );
                    },
              icon: isPosting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.cloud_upload_outlined,
                      size: 20,
                    ),
              label: Text(
                isPosting ? 'Mengunggah...' : 'Unggah Lowongan',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                disabledBackgroundColor: greyColor.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: blackColor,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 9),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontSize: 13,
            color: blackColor,
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 12,
              color: greyColor.withOpacity(0.7),
              fontFamily: 'Poppins',
            ),
            prefixIcon: maxLines == 1
                ? Icon(
                    icon,
                    color: darkMaroon,
                    size: 20,
                  )
                : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE2E8F0),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: darkMaroon,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFFECACA),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.business_center_outlined,
              color: Colors.redAccent,
              size: 36,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Profil Perusahaan Belum Lengkap',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Anda belum dapat mengunggah lowongan pekerjaan. '
            'Silakan lengkapi informasi perusahaan terlebih dahulu, '
            'termasuk deskripsi, foto profil, dan alamat perusahaan.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.7,
              color: greyColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/pageHRD');
              },
              icon: const Icon(Icons.person_outline_rounded, size: 19),
              label: const Text(
                'Kembali ke Beranda',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: greyColor,
            ),
            const SizedBox(height: 18),
            Text(
              'Gagal Memuat Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: darkMaroon,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? 'Terjadi kesalahan. Silakan coba lagi.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: greyColor,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                initUser();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
