part of '../page.dart';

class Homepagehrd extends StatefulWidget {
  const Homepagehrd({super.key});

  @override
  State<Homepagehrd> createState() => _HomepagehrdState();
}

class _HomepagehrdState extends State<Homepagehrd> {
  dynamic user;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    initUser();
  }

  Future<void> initUser() async {
    try {
      final response = await meAPI().getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        setState(() {
          user = response['data'];
          errorMessage = null;
        });
      } else {
        setState(() {
          errorMessage =
              response['message'] ?? 'Gagal memuat profil perusahaan.';
        });
      }
    } catch (e) {
      debugPrint('Error loading HRD profile: $e');

      if (!mounted) return;

      setState(() {
        errorMessage =
            'Tidak dapat terhubung ke server. Periksa jaringan Anda.';
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            color: darkMaroon,
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return _buildErrorState();
    }

    final String companyName =
        (user?['nama_perusahaan'] ?? 'Perusahaan').toString();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: RefreshIndicator(
          color: darkMaroon,
          onRefresh: initUser,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            children: [
              _buildTopHeader(companyName),

              const SizedBox(height: 30),

              _buildWelcomeSection(),

              const SizedBox(height: 24),

              _buildFeatureCard(
                imagePath: 'assets/img/Image1.png',
                title: 'Mencari kandidat yang tepat?',
                description:
                    'Temukan kandidat potensial dan buka kesempatan kerja baru untuk perusahaan Anda.',
                buttonText: 'Unggah Lowongan',
                icon: Icons.post_add_rounded,
                onPressed: () {
                  _navigateToMenu(2);
                },
              ),

              const SizedBox(height: 20),

              _buildFeatureCard(
                imagePath: 'assets/img/Image2.png',
                title: 'Telusuri kandidat yang tepat',
                description:
                    'Periksa daftar pelamar dan temukan kandidat yang sesuai dengan kriteria perusahaan Anda.',
                buttonText: 'Lihat Kandidat',
                icon: Icons.people_alt_rounded,
                onPressed: () {
                  _navigateToMenu(1);
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: darkMaroon.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 36,
                    color: darkMaroon,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Koneksi Terputus',
                  style: TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: blackColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  errorMessage ?? 'Gagal memuat data perusahaan.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontSize: 13,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      isLoading = true;
                      errorMessage = null;
                    });

                    initUser();
                  },
                  icon: const Icon(
                    Icons.refresh_rounded,
                    size: 18,
                  ),
                  label: const Text(
                    'Coba Lagi',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkMaroon,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(String companyName) {
    final String? profilePicture = user?['profile_pict']?.toString();

    final bool hasProfilePicture = profilePicture != null &&
        profilePicture.isNotEmpty &&
        !profilePicture.startsWith('assets/');

    return Row(
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: darkMaroon.withOpacity(0.25),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: hasProfilePicture
                ? Image.network(
                    profilePicture,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return _defaultAvatar();
                    },
                  )
                : _defaultAvatar(),
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyName,
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: blackColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 3),
              const Row(
                children: [
                  Icon(
                    Icons.business_rounded,
                    size: 13,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Recruitment / HRD',
                    style: TextStyle(
                      fontFamily: 'poppins',
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        _buildHeaderIconButton(
          icon: Icons.notifications_rounded,
          onTap: () {
            _showNotificationDialog();
          },
        ),
      ],
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: darkMaroon.withOpacity(0.08),
      child: Icon(
        Icons.business_rounded,
        size: 30,
        color: darkMaroon,
      ),
    );
  }

  Widget _buildHeaderIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: blackColor,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: darkMaroon,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: darkMaroon.withOpacity(0.18),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -20,
            child: Icon(
              Icons.business_center_rounded,
              size: 115,
              color: Colors.white.withOpacity(0.08),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat Datang!',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Kelola proses rekrutmen dan temukan talenta terbaik untuk perusahaan Anda.',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 12,
                  height: 1.6,
                  color: Colors.white.withOpacity(0.85),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.15),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: Colors.white,
                      size: 15,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'HRD Dashboard',
                      style: TextStyle(
                        fontFamily: 'poppins',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String imagePath,
    required String title,
    required String description,
    required String buttonText,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              imagePath,
              height: 190,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  height: 190,
                  width: double.infinity,
                  color: const Color(0xFFF1F5F9),
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 40,
                    color: greyColor,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          Text(
            title,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: blackColor,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            description,
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: greyColor,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onPressed,
              icon: Icon(
                icon,
                size: 18,
              ),
              label: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkMaroon,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                  horizontal: 16,
                ),
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMenu(int index) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HRDnavbarComponent(
          initialIndex: index,
        ),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(
                Icons.notifications_active_rounded,
                color: darkMaroon,
                size: 24,
              ),
              const SizedBox(width: 10),
              Text(
                'Notifikasi',
                style: TextStyle(
                  fontFamily: 'poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: darkMaroon,
                ),
              ),
            ],
          ),
          content: const Text(
            'Belum ada notifikasi terbaru.',
            style: TextStyle(
              fontFamily: 'poppins',
              fontSize: 13,
              color: Color(0xFF475569),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Tutup',
                style: TextStyle(
                  fontFamily: 'poppins',
                  color: darkMaroon,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
