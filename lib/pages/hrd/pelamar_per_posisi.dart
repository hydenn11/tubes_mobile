part of '../page.dart';

class PelamarPerPosisiPage extends StatefulWidget {
  final Map<String, dynamic> job;

  const PelamarPerPosisiPage({
    super.key,
    required this.job,
  });

  @override
  State<PelamarPerPosisiPage> createState() => _PelamarPerPosisiPageState();
}

class _PelamarPerPosisiPageState extends State<PelamarPerPosisiPage> {
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> allApplicantsForJob = [];
  List<Map<String, dynamic>> filteredApplicants = [];

  bool isLoading = true;
  String? errorMessage;
  String searchQuery = '';
  String selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchApplicants() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final int jobId = widget.job['id_post_pekerjaan'] ?? 1;
      final String jobTitle = (widget.job['posisi'] ?? '').toString();

      final data =
          await Postingpekerjaanapi().getPelamarByJob(jobId, jobTitle);

      if (!mounted) return;

      setState(() {
        allApplicantsForJob = List<Map<String, dynamic>>.from(data);
        _applyFilterAndSearch();
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('Error fetching applicants for job: $e');
      if (!mounted) return;
      setState(() {
        errorMessage = 'Tidak dapat memuat berkas pelamar. Periksa koneksi Anda.';
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
    List<Map<String, dynamic>> list = List.from(allApplicantsForJob);

    if (selectedFilter != 'Semua') {
      final filterLower = selectedFilter.toLowerCase();
      list = list.where((item) {
        final status = (item['status_lamaran'] ??
                item['status'] ??
                'diproses')
            .toString()
            .toLowerCase();
        return status == filterLower;
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final queryLower = searchQuery.toLowerCase();
      list = list.where((item) {
        final firstName =
            (item['first_name'] ?? '').toString().toLowerCase();
        final lastName =
            (item['last_name'] ?? '').toString().toLowerCase();
        final fullName = '$firstName $lastName'.trim();
        final email = (item['email'] ?? '').toString().toLowerCase();

        return fullName.contains(queryLower) ||
            firstName.contains(queryLower) ||
            lastName.contains(queryLower) ||
            email.contains(queryLower);
      }).toList();
    }

    setState(() {
      filteredApplicants = list;
    });
  }

  void _onSearchChanged(String val) {
    searchQuery = val.trim();
    _applyFilterAndSearch();
  }

  void _onFilterSelected(String filter) {
    setState(() {
      selectedFilter = filter;
    });
    _applyFilterAndSearch();
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

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '';
    try {
      final parsed = DateTime.parse(dateStr.toString());
      return DateFormat('d MMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return dateStr.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final String posisi = (widget.job['posisi'] ?? 'Posisi Pekerjaan').toString();
    final String lokasi = (widget.job['lokasi'] ?? 'Pabrik').toString();
    final String tipe = (widget.job['tipe'] ?? 'Penuh Waktu').toString();

    final int countTotal = allApplicantsForJob.length;
    final int countDiproses = allApplicantsForJob.where((a) {
      final s = (a['status_lamaran'] ?? a['status'] ?? 'diproses')
          .toString()
          .toLowerCase();
      return s == 'diproses';
    }).length;
    final int countDiterima = allApplicantsForJob.where((a) {
      final s = (a['status_lamaran'] ?? a['status'] ?? '')
          .toString()
          .toLowerCase();
      return s == 'diterima';
    }).length;
    final int countDitolak = allApplicantsForJob.where((a) {
      final s = (a['status_lamaran'] ?? a['status'] ?? '')
          .toString()
          .toLowerCase();
      return s == 'ditolak';
    }).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              posisi,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$lokasi • $tipe',
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
                  onRefresh: _fetchApplicants,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    children: [
                      _buildSearchBar(),

                      const SizedBox(height: 14),

                      _buildFilterChips(
                        countTotal: countTotal,
                        countDiproses: countDiproses,
                        countDiterima: countDiterima,
                        countDitolak: countDitolak,
                      ),

                      const SizedBox(height: 18),

                      _buildSummaryRow(),

                      const SizedBox(height: 12),

                      if (filteredApplicants.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredApplicants
                            .map((app) => _buildApplicantCard(app)),

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
        onChanged: _onSearchChanged,
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 13,
          color: blackColor,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama atau email pelamar...',
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

  Widget _buildFilterChips({
    required int countTotal,
    required int countDiproses,
    required int countDiterima,
    required int countDitolak,
  }) {
    final filters = [
      {'label': 'Semua', 'count': countTotal},
      {'label': 'Diproses', 'count': countDiproses},
      {'label': 'Diterima', 'count': countDiterima},
      {'label': 'Ditolak', 'count': countDitolak},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((f) {
          final String label = f['label'] as String;
          final int count = f['count'] as int;
          final bool isSelected = selectedFilter == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _onFilterSelected(label),
                borderRadius: BorderRadius.circular(20),
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
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
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
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Kandidat Pelamar (${filteredApplicants.length})',
        style: TextStyle(
          fontFamily: 'poppins',
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: blackColor,
        ),
      ),
    );
  }

  Widget _buildApplicantCard(Map<String, dynamic> app) {
    final int lamaranId = app['id_lamaran_pekerjaan'] ?? 1;
    final String firstName = (app['first_name'] ?? '').toString();
    final String lastName = (app['last_name'] ?? '').toString();
    final String fullName =
        ('$firstName $lastName').trim().isNotEmpty
            ? ('$firstName $lastName').trim()
            : 'Kandidat Pelamar';
    final String email = (app['email'] ?? '').toString();
    final String status = (app['status_lamaran'] ??
            app['status'] ??
            'diproses')
        .toString()
        .toLowerCase();
    final String? profilePict = app['profile_pict']?.toString();
    final String dateFormatted = _formatDate(app['createdAt']);

    Color statusBgColor = const Color(0xFFFFFBEB);
    Color statusTextColor = const Color(0xFFB45309);
    IconData statusIcon = Icons.access_time_rounded;
    String statusLabel = 'Diproses';

    if (status == 'diterima') {
      statusBgColor = const Color(0xFFECFDF5);
      statusTextColor = const Color(0xFF047857);
      statusIcon = Icons.check_circle_outline_rounded;
      statusLabel = 'Diterima';
    } else if (status == 'ditolak') {
      statusBgColor = const Color(0xFFFEF2F2);
      statusTextColor = const Color(0xFFB91C1C);
      statusIcon = Icons.cancel_outlined;
      statusLabel = 'Ditolak';
    }

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
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Detailpelamar(
                  id_lamaran_perusahaan: lamaranId,
                ),
              ),
            );

            if (result == true && mounted) {
              _fetchApplicants();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image(
                      image: _getAvatarImage(profilePict),
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
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
                        email.isNotEmpty ? email : 'Email tidak tersedia',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: greyColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (dateFormatted.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(
                          'Melamar: $dateFormatted',
                          style: const TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 10,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            statusIcon,
                            size: 11,
                            color: statusTextColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            statusLabel,
                            style: TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
    final bool isSearchQuery = searchQuery.isNotEmpty;
    final bool isFilteredStatus = selectedFilter != 'Semua';

    String title = 'Belum Ada Pelamar untuk Posisi Ini';
    String desc =
        'Belum ada kandidat yang mengirimkan berkas lamaran untuk lowongan ini.';

    if (isSearchQuery) {
      title = 'Kandidat Tidak Ditemukan';
      desc = 'Tidak ada pelamar dengan kata kunci pencarian "$searchQuery".';
    } else if (isFilteredStatus) {
      title = 'Tidak Ada Pelamar Status $selectedFilter';
      desc =
          'Belum ada kandidat dengan status $selectedFilter pada posisi ini.';
    }

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
              (isSearchQuery || isFilteredStatus)
                  ? Icons.search_off_rounded
                  : Icons.people_outline_rounded,
              color: const Color(0xFF64748B),
              size: 26,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            title,
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
            desc,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 11,
              color: greyColor,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          if (isFilteredStatus) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _onFilterSelected('Semua'),
              icon: const Icon(Icons.people_outline_rounded, size: 16),
              label: const Text(
                'Lihat Semua Pelamar',
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
          ] else if (isSearchQuery) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged('');
              },
              icon: const Icon(Icons.close_rounded, size: 16),
              label: const Text(
                'Hapus Pencarian',
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
              'Gagal Memuat Berkas',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Terjadi kesalahan.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: _fetchApplicants,
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

