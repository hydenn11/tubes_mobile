part of '../page.dart';

class home_pelamar extends StatefulWidget {
  const home_pelamar({super.key});

  @override
  State<home_pelamar> createState() => _homePelamar();
}

class _homePelamar extends State<home_pelamar> {
  var user;
  bool isLoading = true;
  String? errorMessage;
  List<Map<String, dynamic>> myApplications = [];
  List<Map<String, dynamic>> recommendedJobs = [];

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    try {
      errorMessage = null;
      final userRes = await meAPI().getUserProfile();
      if (userRes['status'] == true && userRes['data'] != null) {
        user = userRes['data'];
        final apps = await MelamarPekerjaanapi()
            .gethistoryLamaran(user['id_pelamar'] ?? 1);
        myApplications = apps;
        recommendedJobs = List<Map<String, dynamic>>.from(dummyPostPekerjaan);
      } else {
        errorMessage = userRes['message'] ?? "Gagal memuat profil pelamar.";
      }
    } catch (e) {
      debugPrint("Error loading home data: $e");
      errorMessage = "Tidak dapat terhubung ke server. Periksa jaringan Anda.";
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
                      color: darkMaroon.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.cloud_off_rounded,
                        size: 36, color: darkMaroon),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Koneksi Terputus",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    errorMessage!,
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
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text(
                      "Coba Lagi",
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
                          horizontal: 24, vertical: 12),
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

