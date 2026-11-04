part of '../page.dart';

class Posthistory extends StatefulWidget {
  const Posthistory({super.key});

  @override
  State<Posthistory> createState() => _PosthistoryState();
}

class _PosthistoryState extends State<Posthistory> {
  final meAPI meapi = meAPI();
  final Postingpekerjaanapi postpekerjaanapi = Postingpekerjaanapi();

  dynamic user;

  List<Map<String, dynamic>> resultsJob = [];

  String selectedFilter = 'Tanggal Terbaru';

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchPostPekerjaan();
  }

  Future<void> initUser() async {
    final response = await meapi.getUserProfile();

    if (response['status'] == true && response['data'] != null) {
      user = response['data'];
    } else {
      user = null;
    }
  }

  Future<void> _fetchPostPekerjaan() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      await initUser();

      if (!mounted) return;

      if (user == null || user.isEmpty) {
        Navigator.pushNamed(context, '/login');
        return;
      }

      final data = await postpekerjaanapi.getPostPekerjaan(
        user['id_perusahaan'],
      );

      if (!mounted) return;

      setState(() {
        resultsJob = List<Map<String, dynamic>>.from(data);
      });

      _sortResults();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Gagal memuat riwayat lowongan pekerjaan.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _sortResults() {
    final sortedResults = List<Map<String, dynamic>>.from(resultsJob);

    if (selectedFilter == 'Tanggal Terbaru') {
      sortedResults.sort((a, b) {
        final dateA = DateTime.tryParse(a['createdAt']?.toString() ?? '') ??
            DateTime(2000);
        final dateB = DateTime.tryParse(b['createdAt']?.toString() ?? '') ??
            DateTime(2000);

        return dateB.compareTo(dateA);
      });
    } else if (selectedFilter == 'Status Terbuka') {
      sortedResults.sort((a, b) {
        final statusA = a['status'] == 'terbuka' ? 0 : 1;
        final statusB = b['status'] == 'terbuka' ? 0 : 1;

        return statusA.compareTo(statusB);
      });
    } else if (selectedFilter == 'Status Berakhir') {
      sortedResults.sort((a, b) {
        final statusA = a['status'] == 'ditutup' ? 0 : 1;
        final statusB = b['status'] == 'ditutup' ? 0 : 1;

        return statusA.compareTo(statusB);
      });
    }

    if (!mounted) return;

    setState(() {
      resultsJob = sortedResults;
    });
  }

  void _onFilterChanged(String? newValue) {
    if (newValue == null) return;

    setState(() {
      selectedFilter = newValue;
    });

    _sortResults();
  }

  String _formatDate(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '');

    if (date == null) return '-';

    return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
  }

  String _formatStatus(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'terbuka':
        return 'Terbuka';
      case 'ditutup':
        return 'Berakhir';
      default:
        return status?.toString() ?? '-';
    }
  }

  Color _getStatusColor(dynamic status) {
    switch (status?.toString().toLowerCase()) {
      case 'terbuka':
        return Colors.green;
      case 'ditutup':
        return Colors.redAccent;
      default:
        return greyColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: true,
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: _fetchPostPekerjaan,
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
              _buildHistorySection(),
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
            Icons.history_rounded,
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
                'Riwayat Unggahan',
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
              'RIWAYAT REKRUTMEN',
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
            'Pantau Seluruh Lowongan Pekerjaan Anda',
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
            'Dengan RekanPabrik, Anda dapat melihat kembali '
            'seluruh lowongan pekerjaan yang pernah diposting. '
            'Tinjau informasi lowongan dan pantau status '
            'rekrutmen agar proses perekrutan tetap terorganisasi.',
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
                Icons.analytics_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Kelola riwayat rekrutmen dengan mudah',
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

  Widget _buildHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Lowongan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkMaroon,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Lihat dan kelola lowongan yang telah diposting.',
                    style: TextStyle(
                      fontSize: 12,
                      color: greyColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: darkMaroon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.work_history_outlined,
                color: darkMaroon,
                size: 22,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildFilterDropdown(),
        const SizedBox(height: 18),
        _buildJobList(),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list_rounded,
            color: darkMaroon,
            size: 21,
          ),
          const SizedBox(width: 10),
          Text(
            'Urutkan:',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: blackColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                isExpanded: true,
                items: [
                  'Tanggal Terbaru',
                  'Status Terbuka',
                  'Status Berakhir',
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 12,
                        color: blackColor,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  );
                }).toList(),
                onChanged: _onFilterChanged,
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: darkMaroon,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList() {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Center(
          child: CircularProgressIndicator(
            color: darkMaroon,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    if (resultsJob.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: resultsJob.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final job = resultsJob[index];

        return _buildJobCard(job);
      },
    );
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    final status = job['status'];

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailPekerjaanHRD(
              jobId: job['id_post_pekerjaan'],
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.025),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: darkMaroon.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.work_outline_rounded,
                color: darkMaroon,
                size: 23,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job['posisi']?.toString() ?? 'Tanpa Judul',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: blackColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: greyColor,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          job['lokasi']?.toString() ?? '-',
                          style: TextStyle(
                            fontSize: 11,
                            color: greyColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: greyColor,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _formatDate(job['createdAt']),
                          style: TextStyle(
                            fontSize: 11,
                            color: greyColor,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatStatus(status),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(status),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 5),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 15,
              color: greyColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 42,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: darkMaroon.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.work_off_outlined,
              color: darkMaroon,
              size: 35,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Belum Ada Lowongan',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Anda belum memposting pekerjaan. '
            'Silakan unggah lowongan pekerjaan untuk '
            'mulai menemukan kandidat yang sesuai.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.6,
              color: greyColor,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: greyColor,
            size: 45,
          ),
          const SizedBox(height: 15),
          Text(
            'Gagal Memuat Riwayat',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: darkMaroon,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: greyColor,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _fetchPostPekerjaan,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text(
              'Coba Lagi',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: darkMaroon,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
