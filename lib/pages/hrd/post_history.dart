part of '../page.dart';

class Posthistory extends StatefulWidget {
  const Posthistory({super.key});

  @override
  State<Posthistory> createState() => _PosthistoryState();
}

class _PosthistoryState extends State<Posthistory> {
  final meAPI meapi = meAPI();
  final Postingpekerjaanapi postpekerjaanapi = Postingpekerjaanapi();
  final TextEditingController _searchController = TextEditingController();

  dynamic user;
  List<Map<String, dynamic>> allJobs = [];
  List<Map<String, dynamic>> filteredJobs = [];

  String _searchQuery = '';
  String _selectedStatusFilter = 'Semua'; // 'Semua', 'Aktif', 'Ditutup'

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPostPekerjaan();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchPostPekerjaan() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await meapi.getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        user = response['data'];
      } else {
        user = null;
      }

      if (user == null || user.isEmpty) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      final int companyId = int.tryParse(user['id_perusahaan']?.toString() ?? '') ?? 1;

      final data = await postpekerjaanapi.getPostPekerjaan(companyId);

      if (!mounted) return;

      setState(() {
        allJobs = List<Map<String, dynamic>>.from(data);
        _applyFilterAndSearch();
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching job history: $e');
      if (!mounted) return;

      setState(() {
        errorMessage = 'Tidak dapat memuat riwayat lowongan pekerjaan.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _applyFilterAndSearch() {
    List<Map<String, dynamic>> list = List.from(allJobs);

    // Filter status
    if (_selectedStatusFilter == 'Aktif') {
      list = list.where((j) {
        final st = (j['status'] ?? '').toString().toLowerCase();
        return st == 'tersedia' || st == 'terbuka';
      }).toList();
    } else if (_selectedStatusFilter == 'Ditutup') {
      list = list.where((j) {
        final st = (j['status'] ?? '').toString().toLowerCase();
        return st == 'ditutup' || st == 'berakhir';
      }).toList();
    }

    // Filter pencarian
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((j) {
        final pos = (j['posisi'] ?? '').toString().toLowerCase();
        final loc = (j['lokasi'] ?? '').toString().toLowerCase();
        final tipe = (j['tipe'] ?? '').toString().toLowerCase();
        return pos.contains(q) || loc.contains(q) || tipe.contains(q);
      }).toList();
    }

    // Urutkan tanggal terbaru ke terlama
    list.sort((a, b) {
      final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ?? DateTime(2000);
      final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ?? DateTime(2000);
      return dateB.compareTo(dateA);
    });

    filteredJobs = list;
  }

  void _onStatusFilterSelected(String filter) {
    setState(() {
      _selectedStatusFilter = filter;
      _applyFilterAndSearch();
    });
  }

  int _getApplicantCountForJob(int jobId, String jobTitle) {
    final matchById = Postingpekerjaanapi.dummyPelamar
        .where((p) => p['id_post_pekerjaan'] == jobId)
        .length;
    if (matchById > 0) return matchById;

    final titleClean = jobTitle.trim().toLowerCase();
    return Postingpekerjaanapi.dummyPelamar.where((p) {
      final pos = (p['posisi_dilamar'] ?? p['posisi'] ?? '').toString().toLowerCase();
      return pos == titleClean || pos.contains(titleClean) || titleClean.contains(pos);
    }).length;
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');
    if (date == null) return '-';
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }

  bool _isJobActive(dynamic status) {
    final st = status?.toString().toLowerCase() ?? '';
    return st == 'tersedia' || st == 'terbuka';
  }

  @override
  Widget build(BuildContext context) {
    final int totalCount = allJobs.length;
    final int activeCount = allJobs.where((j) => _isJobActive(j['status'])).length;
    final int closedCount = allJobs.where((j) => !_isJobActive(j['status'])).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Kelola Lowongan',
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
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(color: darkMaroon),
            )
          : errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  color: darkMaroon,
                  onRefresh: _fetchPostPekerjaan,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 14),
                      _buildFilterChips(
                        totalCount: totalCount,
                        activeCount: activeCount,
                        closedCount: closedCount,
                      ),
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
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 13,
          color: blackColor,
        ),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
            _applyFilterAndSearch();
          });
        },
        decoration: InputDecoration(
          hintText: 'Cari nama posisi atau lokasi pabrik...',
          hintStyle: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF94A3B8),
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF94A3B8),
                    size: 18,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                      _applyFilterAndSearch();
                    });
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

  Widget _buildFilterChips({
    required int totalCount,
    required int activeCount,
    required int closedCount,
  }) {
    final List<Map<String, dynamic>> filters = [
      {'label': 'Semua', 'count': totalCount},
      {'label': 'Aktif', 'count': activeCount},
      {'label': 'Ditutup', 'count': closedCount},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final String label = f['label'] as String;
          final int count = f['count'] as int;
          final bool isSelected = _selectedStatusFilter == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onStatusFilterSelected(label),
                borderRadius: BorderRadius.circular(20),
                splashColor: darkMaroon.withOpacity(0.12),
                highlightColor: Colors.transparent,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? darkMaroon : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? darkMaroon : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: darkMaroon.withOpacity(0.18),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : blackColor,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withOpacity(0.2)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '$count',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Text(
      'Menampilkan ${filteredJobs.length} lowongan',
      style: const TextStyle(
        fontFamily: 'poppins',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final int jobId = job['id_post_pekerjaan'] ?? 1;
    final String posisi = (job['posisi'] ?? 'Lowongan Pekerjaan').toString();
    final String lokasi = (job['lokasi'] ?? 'Cikarang, Jawa Barat').toString();
    final String tipe = (job['tipe'] ?? 'Penuh Waktu').toString();
    final String dateFormatted = _formatDate(job['createdAt']);
    final bool isActive = _isJobActive(job['status']);
    final int applicantCount = _getApplicantCountForJob(jobId, posisi);

    final Color statusBg = isActive ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final Color statusColor = isActive ? const Color(0xFF047857) : const Color(0xFFB91C1C);
    final String statusText = isActive ? 'Aktif' : 'Ditutup';

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
                builder: (_) => DetailPekerjaanHRD(jobId: jobId),
              ),
            );
            _fetchPostPekerjaan();
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
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: statusColor.withOpacity(0.2)),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$applicantCount Pelamar',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: blackColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (dateFormatted != '-')
                      Text(
                        'Diterbitkan $dateFormatted',
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    const Spacer(),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: greyColor,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Text(
            _searchQuery.isNotEmpty
                ? 'Lowongan Tidak Ditemukan'
                : 'Belum Ada Lowongan',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Tidak ada lowongan yang sesuai dengan kata kunci "$_searchQuery".'
                : 'Perusahaan Anda belum memposting lowongan pekerjaan.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.5,
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
              'Gagal Memuat Riwayat',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Terjadi kendala jaringan saat memuat daftar lowongan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchPostPekerjaan,
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
