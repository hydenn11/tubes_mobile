import 'package:flutter/material.dart';
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

  final String defaultFotoIMG = 'assets/img/defaultPict.png';

  static const Color darkMaroon = Color(0xFF5B1720);
  static const Color maroon = Color(0xFF7A2633);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textColor = Color(0xFF1E293B);
  static const Color secondaryColor = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    fetchDetailPelamar(widget.id_lamaran_perusahaan);
  }

  Future<void> fetchDetailPelamar(int idLamaranPekerjaan) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final data = await Postingpekerjaanapi()
          .getDetailPelamar(idLamaranPekerjaan);

      if (!mounted) return;

      setState(() {
        pelamar = data;
        isLoading = false;
      });

      debugPrint('DETAIL PELAMAR: $data');
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showSnackBar(
        'Terjadi kesalahan saat mengambil data pelamar.',
        isError: true,
      );

      debugPrint('Fetch detail pelamar error: $e');
    }
  }

  ImageProvider _getProfileImage() {
    final String? imagePath =
        pelamar?['profile_pict']?.toString();

    if (imagePath == null || imagePath.isEmpty) {
      return AssetImage(defaultFotoIMG);
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }

    return AssetImage(defaultFotoIMG);
  }

  Widget _buildProfileImage() {
    return Container(
      width: 124,
      height: 124,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFF0DDE0),
          width: 2,
        ),
      ),
      child: ClipOval(
        child: Image(
          image: _getProfileImage(),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              defaultFotoIMG,
              fit: BoxFit.cover,
            );
          },
        ),
      ),
    );
  }

  Color statusColors(String? status) {
    switch (status?.toLowerCase()) {
      case 'diproses':
        return const Color(0xFF64748B);

      case 'ditolak':
        return const Color(0xFFDC2626);

      case 'diterima':
        return const Color(0xFF16A34A);

      default:
        return const Color(0xFF2563EB);
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'diproses':
        return Icons.hourglass_top_rounded;

      case 'ditolak':
        return Icons.cancel_rounded;

      case 'diterima':
        return Icons.check_circle_rounded;

      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildStatusBadge() {
    final String status =
        pelamar?['status']?.toString() ?? 'Belum Diproses';

    final Color color = statusColors(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: color.withOpacity(0.25),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(status),
            size: 16,
            color: color,
          ),
          const SizedBox(width: 7),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> updateStatus(
    String status,
    int idLamaranPekerjaan,
  ) async {
    if (isUpdatingStatus) return false;

    setState(() {
      isUpdatingStatus = true;
    });

    try {
      final bool result = await MelamarPekerjaanapi()
          .ubahStatusPelamar(status, idLamaranPekerjaan);

      if (!mounted) return false;

      if (result) {
        _showSnackBar(
          status == 'diterima'
              ? 'Pelamar berhasil diterima.'
              : 'Pelamar berhasil ditolak.',
        );

        return true;
      } else {
        _showSnackBar(
          'Gagal memperbarui status lamaran.',
          isError: true,
        );

        return false;
      }
    } catch (e) {
      if (!mounted) return false;

      debugPrint('Update status error: $e');

      _showSnackBar(
        'Terjadi kesalahan saat memperbarui status.',
        isError: true,
      );

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
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                isAccepted
                    ? Icons.check_circle_outline_rounded
                    : Icons.warning_amber_rounded,
                color: isAccepted
                    ? Colors.green
                    : Colors.red,
                size: 25,
              ),
              const SizedBox(width: 10),
              const Text(
                'Konfirmasi',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w700,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Text(
            isAccepted
                ? 'Apakah Anda yakin ingin menerima pelamar ini?'
                : 'Apakah Anda yakin ingin menolak pelamar ini?',
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: secondaryColor,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: secondaryColor,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isAccepted ? Colors.green : Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(
                isAccepted ? 'Terima' : 'Tolak',
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontWeight: FontWeight.w600,
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
      _showSnackBar(
        'ID lamaran tidak valid.',
        isError: true,
      );
      return;
    }

    final bool success = await updateStatus(status, idLamaran);

    if (success && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _launchCV(String? cvUrl) async {
    if (cvUrl == null || cvUrl.trim().isEmpty) {
      _showSnackBar(
        'CV pelamar tidak tersedia.',
        isError: true,
      );
      return;
    }

    try {
      final Uri uri = Uri.parse(cvUrl.trim());

      if (!uri.hasScheme ||
          (uri.scheme != 'http' && uri.scheme != 'https') ||
          uri.host.isEmpty) {
        _showSnackBar(
          'Alamat CV tidak valid.',
          isError: true,
        );
        return;
      }

      final bool launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && mounted) {
        _showSnackBar(
          'Tidak dapat membuka CV.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        'Terjadi kesalahan saat membuka CV.',
        isError: true,
      );
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
            fontSize: 12,
          ),
        ),
        backgroundColor: isError
            ? Colors.red.shade700
            : darkMaroon,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildInformationField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF5E8EA),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              size: 19,
              color: darkMaroon,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                    color: secondaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value.isEmpty ? '-' : value,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final String status =
        pelamar?['status']?.toString().toLowerCase() ?? '';

    if (status == 'diterima' || status == 'ditolak') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: secondaryColor,
              size: 20,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Status lamaran ini sudah ditetapkan dan tidak dapat diproses kembali melalui halaman ini.',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                  color: secondaryColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: isUpdatingStatus
                ? null
                : () => _confirmUpdateStatus('diterima'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF16A34A),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: isUpdatingStatus
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_outline_rounded,
                        size: 19,
                      ),
                      SizedBox(width: 9),
                      Text(
                        'Terima Pelamar',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: isUpdatingStatus
                ? null
                : () => _confirmUpdateStatus('ditolak'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(
                color: Colors.red.shade300,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cancel_outlined,
                  size: 19,
                ),
                SizedBox(width: 9),
                Text(
                  'Tolak Pelamar',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Detail Pelamar',
          style: TextStyle(
            fontFamily: 'poppins',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        iconTheme: const IconThemeData(
          color: textColor,
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: darkMaroon,
              ),
            )
          : pelamar == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_search_rounded,
                          size: 55,
                          color: secondaryColor,
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Data pelamar tidak ditemukan.',
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 13,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => fetchDetailPelamar(
                            widget.id_lamaran_perusahaan,
                          ),
                          child: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      30,
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: borderColor,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.025),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildProfileImage(),
                            const SizedBox(height: 15),
                            Text(
                              '${pelamar['first_name'] ?? ''} ${pelamar['last_name'] ?? ''}'
                                  .trim(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'poppins',
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildStatusBadge(),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        'Informasi Pelamar',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Informasi mengenai pelamar dan posisi pekerjaan.',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: secondaryColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildInformationField(
                        label: 'First Name',
                        value:
                            pelamar['first_name']?.toString() ?? '-',
                        icon: Icons.person_outline_rounded,
                      ),

                      const SizedBox(height: 12),

                      _buildInformationField(
                        label: 'Last Name',
                        value:
                            pelamar['last_name']?.toString() ?? '-',
                        icon: Icons.person_outline_rounded,
                      ),

                      const SizedBox(height: 12),

                      _buildInformationField(
                        label: 'Posisi yang Dilamar',
                        value: pelamar['posisi']?.toString() ?? '-',
                        icon: Icons.work_outline_rounded,
                      ),

                      const SizedBox(height: 22),

                      Container(
                        padding: const EdgeInsets.all(17),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: borderColor,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 43,
                              height: 43,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF5E8EA),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: darkMaroon,
                                size: 23,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Curriculum Vitae',
                                    style: TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: textColor,
                                    ),
                                  ),
                                  SizedBox(height: 3),
                                  Text(
                                    'Lihat dokumen CV pelamar',
                                    style: TextStyle(
                                      fontFamily: 'poppins',
                                      fontSize: 10,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _launchCV(
                                pelamar['curriculum_vitae']?.toString(),
                              ),
                              icon: const Icon(
                                Icons.download_rounded,
                                color: darkMaroon,
                              ),
                              tooltip: 'Download CV',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'Keputusan Lamaran',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Tentukan keputusan terhadap lamaran pekerjaan ini.',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 11,
                          color: secondaryColor,
                        ),
                      ),

                      const SizedBox(height: 16),

                      _buildActionButtons(),
                    ],
                  ),
                ),
    );
  }
}
