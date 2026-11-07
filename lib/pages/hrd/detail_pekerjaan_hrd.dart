part of '../page.dart';

class DetailPekerjaanHRD extends StatefulWidget {
  final int jobId;

  const DetailPekerjaanHRD({
    Key? key,
    required this.jobId,
  }) : super(key: key);

  @override
  State<DetailPekerjaanHRD> createState() => _DetailPekerjaanHRDState();
}

class _DetailPekerjaanHRDState extends State<DetailPekerjaanHRD> {
  final Postingpekerjaanapi postingpekerjaanapi = Postingpekerjaanapi();

  Map<String, dynamic>? selectedJob;
  bool isLoading = true;
  bool isChangingStatus = false;
  bool isDeleting = false;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    try {
      final jobDetails = await postingpekerjaanapi.detailsJob(widget.jobId);

      if (!mounted) return;

      setState(() {
        selectedJob = jobDetails.isNotEmpty ? jobDetails.first : null;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading job details: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar(
        'Gagal memuat detail pekerjaan.',
        isError: true,
      );
    }
  }

  Future<void> _changeJobStatus(String status) async {
    if (selectedJob == null || isChangingStatus) return;

    final idPostPekerjaan =
        int.tryParse(selectedJob!['id_post_pekerjaan'].toString());

    if (idPostPekerjaan == null) {
      _showSnackBar(
        'ID pekerjaan tidak valid.',
        isError: true,
      );
      return;
    }

    setState(() {
      isChangingStatus = true;
    });

    try {
      final result = await postingpekerjaanapi.ubahStatusPekerjaann(
        idPostPekerjaan,
        status,
      );

      if (!mounted) return;

      if (result) {
        setState(() {
          selectedJob!['status'] = status;
          isChangingStatus = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              status == 'terbuka' || status == 'tersedia'
                  ? 'Lowongan berhasil dibuka kembali.'
                  : 'Lowongan pekerjaan berhasil ditutup.',
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12.5,
              ),
            ),
            backgroundColor: const Color(0xFF047857),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          isChangingStatus = false;
        });

        _showSnackBar(
          'Gagal mengubah status pekerjaan.',
          isError: true,
        );
      }
    } catch (e) {
      debugPrint('Error changing job status: $e');

      if (!mounted) return;

      setState(() {
        isChangingStatus = false;
      });

      _showSnackBar(
        'Terjadi gangguan saat mengubah status pekerjaan.',
        isError: true,
      );
    }
  }

  Future<void> _confirmChangeStatus(String status) async {
    final isOpening = status == 'terbuka' || status == 'tersedia';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            isOpening ? 'Buka Kembali Lowongan?' : 'Tutup Lowongan?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontFamily: 'poppins',
            ),
          ),
          content: Text(
            isOpening
                ? 'Kandidat pelamar akan dapat kembali melihat dan mengajukan berkas untuk posisi ini.'
                : 'Penerimaan berkas pelamar baru akan dinonaktifkan untuk posisi pekerjaan ini.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF475569),
              fontFamily: 'poppins',
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isOpening ? const Color(0xFF047857) : darkMaroon,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Text(
                isOpening ? 'Ya, Buka' : 'Ya, Tutup',
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _changeJobStatus(status);
    }
  }

  Future<void> _deleteJob() async {
    if (selectedJob == null || isDeleting) return;

    final idPostPekerjaan =
        int.tryParse(selectedJob!['id_post_pekerjaan'].toString());

    if (idPostPekerjaan == null) {
      _showSnackBar('ID pekerjaan tidak valid.', isError: true);
      return;
    }

    setState(() {
      isDeleting = true;
    });

    try {
      final result =
          await postingpekerjaanapi.hapusPekerjaan(idPostPekerjaan);

      if (!mounted) return;

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Lowongan pekerjaan berhasil dihapus.',
              style: TextStyle(fontFamily: 'poppins', fontSize: 12.5),
            ),
            backgroundColor: const Color(0xFF047857),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );

        Navigator.pop(context, true);
      } else {
        setState(() {
          isDeleting = false;
        });
        _showSnackBar('Gagal menghapus lowongan pekerjaan.', isError: true);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isDeleting = false;
      });
      _showSnackBar('Terjadi gangguan saat memproses penghapusan.', isError: true);
    }
  }

  Future<void> _confirmDeleteJob() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Hapus Lowongan?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: blackColor,
              fontFamily: 'poppins',
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin menghapus lowongan ini? Seluruh data lowongan akan terhapus dan tidak dapat dipulihkan.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF475569),
              fontFamily: 'poppins',
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                  fontFamily: 'poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                'Ya, Hapus',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'poppins',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true && mounted) {
      await _deleteJob();
    }
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
  }) {
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
        backgroundColor:
            isError ? const Color(0xFFB91C1C) : const Color(0xFF047857),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  String _formatTanggal(dynamic createdAt) {
    if (createdAt == null || createdAt.toString().isEmpty) {
      return '-';
    }

    try {
      final date = DateTime.parse(createdAt.toString());
      return DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingView();
    if (selectedJob == null) return _buildEmptyView();

    final job = selectedJob!;
    final status = (job['status'] ?? 'ditutup').toString();
    final bool isOpen = status == 'terbuka' || status == 'tersedia';

    final posisi = (job['posisi'] ?? 'Posisi Pekerjaan').toString();
    final lokasi = (job['lokasi'] ?? 'Cikarang, Jawa Barat').toString();
    final tipe = (job['tipe'] ?? 'Penuh Waktu').toString();
    final gaji = (job['gaji'] ?? 'Sesuai Kebijakan Perusahaan').toString();
    final bidang = (job['bidang'] ?? 'Manufaktur & Pabrik').toString();
    final deskripsi = (job['job_details'] ?? '').toString();
    final persyaratan = (job['requirements'] ?? '').toString();
    final tanggal = _formatTanggal(job['createdAt']);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Pekerjaan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE2E8F0),
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              _buildHeaderCard(
                posisi: posisi,
                bidang: bidang,
                lokasi: lokasi,
                tipe: tipe,
                tanggal: tanggal,
                isOpen: isOpen,
              ),

              const SizedBox(height: 20),

              _buildSpecificationSection(
                lokasi: lokasi,
                tipe: tipe,
                gaji: gaji,
                bidang: bidang,
                tanggal: tanggal,
                isOpen: isOpen,
              ),

              const SizedBox(height: 20),

              _buildTextSection(
                title: 'Deskripsi & Tanggung Jawab',
                content: deskripsi,
              ),

              const SizedBox(height: 20),

              _buildTextSection(
                title: 'Persyaratan & Kualifikasi',
                content: persyaratan,
              ),

              const SizedBox(height: 28),

              _buildManagementSection(isOpen: isOpen),

              const SizedBox(height: 36),
            ],
          ),
          if (isChangingStatus || isDeleting)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.35),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeaderCard({
    required String posisi,
    required String bidang,
    required String lokasi,
    required String tipe,
    required String tanggal,
    required bool isOpen,
  }) {
    final Color statusBg = isOpen ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2);
    final Color statusColor = isOpen ? const Color(0xFF047857) : const Color(0xFFB91C1C);
    final String statusText = isOpen ? 'Aktif' : 'Ditutup';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
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
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  tipe,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: blackColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            posisi,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: blackColor,
              letterSpacing: -0.3,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$lokasi • $bidang',
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              color: Color(0xFF64748B),
            ),
          ),
          if (tanggal != '-') ...[
            const SizedBox(height: 4),
            Text(
              'Diterbitkan pada $tanggal',
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSpecificationSection({
    required String lokasi,
    required String tipe,
    required String gaji,
    required String bidang,
    required String tanggal,
    required bool isOpen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Spesifikasi Lowongan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSpecItem(
                label: 'LOKASI PENEMPATAN',
                value: lokasi,
              ),
              const Divider(height: 22, color: Color(0xFFF1F5F9)),
              _buildSpecItem(
                label: 'TIPE PEKERJAAN',
                value: tipe,
              ),
              const Divider(height: 22, color: Color(0xFFF1F5F9)),
              _buildSpecItem(
                label: 'BIDANG INDUSTRI',
                value: bidang,
              ),
              const Divider(height: 22, color: Color(0xFFF1F5F9)),
              _buildSpecItem(
                label: 'ESTIMASI GAJI',
                value: gaji,
              ),
              const Divider(height: 22, color: Color(0xFFF1F5F9)),
              _buildSpecItem(
                label: 'STATUS PENERIMAAN',
                value: isOpen ? 'Aktif (Menerima Pendaftaran)' : 'Ditutup (Penerimaan Berakhir)',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecItem({
    required String label,
    required String value,
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
        const SizedBox(height: 4),
        Text(
          value.isEmpty ? '-' : value,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: blackColor,
            height: 1.25,
          ),
        ),
      ],
    );
  }

  Widget _buildTextSection({
    required String title,
    required String content,
  }) {
    final String text = content.trim().isEmpty ? 'Tidak ada rincian yang ditambahkan.' : content.trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              height: 1.6,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildManagementSection({required bool isOpen}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kelola Status Lowongan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          isOpen
              ? 'Tutup lowongan ini bila kuota pelamar telah terpenuhi, atau hapus jika dibatalkan.'
              : 'Buka kembali lowongan agar kandidat dapat melamar, atau hapus jika tidak lagi digunakan.',
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 48,
                child: OutlinedButton(
                  onPressed: isDeleting || isChangingStatus ? null : _confirmDeleteJob,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: const Color(0xFFB91C1C).withOpacity(0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: isChangingStatus || isDeleting
                      ? null
                      : () {
                          _confirmChangeStatus(isOpen ? 'ditutup' : 'terbuka');
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isOpen ? darkMaroon : const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: (isOpen ? darkMaroon : const Color(0xFF047857))
                        .withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isOpen ? 'Tutup Lowongan' : 'Buka Lowongan',
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Pekerjaan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
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
      ),
      body: Center(
        child: CircularProgressIndicator(color: darkMaroon),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Detail Pekerjaan',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Lowongan Tidak Ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Detail lowongan pekerjaan ini sudah dihapus atau tidak tersedia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 12,
                  color: Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
