part of '../page.dart';

class Caripekerjaan extends StatefulWidget {
  final bool showBackButton;

  const Caripekerjaan({super.key, this.showBackButton = false});

  @override
  State<Caripekerjaan> createState() => _CaripekerjaanState();
}

class _CaripekerjaanState extends State<Caripekerjaan> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  Set<int> _savedJobIds = {};
  var _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSavedJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initSavedJobs() async {
    try {
      final userRes = await meAPI().getUserProfile();
      if (userRes['status'] == true && userRes['data'] != null) {
        _user = userRes['data'];
      }
      final int pelamarId = _user != null ? (_user['id_pelamar'] ?? 1) : 1;
      final savedData = await SavedJobsApi().getSavedJobsByIDPelamar(pelamarId);
      final Set<int> ids = {};
      for (final s in savedData) {
        final id = s['id_post_pekerjaan'];
        if (id != null && id is int) {
          ids.add(id);
        }
      }
      if (mounted) {
        setState(() {
          _savedJobIds = ids;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching saved jobs: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleSave(int jobId) async {
    final int pelamarId = _user != null ? (_user['id_pelamar'] ?? 1) : 1;
    setState(() {
      if (_savedJobIds.contains(jobId)) {
        _savedJobIds.remove(jobId);
      } else {
        _savedJobIds.add(jobId);
      }
    });

    try {
      await SavedJobsApi().toggleSavedJobs(pelamarId, jobId);
    } catch (e) {
      debugPrint("Error toggling saved job: $e");
    }
  }

  List<Map<String, dynamic>> _getFilteredJobs() {
    if (_searchQuery.trim().isEmpty) {
      return dummyPostPekerjaan;
    }
    final q = _searchQuery.toLowerCase().trim();
    return dummyPostPekerjaan.where((job) {
      final posisi = (job['posisi'] ?? '').toString().toLowerCase();
      final lokasi = (job['lokasi'] ?? '').toString().toLowerCase();
      final bidang = (job['bidang'] ?? '').toString().toLowerCase();

      final idPerusahaan = job['id_perusahaan'] ?? 1;
      final company = dummyPerusahaan.firstWhere(
        (c) => c['id'] == idPerusahaan,
        orElse: () => {'nama': ''},
      );
      final companyName = (company['namaPerusahaanAsli'] ??
              company['nama'] ??
              '')
          .toString()
          .toLowerCase();

      return posisi.contains(q) ||
          lokasi.contains(q) ||
          bidang.contains(q) ||
          companyName.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredJobs = _getFilteredJobs();
    final bool showBack = widget.showBackButton;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // 0. TOP BAR BACK BUTTON (MUNCUL KETIKA DIBUKA DARI BERANDA)
            if (showBack) ...[
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: blackColor,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    "Semua Lowongan",
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: blackColor,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // 1. SEARCH BAR KONSISTEN (BRAND DARK MAROON & NEUTRAL SLATE BORDER)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: darkMaroon,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 14,
                        color: blackColor,
                      ),
                      decoration: const InputDecoration(
                        hintText: "Cari posisi, lokasi, atau nama pabrik...",
                        hintStyle: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: const Icon(
                        Icons.cancel_rounded,
                        color: Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. TOMBOL PIL: LAMARAN YANG ANDA SIMPAN (BENTUK KAPSUL SESUAI REFERENSI DENGAN WARNA CHARCOAL)
            Material(
              color: const Color(0xFF1E293B), // Charcoal Slate sesuai tema
              borderRadius: BorderRadius.circular(30), // Bentuk kapsul / pill
              elevation: 0,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const savedJobs()),
                  );
                },
                borderRadius: BorderRadius.circular(30),
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  child: Row(
                    children: [
                      Icon(
                        Icons.bookmark_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "Lamaran Yang Anda Simpan",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 3. SECTION REKOMENDASI (HEADER KONSISTEN)
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
                Text(
                  "${filteredJobs.length} Lowongan",
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // 4. DAFTAR KARTU REKOMENDASI (KONSISTEN DENGAN SISTEM KARTU BERANDA)
            if (filteredJobs.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.search_off_rounded,
                      size: 44,
                      color: Color(0xFF94A3B8),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Lowongan Tidak Ditemukan",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Coba cari dengan kata kunci lain seperti posisi atau nama pabrik.",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...filteredJobs.map((job) {
                final int jobId = job['id_post_pekerjaan'] ?? 1;
                final bool isSaved = _savedJobIds.contains(jobId);
                return _buildJobCard(job, isSaved);
              }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // BUILDER KARTU REKOMENDASI KONSISTEN DENGAN DESIGN SYSTEM BERANDA
  Widget _buildJobCard(Map<String, dynamic> job, bool isSaved) {
    final int idPerusahaan = job['id_perusahaan'] ?? 1;
    final companyMatch = dummyPerusahaan.firstWhere(
      (c) => c['id'] == idPerusahaan,
      orElse: () => {'nama': 'PT Industri'},
    );
    final String companyName = (companyMatch['namaPerusahaanAsli'] ??
            companyMatch['nama'] ??
            'PT Industri')
        .toString();

    final String posisi = (job['posisi'] ?? 'Operator Produksi').toString();
    final String lokasi = (job['lokasi'] ?? 'Cikarang').toString();
    final String tipe = (job['tipe'] ?? 'Penuh Waktu').toString();
    final String gaji = (job['gaji'] ?? 'Rp 5.2 - 6.5 Jt').toString();
    final int jobId = job['id_post_pekerjaan'] ?? 1;

    final String shortName = companyName
        .replaceAll('PT ', '')
        .replaceAll(' Tbk', '')
        .split(' ')
        .first
        .toUpperCase();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
        child: Stack(
          children: [
            // Ornamen Ombak Konsisten (Subtle Dark Maroon Alpha)
            Positioned(
              right: -10,
              bottom: -15,
              child: Opacity(
                opacity: 0.12,
                child: CustomPaint(
                  size: const Size(110, 90),
                  painter: _WavePatternPainter(
                    color: darkMaroon.withValues(alpha: 0.25),
                  ),
                ),
              ),
            ),

            // Konten Kartu
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Logo Box, Posisi & Nama Perusahaan, Tombol Bookmark
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Kotak Logo (Konsisten dengan Header Beranda)
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
                            shortName,
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

                      // Posisi & Perusahaan
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              posisi,
                              style: TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 15,
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

                      // Tombol Bookmark / Simpan (Amber jika tersimpan)
                      IconButton(
                        onPressed: () => _toggleSave(jobId),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isSaved
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color: isSaved
                              ? const Color(0xFFF59E0B)
                              : const Color(0xFF94A3B8),
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Row 2: Tag Tipe (Soft Maroon) & Tag Gaji (Soft Emerald)
                  Row(
                    children: [
                      // Tag Tipe (Soft Maroon Pill)
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

                      // Tag Gaji (Soft Emerald Financial Badge)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color(0xFF10B981)
                                .withValues(alpha: 0.35),
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

                  // Row 3: Lokasi & Tombol Lamar (Dark Maroon)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Lokasi
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

                      // Tombol Lamar (Dark Maroon Brand CTA)
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
}