    final String userName = (user != null && user['nama'] != null)
        ? user['nama'].toString()
        : 'Sobat Pabrik';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: () async {
            await initData();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              _buildTopHeader(userName),

              const SizedBox(height: 24),

              _buildApplicationStatusCard(),

              const SizedBox(height: 28),

              _buildRecommendationSection(),

              const SizedBox(height: 28),

              _buildIndustrialNewsSection(),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(String userName) {
    return Row(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border:
                Border.all(color: darkMaroon.withValues(alpha: 0.25), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: _buildAvatarImage(user?['profile_pict']?.toString()),
          ),
        ),
        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
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
              Row(
                children: [
                  const SizedBox(width: 1),
                  const Text(
                    "Pencari Kerja",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        _buildHeaderIconButton(
          icon: Icons.notifications_rounded,
          hasBadge: true,
          onTap: () {
            _showNotificationDialog();
          },
        ),
      ],
    );
  }

  Widget _buildAvatarImage(String? path) {
    if (path == null || path.isEmpty) return _defaultAvatar();
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultAvatar(),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      color: darkMaroon.withValues(alpha: 0.08),
      child: Icon(
        Icons.person_rounded,
        size: 30,
        color: darkMaroon,
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: darkMaroon.withValues(alpha: 0.12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Icon(icon, color: blackColor, size: 22),
              if (hasBadge)
                Positioned(
                  top: 10,
                  right: 11,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: darkMaroon,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildApplicationStatusCard() {
    final activeApps = myApplications.take(2).toList();
    final int diterimaCount = myApplications
        .where((a) =>
            (a['status_lamaran'] ?? '').toString().toLowerCase() == 'diterima')
        .length;
    final int diprosesCount = myApplications
        .where((a) =>
            (a['status_lamaran'] ?? '').toString().toLowerCase() == 'diproses')
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Lamaran Anda",
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: blackColor,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B), // Dark Slate / Charcoal
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (activeApps.isEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: Colors.white.withValues(alpha: 0.6), size: 36),
                      const SizedBox(height: 8),
                      const Text(
                        "Belum ada lamaran aktif",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Kirim lamaran ke lowongan pabrik impian Anda sekarang.",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const Caripekerjaan(showBackButton: true)),
                          );
                        },
                        icon: const Icon(Icons.search_rounded, size: 16),
                        label: const Text(
                          "Jelajahi Lowongan Pabrik",
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
                ...activeApps.map((app) => _buildApplicationStatusItem(app)),

              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _statusDot(const Color(0xFF10B981), "Diterima"),
                      const SizedBox(width: 12),
                      _statusDot(const Color(0xFFF59E0B), "Diproses"),
                    ],
                  ),

                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                const riwayatLamaran(showBackButton: true)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF0F172A),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      minimumSize: const Size(0, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Lihat lainnya",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
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

  Widget _buildApplicationStatusItem(Map<String, dynamic> app) {
    final status =
        (app['status_lamaran'] ?? 'diproses').toString().toLowerCase();
    final bool isDiterima = status == 'diterima';
    final Color barColor = isDiterima
        ? const Color(0xFF10B981) // Green
        : (status == 'ditolak'
            ? dangerColor
            : const Color(0xFFF59E0B)); // Orange/Amber

    final String message = isDiterima
        ? "Selamat anda diterima di perusahaan"
        : (status == 'ditolak'
            ? "Mohon maaf anda belum diterima di"
            : "Berkas lamaran sedang diproses oleh");

    final String companyName =
        (app['nama_perusahaan'] ?? 'PT Manufaktur').toString();
    final String posisi = (app['posisi'] ?? 'Operator Produksi').toString();

    final String shortName = companyName
        .replaceAll('PT ', '')
        .replaceAll(' Tbk', '')
        .split(' ')
        .first
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 6,
                color: barColor,
              ),

              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 44,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            shortName,
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: darkMaroon,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              message,
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 11,
                                color: Color(0xFF475569),
                                height: 1.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: blackColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              posisi,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 12,
                                color: darkMaroon,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationSection() {
    final jobs = recommendedJobs;
    if (jobs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            children: [
              Icon(Icons.search_off_rounded, size: 36, color: greyColor),
              const SizedBox(height: 6),
              const Text(
                "Belum ada rekomendasi lowongan saat ini",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  color: Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final featuredJob = jobs.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Rekomendasi",
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const Caripekerjaan(showBackButton: true)),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Text(
                    "Semua Lowongan",
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

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
                const Color(0xFF1E293B), // Charcoal / Dark Slate ala referensi
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: _buildFeaturedJobCard(featuredJob),
        ),
      ],
    );
  }

  Widget _buildFeaturedJobCard(Map<String, dynamic> job) {
    final idPerusahaan = job['id_perusahaan'] ?? 1;
    final companyMatch = dummyPerusahaan.firstWhere(
      (c) => c['id'] == idPerusahaan,
      orElse: () => {'nama': 'PT Astra Otoparts'},
    );
    final String companyName = (companyMatch['namaPerusahaanAsli'] ??
            companyMatch['nama'] ??
            'PT Astra Otoparts')
        .toString();

    final String posisi =
        (job['posisi'] ?? 'Operator Produksi Assembly').toString();
    final String lokasi =
        (job['lokasi'] ?? 'Kawasan MM2100, Cikarang').toString();
    final String tipe = (job['tipe'] ?? 'Penuh Waktu').toString();
    final String gaji = (job['gaji'] ?? 'Rp 5.2 - 6.5 Jt').toString();
    final int jobId = job['id_post_pekerjaan'] ?? 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -15,
              child: Opacity(
                opacity: 0.15,
                child: CustomPaint(
                  size: const Size(110, 90),
                  painter: _WavePatternPainter(color: darkMaroon.withValues(alpha: 0.2)),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 72,
                        height: 52,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFFCBD5E1),
                            width: 1.2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            companyName
                                .replaceAll('PT ', '')
                                .split(' ')
                                .first
                                .toUpperCase(),
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: darkMaroon,
                              letterSpacing: 0.5,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posisi,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: blackColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              companyName,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 13,
                                color: greyColor,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: darkMaroon.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tipe,
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: darkMaroon,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          "Gaji $gaji",
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF047857),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                lokasi,
                                style: const TextStyle(
                                  fontFamily: 'poppins',
                                  fontSize: 12,
                                  color: Color(0xFF475569),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),

                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  detailPekerjaan(jobId: jobId),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkMaroon,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 10),
                          minimumSize: const Size(0, 44),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "Lamar",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIndustrialNewsSection() {
    final List<Map<String, dynamic>> newsArticles = [
      {
        'tag': 'Tips Rekrutmen',
        'title': 'Panduan Lolos Tes Fisik, Ketelitian & MCU Pabrik',
        'desc':
            'Kiat penting menjaga stamina, tes buta warna, dan tes ketelitian kreapelin/pauli untuk calon operator.',
        'gradient': [darkMaroon, const Color(0xFF5A1414)],
      },
      {
        'tag': 'K3 & Budaya Kerja',
        'title': 'Mengenal Standar 5S & Kaizen di Pabrik Manufaktur',
        'desc':
            'Pahami konsep Seiri, Seiton, Seiso, Seiketsu, Shitsuke agar punya nilai plus saat interview HRD.',
        'gradient': [const Color(0xFF1E293B), const Color(0xFF0F172A)],
      },
      {
        'tag': 'Kawasan Industri',
        'title': 'Kawasan Industri Terbesar di Cikarang & Karawang',
        'desc':
            'Informasi kawasan MM2100, GIIC, KIIC, Jababeka, dan Suryacipta yang aktif membuka lowongan.',
        'gradient': [const Color(0xFF1E3A5F), const Color(0xFF0F172A)],
      },
      {
        'tag': 'Shift & Fisik',
        'title': 'Tips Menjaga Kebugaran saat Shift Malam Pabrik',
        'desc':
            'Pola tidur teratur, asupan nutrisi seimbang, dan manajemen ritme kerja agar tetap fokus bekerja shift.',
        'gradient': [const Color(0xFF2E1065), const Color(0xFF0F172A)],
      },
      {
        'tag': 'Gaji & Benefit',
        'title': 'Memahami Komponen Slip Gaji Operator & Lembur',
        'desc':
            'Penjelasan detail gaji pokok UMR/UMK, perhitungan lembur Depnaker, serta tunjangan kehadiran shift.',
        'gradient': [const Color(0xFF064E3B), const Color(0xFF0F172A)],
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Berita Pekerjaan",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: blackColor,
                letterSpacing: -0.3,
              ),
            ),
            const Text(
              "Edukasi Karir",
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 190,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            clipBehavior: Clip.none,
            padding: const EdgeInsets.symmetric(horizontal: 2),
            itemCount: newsArticles.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = newsArticles[index];
              return _buildNewsCard(item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewsCard(Map<String, dynamic> item) {
    final List<Color> gradientColors = item['gradient'] as List<Color>;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          _showArticleBottomSheet(item);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: darkMaroon.withValues(alpha: 0.1),
        child: Container(
          width: 215,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 85,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: gradientColors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        item['tag'] ?? 'Manufaktur',
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Wawasan Karir",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] ?? '',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: blackColor,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(Icons.notifications_active_rounded,
                  color: darkMaroon, size: 24),
              const SizedBox(width: 10),
              Text(
                "Notifikasi",
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkMaroon,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _notificationItem(
                title: "Lamaran Anda Diterima!",
                desc:
                    "PT Astra Otoparts Tbk menerima berkas Anda untuk posisi Operator Produksi.",
                time: "Hari ini",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const riwayatLamaran(showBackButton: true)),
                  );
                },
              ),
              const Divider(height: 16),
              _notificationItem(
                title: "Lowongan Baru di Karawang",
                desc:
                    "PT Toyota Motor Manufacturing membuka lowongan teknisi baru.",
                time: "Kemarin",
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => detailPekerjaan(jobId: 2)),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Tutup",
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: darkMaroon,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _notificationItem({
    required String title,
    required String desc,
    required String time,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        splashColor: darkMaroon.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 10,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      desc,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }

  void _showArticleBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: darkMaroon.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['tag'] ?? 'Manufaktur',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: darkMaroon,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: blackColor,
                    ),
                  ),
                  const Divider(height: 24),
                  Text(
                    item['desc'] ?? '',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      height: 1.6,
                      color: blackColor,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    "Dalam industri manufaktur dan pabrik perakitan, seleksi berkas dan tes ketelitian merupakan gerbang awal. Pastikan Anda mempersiapkan fisik dengan baik sebelum Medical Check-Up (MCU), memahami instruksi kerja, dan selalu memperhatikan perlengkapan keselamatan K3 seperti helm, safety shoes, dan kacamata pelindung.",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      height: 1.6,
                      color: greyColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: darkMaroon,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Tutup Bacaan",
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _WavePatternPainter extends CustomPainter {
  final Color color;
  _WavePatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (double r = 18; r <= size.width + 40; r += 16) {
      canvas.drawCircle(Offset(size.width, size.height), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
