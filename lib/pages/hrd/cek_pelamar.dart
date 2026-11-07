part of '../page.dart';

class Cekpelamar extends StatefulWidget {
  const Cekpelamar({super.key});

  @override
  State<Cekpelamar> createState() => _CekpelamarState();
}

class _CekpelamarState extends State<Cekpelamar> {
  final TextEditingController _searchController = TextEditingController();

  dynamic user;
  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> allApplicants = [];
  List<Map<String, dynamic>> filteredJobs = [];

  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final userResponse = await meAPI().getUserProfile();

      if (!mounted) return;

      if (userResponse['status'] == true && userResponse['data'] != null) {
        user = userResponse['data'];
        final int companyId = user['id_perusahaan'] ?? 1;

        final jobsFuture = Postingpekerjaanapi().getPostPekerjaan(companyId);
        final appsFuture =
            Postingpekerjaanapi().getPelamarByCompanyId(companyId);

        final results = await Future.wait([jobsFuture, appsFuture]);

        if (!mounted) return;

        setState(() {
          allJobs = List<Map<String, dynamic>>.from(results[0]);
          allApplicants = List<Map<String, dynamic>>.from(results[1]);
          _applyFilterAndSearch();
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              userResponse['message'] ?? 'Gagal memuat profil perusahaan.';
        });
      }
    } catch (e) {
      debugPrint('Error loading Cekpelamar data: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  int _getApplicantCountForJob(Map<String, dynamic> job) {
    final int jobId = job['id_post_pekerjaan'] ?? -1;
    final String jobTitle =
        (job['posisi'] ?? '').toString().trim().toLowerCase();

    return allApplicants.where((app) {
      final int appJobId = app['id_post_pekerjaan'] ?? -2;
      if (appJobId == jobId) return true;

      final String appPos = (app['posisi_dilamar'] ?? app['posisi'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      return appPos == jobTitle ||
          appPos.contains(jobTitle) ||
          jobTitle.contains(appPos);
    }).length;
  }

  int _getPendingCountForJob(Map<String, dynamic> job) {
    final int jobId = job['id_post_pekerjaan'] ?? -1;
    final String jobTitle =
        (job['posisi'] ?? '').toString().trim().toLowerCase();

    return allApplicants.where((app) {
      final String status =
          (app['status_lamaran'] ?? app['status'] ?? 'diproses')
              .toString()
              .toLowerCase();
      if (status != 'diproses') return false;

      final int appJobId = app['id_post_pekerjaan'] ?? -2;
      if (appJobId == jobId) return true;

      final String appPos = (app['posisi_dilamar'] ?? app['posisi'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      return appPos == jobTitle ||
          appPos.contains(jobTitle) ||
          jobTitle.contains(appPos);
    }).length;
  }

  void _applyFilterAndSearch() {
    List<Map<String, dynamic>> list = List.from(allJobs);

    if (searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      list = list.where((job) {
        final pos = (job['posisi'] ?? '').toString().toLowerCase();
        final loc = (job['lokasi'] ?? '').toString().toLowerCase();
        final type = (job['tipe'] ?? '').toString().toLowerCase();
        return pos.contains(queryLower) ||
            loc.contains(queryLower) ||
            type.contains(queryLower);
      }).toList();
    }

    setState(() {
      filteredJobs = list;
    });
  }

  void _onSearchChanged(String val) {
    searchQuery = val.trim();
    _applyFilterAndSearch();
  }

  void _resetSearch() {
    _searchController.clear();
    searchQuery = '';
    _applyFilterAndSearch();
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

    if (errorMessage != null) {
      return _buildErrorState();
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: _fetchData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            children: [
              _buildHeader(),

              const SizedBox(height: 18),

              _buildSearchBar(),

              const SizedBox(height: 18),

              _buildSummaryRow(),

              const SizedBox(height: 12),

              if (filteredJobs.isEmpty)
                _buildEmptyState()
              else
                ...filteredJobs.map((job) => _buildJobCard(job)),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pelamar per Posisi',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: blackColor,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pilih posisi lowongan untuk meninjau dan mengelola kandidat pelamarnya.',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            color: greyColor,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 13,
          color: blackColor,
        ),
        decoration: InputDecoration(
          hintText: 'Cari posisi lowongan atau lokasi...',
          hintStyle: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF64748B),
            size: 20,
          ),
          suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF64748B),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Daftar Posisi (${filteredJobs.length})',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        if (searchQuery.isNotEmpty)
          GestureDetector(
            onTap: _resetSearch,
            child: Text(
              'Reset Pencarian',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: darkMaroon,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final String posisi =
        (job['posisi'] ?? 'Operator Produksi').toString();
    final String lokasi = (job['lokasi'] ?? 'Cikarang').toString();
    final String tipe = (job['tipe'] ?? 'Penuh Waktu').toString();

    final int applicantCount = _getApplicantCountForJob(job);
    final int pendingCount = _getPendingCountForJob(job);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PelamarPerPosisiPage(job: job),
              ),
            );

            if (mounted) {
              _fetchData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            posisi,
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$lokasi • $tipe',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11.5,
                              color: greyColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: greyColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Container(
                  height: 1,
                  color: const Color(0xFFF1F5F9),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.people_alt_outlined,
                            size: 12,
                            color: blackColor,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '$applicantCount Pelamar',
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    if (pendingCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFFFDE68A),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.pending_actions_rounded,
                              size: 12,
                              color: Color(0xFFB45309),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$pendingCount Perlu Ditinjau',
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFB45309),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Semua sudah ditinjau',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 11,
                            color: greyColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final bool isSearching = searchQuery.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isSearching
                  ? Icons.search_off_rounded
                  : Icons.work_off_outlined,
              color: const Color(0xFF64748B),
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            isSearching
                ? 'Posisi Tidak Ditemukan'
                : 'Belum Ada Lowongan Pekerjaan',
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
            isSearching
                ? 'Tidak ada posisi lowongan yang cocok dengan kata kunci pencarian Anda.'
                : 'Pasang lowongan pekerjaan baru untuk mulai menerima berkas pelamar.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: greyColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (isSearching) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _resetSearch,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'Reset Pencarian',
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
                  horizontal: 18,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: darkMaroon.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 32,
                color: darkMaroon,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Koneksi Terputus',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Gagal memuat lowongan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
