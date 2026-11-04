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

  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryColor = Color(0xFF7B1E2B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

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
              status == 'terbuka'
                  ? 'Pekerjaan berhasil dibuka.'
                  : 'Pekerjaan berhasil ditutup.',
            ),
            backgroundColor: const Color(0xFF15803D),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
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
        'Terjadi kesalahan saat mengubah status pekerjaan.',
        isError: true,
      );
    }
  }

  Future<void> _confirmChangeStatus(String status) async {
    final isOpening = status == 'terbuka';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            isOpening ? 'Buka Pekerjaan?' : 'Tutup Pekerjaan?',
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _textColor,
              fontFamily: 'Poppins',
            ),
          ),
          content: Text(
            isOpening
                ? 'Apakah kamu yakin ingin membuka kembali lowongan pekerjaan ini?'
                : 'Apakah kamu yakin ingin menutup lowongan pekerjaan ini?',
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _secondaryTextColor,
              fontFamily: 'Poppins',
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: _secondaryTextColor,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isOpening ? const Color(0xFF15803D) : _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                isOpening ? 'Ya, Buka' : 'Ya, Tutup',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
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
            fontFamily: 'Poppins',
            fontSize: 12,
          ),
        ),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF15803D),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  String _formatTanggal(dynamic createdAt) {
    if (createdAt == null || createdAt.toString().isEmpty) {
      return 'Tanggal tidak tersedia';
    }

    try {
      final date = DateTime.parse(createdAt.toString());

      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'Mei',
        'Jun',
        'Jul',
        'Agu',
        'Sep',
        'Okt',
        'Nov',
        'Des',
      ];

      return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Tanggal tidak tersedia';
    }
  }

  Widget _buildStatusBadge(String status) {
    final isOpen = status == 'terbuka';
    final color = isOpen ? const Color(0xFF15803D) : const Color(0xFFDC2626);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.09),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isOpen ? 'Terbuka' : 'Ditutup',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: _primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? 'Tidak tersedia' : value,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _textColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    final value = content.trim().isEmpty
        ? 'Belum ada informasi yang ditambahkan.'
        : content;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: _primaryColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: _borderColor, height: 1),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              height: 1.8,
              color: _secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 52,
      child: ElevatedButton.icon(
        onPressed: isChangingStatus ? null : onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Pekerjaan'),
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      body: const Center(
        child: CircularProgressIndicator(
          color: _primaryColor,
        ),
      ),
    );
  }

  Widget _buildEmptyView() {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Detail Pekerjaan'),
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.work_off_outlined,
                size: 65,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              const Text(
                'Pekerjaan tidak ditemukan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Detail pekerjaan ini tidak tersedia atau sudah dihapus.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: _secondaryTextColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return _buildLoadingView();

    if (selectedJob == null) return _buildEmptyView();

    final job = selectedJob!;
    final status = (job['status'] ?? 'ditutup').toString();
    final isOpen = status == 'terbuka';

    final posisi = (job['posisi'] ?? 'Posisi tidak tersedia').toString();
    final lokasi = (job['lokasi'] ?? 'Lokasi tidak tersedia').toString();
    final deskripsi = (job['job_details'] ?? '').toString();
    final persyaratan = (job['requirements'] ?? '').toString();
    final tanggal = _formatTanggal(job['createdAt']);

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Detail Pekerjaan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: _borderColor,
            height: 1,
          ),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _borderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _primaryColor.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.work_outline_rounded,
                              color: _primaryColor,
                              size: 25,
                            ),
                          ),
                          const Spacer(),
                          _buildStatusBadge(status),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        posisi,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 23,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: _secondaryTextColor,
                          ),
                          const SizedBox(width: 7),
                          Expanded(
                            child: Text(
                              lokasi,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                color: _secondaryTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 15,
                            color: _secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Diposting pada $tanggal',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11,
                              color: _secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _buildInfoCard(
                  icon: Icons.location_city_outlined,
                  title: 'Lokasi Pekerjaan',
                  value: lokasi,
                ),
                const SizedBox(height: 12),
                _buildInfoCard(
                  icon: Icons.event_outlined,
                  title: 'Tanggal Diposting',
                  value: tanggal,
                ),
                const SizedBox(height: 24),
                _buildDescriptionSection(
                  title: 'Deskripsi Pekerjaan',
                  content: deskripsi,
                  icon: Icons.description_outlined,
                ),
                const SizedBox(height: 16),
                _buildDescriptionSection(
                  title: 'Persyaratan',
                  content: persyaratan,
                  icon: Icons.fact_check_outlined,
                ),
                const SizedBox(height: 28),
                const Text(
                  'Kelola Lowongan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isOpen
                      ? 'Tutup lowongan jika proses penerimaan sudah selesai atau tidak lagi menerima pelamar.'
                      : 'Buka kembali lowongan agar pelamar dapat melihat dan melamar pekerjaan ini.',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    height: 1.6,
                    color: _secondaryTextColor,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: _buildActionButton(
                    label: isOpen ? 'Tutup Pekerjaan' : 'Buka Pekerjaan',
                    icon: isOpen
                        ? Icons.lock_outline_rounded
                        : Icons.lock_open_rounded,
                    color: isOpen ? _primaryColor : const Color(0xFF15803D),
                    onPressed: () {
                      _confirmChangeStatus(
                        isOpen ? 'ditutup' : 'terbuka',
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          if (isChangingStatus)
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
}
