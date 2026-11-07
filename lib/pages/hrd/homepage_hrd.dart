part of '../page.dart';

class Homepagehrd extends StatefulWidget {
  final void Function(int index)? onTabChange;

  const Homepagehrd({
    super.key,
    this.onTabChange,
  });

  @override
  State<Homepagehrd> createState() => _HomepagehrdState();
}

class _HomepagehrdState extends State<Homepagehrd> {
  dynamic user;
  List<Map<String, dynamic>> postedJobs = [];
  List<Map<String, dynamic>> applicants = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    try {
      errorMessage = null;
      final response = await meAPI().getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        user = response['data'];
        final int companyId = user['id_perusahaan'] ?? 1;

        final jobsFuture = Postingpekerjaanapi().getPostPekerjaan(companyId);
        final appsFuture =
            Postingpekerjaanapi().getPelamarByCompanyId(companyId);

        final results = await Future.wait([jobsFuture, appsFuture]);

        if (!mounted) return;

        setState(() {
          postedJobs = List<Map<String, dynamic>>.from(results[0]);
          applicants = List<Map<String, dynamic>>.from(results[1]);
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              response['message'] ?? 'Gagal memuat profil perusahaan.';
        });
      }
    } catch (e) {
      debugPrint('Error loading HRD home data: $e');
      if (!mounted) return;
      setState(() {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _switchTab(int index) {
    if (widget.onTabChange != null) {
      widget.onTabChange!(index);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HRDnavbarComponent(initialIndex: index),
        ),
      );
    }
  }

  ImageProvider _getAvatarImage(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage('assets/img/defaultPict.png');
    }
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }
    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }
    final file = File(path);
    if (file.existsSync()) {
      return FileImage(file);
    }
    return const AssetImage('assets/img/defaultPict.png');
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
      return _buildErrorState();
    }

    final String companyName = (user?['nama_perusahaan'] ??
            user?['namaPerusahaanAsli'] ??
            user?['nama'] ??
            'Perusahaan')
        .toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: initData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildTopHeader(companyName),

              const SizedBox(height: 20),

              _buildActionReminderCard(),

              const SizedBox(height: 24),

              _buildRecruitmentStatusCard(),

              const SizedBox(height: 28),

              _buildRecentCandidatesSection(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(String companyName) {
    final String? profilePicture = user?['profile_pict']?.toString();

    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: darkMaroon.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: Image(
              image: _getAvatarImage(profilePicture),
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            ),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyName,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              const Row(
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 13,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Perekrut / HRD',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionReminderCard() {
    final int pendingCount = applicants
        .where((a) =>
            (a['status_lamaran'] ?? 'diproses').toString().toLowerCase() ==
            'diproses')
        .length;

    if (pendingCount == 0) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            Text(
              "Semua Berkas Sudah Ditinjau",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 3),
            const Text(
              "Belum ada berkas baru yang perlu tindakan saat ini.",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 11.5,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: darkMaroon.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _switchTab(1),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Perlu Tindakan",
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2.5),
                            decoration: BoxDecoration(
                              color: darkMaroon,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              "$pendingCount Baru",
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$pendingCount berkas pelamar menunggu review Anda.",
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: darkMaroon,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecruitmentStatusCard() {
    final activeJobs = postedJobs
        .where((j) =>
            (j['status'] ?? '').toString().toLowerCase() == 'tersedia')
        .take(2)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Lowongan Aktif",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: blackColor,
                letterSpacing: -0.3,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _switchTab(3),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    "Kelola Semua",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkMaroon,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (activeJobs.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.work_off_outlined,
                  color: greyColor,
                  size: 34,
                ),
                const SizedBox(height: 8),
                Text(
                  "Belum ada lowongan aktif",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "Buka lowongan baru untuk mulai menjaring kandidat pabrik.",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    color: greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () => _switchTab(2),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text(
                    "Pasang Lowongan",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          )
        else
          ...activeJobs.map((job) => _buildJobStatusItem(job)),
      ],
    );
  }

  Widget _buildJobStatusItem(Map<String, dynamic> job) {
    final int jobId = job['id_post_pekerjaan'] ?? 1;
    final String posisi =
        (job['posisi'] ?? 'Operator Produksi').toString();
    final String lokasi = (job['lokasi'] ?? 'Cikarang').toString();
    final String tipe = (job['tipe'] ?? 'Penuh Waktu').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailPekerjaanHRD(jobId: jobId),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        posisi,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "$lokasi • $tipe",
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: greyColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentCandidatesSection() {
    final recentApplicants = applicants.take(2).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Pelamar Terbaru",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: blackColor,
                letterSpacing: -0.3,
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _switchTab(1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    "Lihat Semua",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: darkMaroon,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (recentApplicants.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.group_outlined,
                  size: 34,
                  color: greyColor,
                ),
                const SizedBox(height: 8),
                Text(
                  "Belum ada pelamar baru",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Pelamar yang mengirim berkas akan muncul di sini.",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 11,
                    color: greyColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...recentApplicants.map((app) => _buildCandidateItem(app)),
      ],
    );
  }

  Widget _buildCandidateItem(Map<String, dynamic> app) {
    final int lamaranId = app['id_lamaran_pekerjaan'] ?? 1;
    final String firstName = (app['first_name'] ?? '').toString();
    final String lastName = (app['last_name'] ?? '').toString();
    final String candidateName =
        ('$firstName $lastName').trim().isNotEmpty
            ? ('$firstName $lastName').trim()
            : 'Kandidat Pelamar';
    final String posisi =
        (app['posisi_dilamar'] ?? app['posisi'] ?? 'Operator Produksi')
            .toString();
    final String status =
        (app['status_lamaran'] ?? 'diproses').toString().toLowerCase();

    Color statusBgColor = const Color(0xFFFFFBEB);
    Color statusTextColor = const Color(0xFFB45309);
    String statusLabel = 'Diproses';

    if (status == 'diterima') {
      statusBgColor = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF047857);
      statusLabel = 'Diterima';
    } else if (status == 'ditolak') {
      statusBgColor = const Color(0xFFFEF2F2);
      statusTextColor = const Color(0xFFB91C1C);
      statusLabel = 'Ditolak';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Detailpelamar(
                  id_lamaran_perusahaan: lamaranId,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: darkMaroon.withOpacity(0.08),
                  ),
                  child: Center(
                    child: Text(
                      candidateName.isNotEmpty
                          ? candidateName[0].toUpperCase()
                          : 'K',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: darkMaroon,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: blackColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Melamar: $posisi",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: greyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: darkMaroon.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 36,
                    color: darkMaroon,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Koneksi Terputus',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  errorMessage ?? 'Gagal memuat data perusahaan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });
                    initData();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
