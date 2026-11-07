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
  final TextEditingController gajiController = TextEditingController();
  final TextEditingController jobDetailsController = TextEditingController();
  final TextEditingController requirementsController = TextEditingController();

  final List<String> tipeOptions = [
    'Penuh Waktu',
    'Kontrak',
    'Shift / Harian',
    'Magang / PKL',
  ];
  String selectedTipe = 'Penuh Waktu';

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
    gajiController.dispose();
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

        // Pre-fill location from company address if empty
        if (lokasiPekerjaanController.text.trim().isEmpty &&
            user?['alamat'] != null) {
          lokasiPekerjaanController.text = user['alamat'].toString();
        }
      } else {
        setState(() {
          errorMessage = 'Gagal memuat data profil perusahaan.';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = 'Terjadi kesalahan saat memuat data profil.';
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
      await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
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
      await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> showJobPostedNotification(String title) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'job_channel',
      'Job Posting Notifications',
      channelDescription: 'Pemberitahuan penerbitan lowongan baru',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      'Lowongan Berhasil Diterbitkan',
      'Lowongan untuk $title telah aktif dan dapat dilamar kandidat.',
      platformChannelSpecifics,
    );
  }

  Future<void> _submitJob() async {
    if (isPosting) return;

    final String posisi = posisiController.text.trim();
    final String lokasi = lokasiPekerjaanController.text.trim();
    final String gaji = gajiController.text.trim();
    final String jobDetails = jobDetailsController.text.trim();
    final String requirements = requirementsController.text.trim();

    if (posisi.isEmpty) {
      _showSnackBar('Mohon isi nama posisi atau jabatan lowongan.', isError: true);
      return;
    }
    if (lokasi.isEmpty) {
      _showSnackBar('Mohon tentukan lokasi pabrik atau penempatan.', isError: true);
      return;
    }
    if (jobDetails.isEmpty) {
      _showSnackBar('Mohon lengkapi detail dan tanggung jawab pekerjaan.', isError: true);
      return;
    }
    if (requirements.isEmpty) {
      _showSnackBar('Mohon tuliskan kualifikasi dan persyaratan pelamar.', isError: true);
      return;
    }

    final int idPerusahaan = int.tryParse(user?['id_perusahaan']?.toString() ?? '') ?? 1;

    setState(() {
      isPosting = true;
    });

    try {
      final bool status = await Postingpekerjaanapi().postingPekerjaann(
        idPerusahaan,
        posisi,
        lokasi,
        jobDetails,
        requirements,
        tipe: selectedTipe,
        gaji: gaji.isNotEmpty ? gaji : 'Sesuai UMR / Kebijakan',
      );

      if (!mounted) return;

      if (status) {
        await showJobPostedNotification(posisi);

        if (!mounted) return;

        _showSnackBar('Lowongan pekerjaan berhasil diterbitkan.');

        // Bersihkan isian form
        posisiController.clear();
        lokasiPekerjaanController.clear();
        gajiController.clear();
        jobDetailsController.clear();
        requirementsController.clear();

        // Alihkan langsung ke tab Riwayat Lowongan (index 3) agar HRD dapat memantau lowongan yang baru dibuat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HRDnavbarComponent(initialIndex: 3),
          ),
        );
      } else {
        _showSnackBar('Gagal menerbitkan lowongan. Silakan coba lagi.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('Terjadi gangguan saat memproses formulir lowongan.', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          isPosting = false;
        });
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12.5,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFB91C1C) : const Color(0xFF047857),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
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
          child: CircularProgressIndicator(color: darkMaroon),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Pasang Lowongan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: errorMessage != null
          ? _buildErrorState()
          : SafeArea(
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
                    vertical: 20,
                  ),
                  children: [
                    _buildCompanyBanner(),
                    const SizedBox(height: 16),
                    if (cekDataPerusahaan())
                      _buildForm()
                    else
                      _buildIncompleteProfileCard(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCompanyBanner() {
    final String companyName = (user?['nama_perusahaan'] ??
            user?['namaPerusahaanAsli'] ??
            user?['nama'] ??
            'PT Astra Otoparts Tbk')
        .toString();
    final String address =
        (user?['alamat'] ?? 'Kawasan Industri GIIC Cikarang, Jawa Barat').toString();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PERUSAHAAN PENERBIT',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            companyName,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            address,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Spesifikasi Posisi',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tentukan nama posisi dan tempat penugasan kandidat.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),

          _buildInputField(
            controller: posisiController,
            label: 'POSISI / JABATAN *',
            hint: 'Contoh: Operator Produksi (Assembly)',
          ),

          const SizedBox(height: 16),

          _buildInputField(
            controller: lokasiPekerjaanController,
            label: 'LOKASI PENEMPATAN *',
            hint: 'Contoh: Kawasan Industri GIIC Cikarang',
          ),

          const SizedBox(height: 16),

          _buildTipePekerjaanSelector(),

          const SizedBox(height: 16),

          _buildInputField(
            controller: gajiController,
            label: 'ESTIMASI GAJI (OPSIONAL)',
            hint: 'Contoh: Rp 5.2 - 6.5 Juta',
          ),

          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 20),

          Text(
            'Detail & Persyaratan',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Jelaskan tanggung jawab kerja dan kualifikasi yang dibutuhkan.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 11.5,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 18),

          _buildInputField(
            controller: jobDetailsController,
            label: 'DETAIL PEKERJAAN & TANGGUNG JAWAB *',
            hint: 'Jelaskan alur operasional lini produksi, instruksi kerja (SOP), dan standar keselamatan...',
            maxLines: 4,
          ),

          const SizedBox(height: 16),

          _buildInputField(
            controller: requirementsController,
            label: 'PERSYARATAN & KUALIFIKASI *',
            hint: 'Contoh: Pendidikan SMK/SMA, usia 18-24 tahun, siap kerja sistem shift, teliti, tidak buta warna...',
            maxLines: 4,
          ),

          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: isPosting ? null : _submitJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                disabledBackgroundColor: darkMaroon.withOpacity(0.5),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isPosting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Terbitkan Lowongan',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipePekerjaanSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TIPE PEKERJAAN',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: tipeOptions.map((tipe) {
            final bool isSelected = selectedTipe == tipe;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedTipe = tipe;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                splashColor: darkMaroon.withOpacity(0.12),
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? darkMaroon : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? darkMaroon : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: darkMaroon.withOpacity(0.16),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Text(
                    tipe,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 10.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: blackColor,
            height: maxLines > 1 ? 1.4 : 1.2,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: darkMaroon, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIncompleteProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF59E0B).withOpacity(0.4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profil Perusahaan Belum Lengkap',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB45309),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Untuk menjaga kepercayaan pelamar, informasi profil perusahaan (deskripsi, logo, dan alamat operasional) harus dilengkapi sebelum dapat menerbitkan lowongan baru.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const Changeprofilepageperusahaan(),
                  ),
                );
                initUser();
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
                'Lengkapi Profil Sekarang',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Gagal Memuat Formulir',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Periksa koneksi jaringan Anda.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  isLoading = true;
                  errorMessage = null;
                });
                initUser();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
