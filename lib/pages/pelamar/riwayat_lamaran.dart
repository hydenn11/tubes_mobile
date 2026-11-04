part of '../page.dart';

class riwayatLamaran extends StatefulWidget {
  final bool showBackButton;

  const riwayatLamaran({super.key, this.showBackButton = false});

  @override
  State<riwayatLamaran> createState() => _riwayatLamaranState();
}

class _riwayatLamaranState extends State<riwayatLamaran> {
  int _selectedTabIndex = 0; // 0: Diproses, 1: Diterima, 2: Ditolak
  bool _isLoading = true;
  List<Map<String, dynamic>> _allApplications = [];
  var _user;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    try {
      final userRes = await meAPI().getUserProfile();
      if (userRes['status'] == true && userRes['data'] != null) {
        _user = userRes['data'];
      }
      final int pelamarId = _user != null ? (_user['id_pelamar'] ?? 1) : 1;
      final data = await MelamarPekerjaanapi().gethistoryLamaran(pelamarId);
      if (mounted) {
        setState(() {
          _allApplications = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading applications: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> _filterByStatus(String status) {
    final List<Map<String, dynamic>> filtered = [];
    for (final app in _allApplications) {
      final s = (app['status_lamaran'] ?? '').toString().toLowerCase().trim();
      if (s == status.toLowerCase().trim()) {
        filtered.add(app);
      }
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final bool showBack = widget.showBackButton;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // 1. TOP HEADER (BRAND DARK MAROON DENGAN WATERMARK TAS KERJA)
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  darkMaroon,
                  const Color(0xFF5A1414),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(
                children: [
                  // Siluet Watermark Tas Kerja / Briefcase
                  Positioned(
                    right: 12,
                    top: 10,
                    child: Opacity(
                      opacity: 0.16,
                      child: Icon(
                        Icons.business_center_rounded,
                        size: 130,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Konten Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tombol Kembali (Hanya tampil jika ditekan dari "Riwayat Lengkap" di Beranda)
                        if (showBack) ...[
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 14),
                        ] else
                          const SizedBox(height: 10),

                        // Judul Lamaran Anda (Multi-line bold)
                        const Text(
                          "Lamaran\nAnda",
                          style: TextStyle(
                            fontFamily: 'poppins',
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. TAB BAR (DIPROSES, DITERIMA, DITOLAK TERPISAH DENGAN INDIKATOR AKTIF)
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                _buildTabButton(0, "Diproses"),
                _buildTabButton(1, "Diterima"),
                _buildTabButton(2, "Ditolak"),
              ],
            ),
          ),

          // 3. TAB CONTENT (LISTVIEW KARTU LAMARAN)
          Expanded(
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: darkMaroon,
                    ),
                  )
                : _buildActiveTabContent(),
          ),
        ],
      ),
    );
  }

  // BUILDER TOMBOL TAB DENGAN INDIKATOR GARIS BAWAH
  Widget _buildTabButton(int index, String title) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTabIndex = index;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected ? blackColor : const Color(0xFF64748B),
                  ),
                ),
              ),
              Container(
                height: 3.5,
                width: 65,
                decoration: BoxDecoration(
                  color: isSelected ? darkMaroon : Colors.transparent,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // CONTENT SESUAI TAB YANG AKTIF
  Widget _buildActiveTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildApplicationList(
          items: _filterByStatus('diproses'),
          accentColor: const Color(0xFFEAB308), // Amber / Kuning
          statusMessage: "Lamaran anda sedang diproses",
          emptyMessage: "Belum ada lamaran yang sedang diproses.",
        );
      case 1:
        return _buildApplicationList(
          items: _filterByStatus('diterima'),
          accentColor: const Color(0xFF10B981), // Emerald / Hijau
          statusMessage: "Selamat! Lamaran anda diterima",
          emptyMessage: "Belum ada lamaran yang diterima.",
        );
      case 2:
      default:
        return _buildApplicationList(
          items: _filterByStatus('ditolak'),
          accentColor: const Color(0xFFEF4444), // Red / Merah
          statusMessage: "Lamaran anda belum sesuai",
          emptyMessage: "Tidak ada lamaran yang ditolak.",
        );
    }
  }

  // BUILDER LIST LAMARAN PER TAB
  Widget _buildApplicationList({
    required List<Map<String, dynamic>> items,
    required Color accentColor,
    required String statusMessage,
    required String emptyMessage,
  }) {
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadApplications,
        color: darkMaroon,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 90),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.inbox_rounded,
                      size: 36,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    emptyMessage,
                    style: const TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadApplications,
      color: darkMaroon,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return _buildApplicationCard(
            item: item,
            accentColor: accentColor,
            statusMessage: statusMessage,
          );
        },
      ),
    );
  }

  // BUILDER KARTU LAMARAN PERSIS SEPERTI GAMBAR
  Widget _buildApplicationCard({
    required Map<String, dynamic> item,
    required Color accentColor,
    required String statusMessage,
  }) {
    final String companyName =
        (item['nama_perusahaan'] ?? 'Perusahaan').toString();
    final String posisi = (item['posisi'] ?? 'Operator Produksi').toString();
    final int idLamaran = item['id_lamaran_pekerjaan'] ?? 1;

    // Nama singkatan untuk logo avatar
    final String shortName = companyName
        .replaceAll('PT ', '')
        .replaceAll(' Tbk', '')
        .split(' ')
        .first
        .toUpperCase();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  Detailhistorylamaran(idLamaranPekerjaan: idLamaran),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: darkMaroon.withValues(alpha: 0.08),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. GARIS STATUS VERTIKAL
              Container(
                width: 4.5,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              const SizedBox(width: 14),

              // 2. KOTAK LOGO / AVATAR PERUSAHAAN
              Container(
                width: 64,
                height: 44,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
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
                      fontWeight: FontWeight.w900,
                      color: darkMaroon,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // 3. INFORMASI STATUS & PERUSAHAAN
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      statusMessage,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 12,
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    RichText(
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'poppins',
                          fontSize: 13,
                          color: Color(0xFF64748B),
                        ),
                        children: [
                          const TextSpan(text: "oleh "),
                          TextSpan(
                            text: companyName,
                            style: TextStyle(
                              color: blackColor,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      posisi,
                      style: const TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
