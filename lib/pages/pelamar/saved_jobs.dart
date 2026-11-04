part of '../page.dart';

class savedJobs extends StatefulWidget {
  const savedJobs({super.key});

  @override
  State<savedJobs> createState() => _savedJobsState();
}

class _savedJobsState extends State<savedJobs> {
  final SavedJobsApi _savedJobsApi = SavedJobsApi();
  final meAPI _meApi = meAPI();

  var _user;
  bool _isLoading = true;
  List<Map<String, dynamic>> _savedJobs = [];

  @override
  void initState() {
    super.initState();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userRes = await _meApi.getUserProfile();
      if (userRes['status'] == true && userRes['data'] != null) {
        _user = userRes['data'];
      }

      final int pelamarId = _user != null ? (_user['id_pelamar'] ?? 1) : 1;
      final rawList = await _savedJobsApi.getSavedJobsByIDPelamar(pelamarId);

      final List<Map<String, dynamic>> enriched = [];
      for (final raw in rawList) {
        final int jobId = raw['id_post_pekerjaan'] ?? 0;
        final matchedJob = dummyPostPekerjaan.firstWhere(
          (j) => j['id_post_pekerjaan'] == jobId,
          orElse: () => <String, dynamic>{},
        );

        String compName = "Pabrik Industri";
        if (matchedJob.isNotEmpty) {
          final int compId = matchedJob['id_perusahaan'] ?? 0;
          final matchedComp = dummyPerusahaan.firstWhere(
            (p) => p['id'] == compId,
            orElse: () => <String, dynamic>{},
          );
          if (matchedComp.isNotEmpty) {
            compName = matchedComp['namaPerusahaanAsli'] ??
                matchedComp['nama'] ??
                compName;
          }
        }

        final String posisi = (matchedJob.isNotEmpty && matchedJob['posisi'] != null)
            ? matchedJob['posisi']
            : (raw['posisi'] ?? 'Lowongan Manufaktur');
        final String lokasi = (matchedJob.isNotEmpty && matchedJob['lokasi'] != null)
            ? matchedJob['lokasi']
            : (raw['lokasi'] ?? 'Indonesia');

        enriched.add({
          'id_saved_jobs': raw['id_saved_jobs'],
          'id_post_pekerjaan': jobId,
          'posisi': posisi,
          'lokasi': lokasi,
          'company_name': compName,
          'tipe': matchedJob['tipe'] ?? 'Penuh Waktu',
          'gaji': matchedJob['gaji'] ?? 'Sesuai UMR',
          'bidang': matchedJob['bidang'] ?? 'Manufaktur & Pabrik',
          'job_details': (matchedJob.isNotEmpty && matchedJob['job_details'] != null)
              ? matchedJob['job_details']
              : (raw['job_details'] ?? ''),
          'requirements': (matchedJob.isNotEmpty && matchedJob['requirements'] != null)
              ? matchedJob['requirements']
              : (raw['requirements'] ?? ''),
          'status': (matchedJob.isNotEmpty && matchedJob['status'] != null)
              ? matchedJob['status']
              : (raw['status'] ?? 'tersedia'),
        });
      }

      if (mounted) {
        setState(() {
          _savedJobs = enriched;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading saved jobs: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeSavedJob(int jobId, String posisi) async {
    final int pelamarId = _user != null ? (_user['id_pelamar'] ?? 1) : 1;

    final removed = _savedJobs.firstWhere(
      (job) => job['id_post_pekerjaan'] == jobId,
      orElse: () => <String, dynamic>{},
    );

    setState(() {
      _savedJobs.removeWhere((job) => job['id_post_pekerjaan'] == jobId);
    });

    try {
      await _savedJobsApi.toggleSavedJobs(pelamarId, jobId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          content: Text(
            '"$posisi" dihapus dari pekerjaan tersimpan.',
            style: const TextStyle(fontFamily: 'poppins', fontSize: 13),
          ),
          action: SnackBarAction(
            label: "Batal",
            textColor: const Color(0xFFF59E0B),
            onPressed: () async {
              if (removed.isNotEmpty) {
                setState(() {
                  _savedJobs.add(removed);
                });
                await _savedJobsApi.toggleSavedJobs(pelamarId, jobId);
              }
            },
          ),
        ),
      );
    } catch (_) {
      if (removed.isNotEmpty && mounted) {
        setState(() {
          _savedJobs.add(removed);
        });
      }
    }
  }

  String _getCompanyShortName(String companyName) {
    return companyName
        .replaceAll('PT ', '')
        .replaceAll(' Tbk', '')
        .replaceAll('(Persero)', '')
        .split(' ')
        .first
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
          "Pekerjaan Tersimpan",
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: blackColor,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(color: darkMaroon),
              )
            : _savedJobs.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 14),
                    itemCount: _savedJobs.length,
                    itemBuilder: (context, index) {
                      return _buildSavedJobCard(_savedJobs[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Belum Ada Pekerjaan Tersimpan",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Simpan peluang kerja yang menarik perhatian Anda untuk ditinjau dan dilamar nanti.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: const Text(
                  "Jelajahi Lowongan",
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedJobCard(Map<String, dynamic> job) {
    final int jobId = job['id_post_pekerjaan'] ?? 0;
    final String posisi = job['posisi'] ?? 'Lowongan Pabrik';
    final String companyName = job['company_name'] ?? 'Pabrik Industri';
    final String lokasi = job['lokasi'] ?? 'Indonesia';
    final String tipe = job['tipe'] ?? 'Penuh Waktu';
    final String gaji = job['gaji'] ?? 'Sesuai UMR';
    final String shortName = _getCompanyShortName(companyName);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => detailPekerjaan(jobId: jobId),
              ),
            ).then((_) {
              _loadSavedJobs();
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 60,
                      height: 48,
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
                            fontWeight: FontWeight.w800,
                            color: darkMaroon,
                          ),
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
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: blackColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            companyName,
                            style: const TextStyle(
                              fontFamily: 'poppins',
                              fontSize: 12,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      tooltip: "Hapus dari simpanan",
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.bookmark_rounded,
                        color: Color(0xFFF59E0B),
                        size: 24,
                      ),
                      onPressed: () => _removeSavedJob(jobId, posisi),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: darkMaroon.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tipe,
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: darkMaroon,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        "Gaji $gaji",
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF047857),
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
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        lokasi,
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      "Lihat Detail",
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: darkMaroon,
                      ),
                    ),
                    const SizedBox(width: 2),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 11,
                      color: darkMaroon,
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
}
