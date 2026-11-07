import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rekanpabrik/api/melamar_pekerjaan_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/shared/shared.dart';
import 'package:url_launcher/url_launcher.dart';

class Detailpelamar extends StatefulWidget {
  final int id_lamaran_perusahaan;

  const Detailpelamar({
    super.key,
    required this.id_lamaran_perusahaan,
  });

  @override
  State<Detailpelamar> createState() => _DetailpelamarState();
}

class _DetailpelamarState extends State<Detailpelamar> {
  dynamic pelamar;

  bool isLoading = true;
  bool isUpdatingStatus = false;
  String? errorMessage;

  final String defaultFotoIMG = 'assets/img/defaultPict.png';

  @override
  void initState() {
    super.initState();
    fetchDetailPelamar(widget.id_lamaran_perusahaan);
  }

  Future<void> fetchDetailPelamar(int idLamaranPekerjaan) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data =
          await Postingpekerjaanapi().getDetailPelamar(idLamaranPekerjaan);

      if (!mounted) return;

      setState(() {
        pelamar = data;
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      debugPrint('Fetch detail pelamar error: $e');
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = 'Gagal memuat profil kandidat. Periksa koneksi Anda.';
      });
    }
  }

  ImageProvider _getProfileImage(String? path) {
    if (path == null || path.isEmpty) {
      return AssetImage(defaultFotoIMG);
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
    return AssetImage(defaultFotoIMG);
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null || dateStr.toString().isEmpty) return '-';
    try {
      final parsed = DateTime.parse(dateStr.toString());
      return DateFormat('d MMMM yyyy', 'id_ID').format(parsed);
    } catch (_) {
      return dateStr.toString();
    }
  }

  Future<void> _launchExternalUrl(String urlString, String fallbackError) async {
    if (urlString.trim().isEmpty) {
      _showSnackBar(fallbackError, isError: true);
      return;
    }

    try {
      final Uri uri = Uri.parse(urlString.trim());
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar(fallbackError, isError: true);
      }
    } catch (e) {
      debugPrint('Error launching url $urlString: $e');
      _showSnackBar(fallbackError, isError: true);
    }
  }

  Future<bool> _updateStatus(String status, int idLamaranPekerjaan) async {
    if (isUpdatingStatus) return false;

    setState(() {
      isUpdatingStatus = true;
    });

    try {
      final bool result = await MelamarPekerjaanapi()
          .ubahStatusPelamar(status, idLamaranPekerjaan);

      if (!mounted) return false;

      if (result) {
        setState(() {
          pelamar['status_lamaran'] = status;
          pelamar['status'] = status;
        });

        _showSnackBar(
          status == 'diterima'
              ? 'Kandidat pelamar berhasil diterima.'
              : 'Kandidat pelamar telah ditolak.',
        );

        return true;
      } else {
        _showSnackBar('Gagal memperbarui status lamaran.', isError: true);
        return false;
      }
    } catch (e) {
      debugPrint('Update status error: $e');
      if (!mounted) return false;
      _showSnackBar('Terjadi kesalahan saat memproses keputusan.', isError: true);
      return false;
    } finally {
      if (mounted) {
        setState(() {
          isUpdatingStatus = false;
        });
      }
    }
  }

  Future<void> _confirmUpdateStatus(String status) async {
    final bool isAccepted = status == 'diterima';

    final bool? confirmation = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                isAccepted
                    ? Icons.check_circle_outline_rounded
                    : Icons.cancel_outlined,
                color: isAccepted
                    ? const Color(0xFF047857)
                    : const Color(0xFFB91C1C),
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                isAccepted ? 'Terima Pelamar' : 'Tolak Pelamar',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: blackColor,
                ),
              ),
            ],
          ),
          content: Text(
            isAccepted
                ? 'Apakah Anda yakin ingin menerima kandidat ini untuk posisi yang dilamar?'
                : 'Apakah Anda yakin ingin menolak berkas lamaran dari kandidat ini?',
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isAccepted
                    ? const Color(0xFF047857)
                    : const Color(0xFFB91C1C),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 9,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(
                isAccepted ? 'Ya, Terima' : 'Ya, Tolak',
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmation != true || !mounted) return;

    final int? idLamaran = int.tryParse(
      pelamar?['id_lamaran_pekerjaan']?.toString() ?? '',
    );

    if (idLamaran == null) {
      _showSnackBar('ID lamaran tidak valid.', isError: true);
      return;
    }

    final bool success = await _updateStatus(status, idLamaran);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 12,
          ),
        ),
        backgroundColor: isError ? const Color(0xFFB91C1C) : darkMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
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
        title: Text(
          'Detail Pelamar',
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
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final String firstName = (pelamar?['first_name'] ?? '').toString();
    final String lastName = (pelamar?['last_name'] ?? '').toString();
    final String fullName = ('$firstName $lastName').trim().isNotEmpty
        ? ('$firstName $lastName').trim()
        : 'Kandidat Pelamar';
    final String posisi = (pelamar?['posisi_dilamar'] ??
            pelamar?['posisi'] ??
            'Operator Produksi')
        .toString();
    final String status = (pelamar?['status_lamaran'] ??
            pelamar?['status'] ??
            'diproses')
        .toString()
        .toLowerCase();
    final String email = (pelamar?['email'] ?? '').toString();
    final String phone =
        (pelamar?['nomor_telpon'] ?? pelamar?['no_hp'] ?? '081234567890')
            .toString();
    final String alamat =
        (pelamar?['alamat'] ?? 'Cikarang, Jawa Barat').toString();
    final String aboutMe = (pelamar?['about_me'] ??
            'Lulusan SMK/D3 dengan pengalaman kerja di industri manufaktur dan pemahaman SOP & K3 yang baik.')
        .toString();
    final String linkCv =
        (pelamar?['link_cv'] ?? pelamar?['curriculum_vitae'] ?? '').toString();
    final String dateApplied = _formatDate(pelamar?['createdAt']);

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        children: [
          _buildCandidateHeaderCard(
            fullName: fullName,
            posisi: posisi,
            status: status,
            dateApplied: dateApplied,
          ),

          const SizedBox(height: 24),

          _buildProfileDetailsSection(
            posisi: posisi,
            email: email,
            phone: phone,
            alamat: alamat,
            aboutMe: aboutMe,
          ),

          const SizedBox(height: 24),

          _buildCvDocumentCard(linkCv: linkCv),

          const SizedBox(height: 28),

          _buildDecisionSection(status: status),

          const SizedBox(height: 36),
        ],
      ),
    );
  }

  Widget _buildCandidateHeaderCard({
    required String fullName,
    required String posisi,
    required String status,
    required String dateApplied,
  }) {
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
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: darkMaroon.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: Image(
                image: _getProfileImage(pelamar?['profile_pict']?.toString()),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Image.asset(
                  defaultFotoIMG,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            fullName,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: blackColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            posisi,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: greyColor,
            ),
          ),
          if (dateApplied.isNotEmpty && dateApplied != '-') ...[
            const SizedBox(height: 4),
            Text(
              'Melamar pada $dateApplied',
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 11,
                color: Color(0xFF94A3B8),
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: statusTextColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  statusIcon,
                  size: 13,
                  color: statusTextColor,
                ),
                const SizedBox(width: 5),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsSection({
    required String posisi,
    required String email,
    required String phone,
    required String alamat,
    required String aboutMe,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informasi Kandidat',
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
              _buildDetailItem(
                label: 'Posisi yang Dilamar',
                value: posisi,
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDetailItem(
                label: 'Alamat Email',
                value: email.isNotEmpty ? email : '-',
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDetailItem(
                label: 'Nomor Telepon / WhatsApp',
                value: phone.isNotEmpty ? phone : '-',
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDetailItem(
                label: 'Domisili',
                value: alamat,
              ),
              const Divider(height: 24, color: Color(0xFFF1F5F9)),
              _buildDetailItem(
                label: 'Ringkasan Kualifikasi',
                value: aboutMe,
                isMultiLine: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
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
            value,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: blackColor,
              height: isMultiLine ? 1.5 : 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCvDocumentCard({required String linkCv}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Berkas Lamaran',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFCA5A5).withOpacity(0.4),
                  ),
                ),
                child: const Icon(
                  Icons.picture_as_pdf_rounded,
                  color: Color(0xFFB91C1C),
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Curriculum Vitae (CV)',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: blackColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Dokumen PDF • Resume kandidat',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  if (linkCv.isNotEmpty) {
                    _launchExternalUrl(
                      linkCv,
                      'Dokumen CV tidak dapat dibuka secara langsung.',
                    );
                  } else {
                    _showSnackBar(
                      'Dokumen CV kandidat belum diunggah.',
                      isError: true,
                    );
                  }
                },
                icon: const Icon(Icons.visibility_outlined, size: 15),
                label: const Text(
                  'Lihat CV',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: darkMaroon,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionSection({required String status}) {
    final bool isAlreadyDecided = status == 'diterima' || status == 'ditolak';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Keputusan Rekrutmen',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: blackColor,
          ),
        ),
        const SizedBox(height: 12),
        if (isAlreadyDecided)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: status == 'diterima'
                  ? const Color(0xFFECFDF5)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: status == 'diterima'
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  status == 'diterima'
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
                  color: status == 'diterima'
                      ? const Color(0xFF047857)
                      : const Color(0xFF64748B),
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status == 'diterima'
                            ? 'Pelamar Telah Diterima'
                            : 'Pelamar Telah Ditolak',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: status == 'diterima'
                              ? const Color(0xFF047857)
                              : blackColor,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        status == 'diterima'
                            ? 'Status penerimaan kandidat sudah ditetapkan. Anda dapat segera menghubungi kandidat untuk proses verifikasi berkas asli atau onboarding.'
                            : 'Status lamaran ini sudah ditandai ditolak.',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: status == 'diterima'
                              ? const Color(0xFF065F46)
                              : const Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isUpdatingStatus
                      ? null
                      : () => _confirmUpdateStatus('diterima'),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 17),
                  label: isUpdatingStatus
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Terima',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF047857),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isUpdatingStatus
                      ? null
                      : () => _confirmUpdateStatus('ditolak'),
                  icon: const Icon(Icons.cancel_outlined, size: 17),
                  label: const Text(
                    'Tolak',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFB91C1C),
                    side: const BorderSide(
                      color: Color(0xFFFCA5A5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
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
                Icons.person_off_outlined,
                size: 32,
                color: darkMaroon,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Profil',
              style: TextStyle(
                fontFamily: 'poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: blackColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              errorMessage ?? 'Terjadi kesalahan saat memuat data.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () =>
                  fetchDetailPelamar(widget.id_lamaran_perusahaan),
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
