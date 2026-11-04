import 'package:flutter/material.dart';
import 'package:rekanpabrik/api/me_api.dart';
import 'package:rekanpabrik/api/posting_pekerjaan_api.dart';
import 'package:rekanpabrik/models/data_pelamar_pekerjaan.dart';
import 'package:rekanpabrik/pages/hrd/detail_pelamar.dart';
import 'package:rekanpabrik/shared/shared.dart';

class SearchBarPelamarPekerjaan extends StatefulWidget {
  const SearchBarPelamarPekerjaan({super.key});

  @override
  State<SearchBarPelamarPekerjaan> createState() =>
      _SearchBarPelamarPekerjaanState();
}

class _SearchBarPelamarPekerjaanState extends State<SearchBarPelamarPekerjaan> {
  final TextEditingController searchController = TextEditingController();

  String query = '';
  List<pelamarPekerjaan> dataDitampilkan = [];
  List<Map<String, dynamic>> resultsPelamar = [];
  dynamic user;

  bool _isLoading = true;
  String _errorMessage = '';

  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryColor = Color(0xFF7B1E2B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await meAPI().getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        user = response['data'];
        await _fetchPelamar();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Anda belum login. Silakan login kembali.';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat mengambil profil.';
      });
    }
  }

  Future<void> _fetchPelamar() async {
    try {
      final dynamic companyId = user?['id_perusahaan'];

      if (companyId == null) {
        if (!mounted) return;

        setState(() {
          _isLoading = false;
          _errorMessage = 'ID perusahaan tidak ditemukan.';
        });
        return;
      }

      final data = await Postingpekerjaanapi().getPelamarByCompanyId(companyId);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        resultsPelamar = data;

        if (data.isEmpty) {
          _errorMessage = '';
          dataDitampilkan = [];
        } else {
          _errorMessage = '';
          dataDitampilkan = _mapPelamar(data.take(5).toList());
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Terjadi kesalahan saat mengambil data pelamar.';
      });
    }
  }

  List<pelamarPekerjaan> _mapPelamar(
    List<Map<String, dynamic>> data,
  ) {
    return data.map((item) {
      return pelamarPekerjaan(
        namaPerusahaan: item['nama_perusahaan']?.toString() ?? '',
        idPelamar: item['id_pelamar'],
        firstName: item['first_name']?.toString() ?? '',
        lastName: item['last_name']?.toString() ?? '',
        email: item['email']?.toString() ?? '',
        linkCv: item['curriculum_vitae']?.toString() ?? '',
        fotoProfil: item['profile_pict']?.toString() ?? '',
        id_lamaran_pekerjaan: item['id_lamaran_pekerjaan'],
        statusLamaran: item['status']?.toString() ?? 'Belum Diproses',
        posisiDilamar: item['posisi']?.toString() ?? '',
      );
    }).toList();
  }

  void _searchPelamar(String value) {
    setState(() {
      query = value.trim().toLowerCase();

      if (query.isEmpty) {
        dataDitampilkan = _mapPelamar(resultsPelamar.take(5).toList());
        return;
      }

      final filteredData = resultsPelamar.where((item) {
        final firstName = item['first_name']?.toString().toLowerCase() ?? '';
        final lastName = item['last_name']?.toString().toLowerCase() ?? '';
        final email = item['email']?.toString().toLowerCase() ?? '';
        final position = item['posisi']?.toString().toLowerCase() ?? '';

        final fullName = '$firstName $lastName';

        return firstName.contains(query) ||
            lastName.contains(query) ||
            fullName.contains(query) ||
            email.contains(query) ||
            position.contains(query);
      }).toList();

      dataDitampilkan = _mapPelamar(filteredData);
    });
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFFD97706);
      case 'ditolak':
        return const Color(0xFFDC2626);
      case 'diterima':
        return const Color(0xFF15803D);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _statusBackground(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFFFFF7ED);
      case 'ditolak':
        return const Color(0xFFFEF2F2);
      case 'diterima':
        return const Color(0xFFF0FDF4);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return Icons.access_time_rounded;
      case 'ditolak':
        return Icons.cancel_outlined;
      case 'diterima':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: _searchPelamar,
        style: const TextStyle(
          fontFamily: 'poppins',
          fontSize: 12,
          color: _textColor,
        ),
        decoration: InputDecoration(
          hintText: 'Cari nama, email, atau posisi...',
          hintStyle: const TextStyle(
            fontFamily: 'poppins',
            fontSize: 11,
            color: Color(0xFF94A3B8),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _secondaryTextColor,
            size: 21,
          ),
          suffixIcon: query.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    searchController.clear();
                    _searchPelamar('');
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                    color: _secondaryTextColor,
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(
              color: _primaryColor,
              width: 1.2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildApplicantImage(String imagePath) {
    ImageProvider? imageProvider;

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      imageProvider = NetworkImage(imagePath);
    } else if (imagePath.startsWith('assets/')) {
      imageProvider = AssetImage(imagePath);
    }

    return CircleAvatar(
      radius: 25,
      backgroundColor: const Color(0xFFF1F5F9),
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? const Icon(
              Icons.person_rounded,
              color: _secondaryTextColor,
              size: 27,
            )
          : null,
      onBackgroundImageError:
          imageProvider is NetworkImage || imageProvider is AssetImage
              ? (exception, stackTrace) {}
              : null,
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalizedStatus = status.trim().toLowerCase();

    final color = normalizedStatus == 'belum diproses'
        ? const Color(0xFF64748B)
        : _statusColor(status);

    final backgroundColor = normalizedStatus == 'belum diproses'
        ? const Color(0xFFF1F5F9)
        : _statusBackground(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            normalizedStatus == 'belum diproses'
                ? Icons.info_outline_rounded
                : _statusIcon(status),
            size: 12,
            color: color,
          ),
          const SizedBox(width: 5),
          Text(
            status.isEmpty ? 'Belum Diproses' : status,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantCard(pelamarPekerjaan pelamar) {
    final String fullName = '${pelamar.firstName} ${pelamar.lastName}'.trim();

    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Detailpelamar(
              id_lamaran_perusahaan: pelamar.id_lamaran_pekerjaan,
            ),
          ),
        );

        if (result == true && mounted) {
          setState(() {
            _isLoading = true;
            _errorMessage = '';
          });

          await _fetchData();
        }
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildApplicantImage(pelamar.fotoProfil ?? ''),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName.isEmpty ? 'Nama tidak tersedia' : fullName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    pelamar.posisiDilamar,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 10,
                      color: _secondaryTextColor,
                    ),
                  ),
                  const SizedBox(height: 9),
                  _buildStatusBadge(pelamar.statusLamaran),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF94A3B8),
              size: 23,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 35,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: _secondaryTextColor,
              size: 30,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'poppins',
              fontSize: 10,
              color: _secondaryTextColor,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicantList() {
    if (resultsPelamar.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'Belum Ada Pelamar',
        description:
            'Saat ini belum ada pelamar yang mendaftar pada lowongan pekerjaan perusahaan Anda.',
      );
    }

    if (dataDitampilkan.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search_off_rounded,
        title: 'Pelamar Tidak Ditemukan',
        description:
            'Kami tidak menemukan pelamar yang sesuai dengan kata kunci pencarian Anda.',
      );
    }

    return Column(
      children: dataDitampilkan.map(_buildApplicantCard).toList(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 45,
              color: Color(0xFFDC2626),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'poppins',
                fontSize: 12,
                color: _secondaryTextColor,
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _fetchData();
              },
              icon: const Icon(Icons.refresh_rounded, size: 17),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 11,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(30),
          child: CircularProgressIndicator(
            color: _primaryColor,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    return Container(
      color: _backgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 17),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSearchField(),
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Daftar Pelamar',
                        style: TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _textColor,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1E7E9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${dataDitampilkan.length} Pelamar',
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                const Text(
                  'Pilih pelamar untuk melihat detail lamaran.',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 10,
                    color: _secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildApplicantList(),
          ),
        ],
      ),
    );
  }
}
