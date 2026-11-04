part of '../page.dart';

class Profilehrd extends StatefulWidget {
  const Profilehrd({super.key});

  @override
  State<Profilehrd> createState() => _ProfilehrdState();
}

class _ProfilehrdState extends State<Profilehrd> {
  final TextEditingController namaPerusahaanController =
      TextEditingController();
  final TextEditingController alamatPerusahaanController =
      TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController tentangPerusahaanController =
      TextEditingController();

  final String defaultFotoIMG = 'assets/img/defaultPict.png';

  final LoginAPI loginapi = LoginAPI();
  final meAPI meapi = meAPI();
  final PerusahaanAPI perusahaanapi = PerusahaanAPI();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  File? _imageFile;
  dynamic user;

  bool isLoading = true;
  bool isSaving = false;

  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _primaryColor = Color(0xFF7B1E2B);
  static const Color _textColor = Color(0xFF1E293B);
  static const Color _secondaryTextColor = Color(0xFF64748B);
  static const Color _borderColor = Color(0xFFE2E8F0);
  static const Color _successColor = Color(0xFF15803D);
  static const Color _dangerColor = Color(0xFFDC2626);

  @override
  void initState() {
    super.initState();
    initUser();
    _initializeNotifications();
    _requestNotificationPermission();
  }

  @override
  void dispose() {
    namaPerusahaanController.dispose();
    alamatPerusahaanController.dispose();
    emailController.dispose();
    tentangPerusahaanController.dispose();
    super.dispose();
  }

  Future<void> initUser() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await meapi.getUserProfile();

      if (!mounted) return;

      if (response['status'] == true && response['data'] != null) {
        final data = response['data'];

        setState(() {
          user = data;

          namaPerusahaanController.text =
              (data['nama_perusahaan'] ?? data['nama'] ?? '').toString();

          alamatPerusahaanController.text = (data['alamat'] ?? '').toString();

          emailController.text = (data['email'] ?? '').toString();

          tentangPerusahaanController.text = (data['deskripsi'] ??
                  data['about_me'] ??
                  data['aboutMe'] ??
                  data['about'] ??
                  '')
              .toString();

          isLoading = false;
        });
      } else {
        setState(() {
          user = null;
          isLoading = false;
        });

        debugPrint(
          'Failed to retrieve user data: ${response['message']}',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      debugPrint('Error loading profile: $e');

      _showSnackBar(
        'Gagal mengambil data profil perusahaan.',
        isError: true,
      );
    }
  }

  ImageProvider _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    final String? imagePath = user?['profile_pict']?.toString();

    if (imagePath == null || imagePath.isEmpty) {
      return AssetImage(defaultFotoIMG);
    }

    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return NetworkImage(imagePath);
    }

    if (imagePath.startsWith('assets/')) {
      return AssetImage(imagePath);
    }

    return AssetImage(defaultFotoIMG);
  }

  Widget _buildProfileImage() {
    return Container(
      width: 126,
      height: 126,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(
          color: _primaryColor.withOpacity(0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
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

  Future<void> _requestNotificationPermission() async {
    try {
      final bool? granted = await flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();

      if (granted != null && !granted) {
        debugPrint('Izin notifikasi ditolak oleh pengguna.');
      }
    } catch (e) {
      debugPrint('Notification permission error: $e');
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
      );

      await flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
      );
    } catch (e) {
      debugPrint('Notification initialization error: $e');
    }
  }

  Future<void> showProfileUpdatedNotification() async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'profile_channel',
        'Profile Update Notifications',
        channelDescription: 'Notifications for profile updates',
        importance: Importance.high,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
      );

      await flutterLocalNotificationsPlugin.show(
        0,
        'Profil Diperbarui',
        'Profil Anda telah berhasil diperbarui.',
        platformChannelSpecifics,
      );
    } catch (e) {
      debugPrint('Show notification error: $e');
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
        backgroundColor: isError ? _dangerColor : _successColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Future<void> _updateProfileData(
    String email,
    String namaPerusahaan,
    String tentangPerusahaan,
    String alamatPerusahaan,
  ) async {
    if (email.trim().isEmpty) {
      _showSnackBar(
        'Email tidak boleh kosong!',
        isError: true,
      );
      return;
    }

    if (namaPerusahaan.trim().isEmpty) {
      _showSnackBar(
        'Nama perusahaan tidak boleh kosong!',
        isError: true,
      );
      return;
    }

    if (user == null) {
      _showSnackBar(
        'Data profil belum tersedia.',
        isError: true,
      );
      return;
    }

    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final success = await perusahaanapi.updateProfileData(
        idperusahaan: int.tryParse(
              user['id_perusahaan']?.toString() ?? '',
            ) ??
            1,
        email: email.trim(),
        namaPerusahaan: namaPerusahaan.trim(),
        tentangPerusahaan: tentangPerusahaan.trim(),
        alamatPerusahaan: alamatPerusahaan.trim(),
      );

      if (!mounted) return;

      if (success) {
        await showProfileUpdatedNotification();

        if (!mounted) return;

        await initUser();

        if (!mounted) return;

        _showSnackBar('Profil berhasil diperbarui!');
      } else {
        _showSnackBar(
          'Gagal memperbarui profil.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Update profile error: $e');

      _showSnackBar(
        'Terjadi kesalahan saat memperbarui profil.',
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  Future<void> logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Keluar dari Akun?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari akun perusahaan?',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              color: _secondaryTextColor,
              height: 1.6,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: _secondaryTextColor,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ya, Keluar',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    try {
      final bool result = await loginapi.logout();

      if (!mounted) return;

      if (result) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/',
          (route) => false,
        );
      } else {
        _showSnackBar(
          'Gagal keluar dari akun.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Logout error: $e');

      _showSnackBar(
        'Terjadi kesalahan saat logout.',
        isError: true,
      );
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          enabled: !isSaving,
          textAlignVertical: TextAlignVertical.center,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            color: _textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              color: Color(0xFF94A3B8),
            ),
            prefixIcon: Icon(
              icon,
              size: 19,
              color: _secondaryTextColor,
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            alignLabelWithHint: true,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 15,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _borderColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(color: _borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: _primaryColor,
                width: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  color: _secondaryTextColor,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    final String nama = namaPerusahaanController.text.trim().isNotEmpty
        ? namaPerusahaanController.text.trim()
        : 'Perusahaan';

    final String email = emailController.text.trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              _buildProfileImage(),
              Positioned(
                right: 0,
                bottom: 3,
                child: Material(
                  color: _primaryColor,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const Changeprofilepageperusahaan(),
                        ),
                      ).then((_) {
                        if (mounted) initUser();
                      });
                    },
                    child: const SizedBox(
                      width: 38,
                      height: 38,
                      child: Icon(
                        Icons.camera_alt_outlined,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _textColor,
            ),
          ),
          if (email.isNotEmpty) ...[
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.email_outlined,
                  size: 14,
                  color: _secondaryTextColor,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    email,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 11,
                      color: _secondaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business_outlined,
                  size: 14,
                  color: Color(0xFF2563EB),
                ),
                SizedBox(width: 6),
                Text(
                  'Akun Perusahaan',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving
            ? null
            : () {
                _updateProfileData(
                  emailController.text,
                  namaPerusahaanController.text,
                  tentangPerusahaanController.text,
                  alamatPerusahaanController.text,
                );
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: _primaryColor.withOpacity(0.5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
        child: isSaving
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
                  Icon(Icons.save_outlined, size: 19),
                  SizedBox(width: 9),
                  Text(
                    'Simpan Perubahan',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: isSaving ? null : onPressed,
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          side: const BorderSide(color: _borderColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(13),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: _primaryColor,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 55,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            const Text(
              'Gagal Memuat Profil',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _textColor,
              ),
            ),
            const SizedBox(height: 7),
            const Text(
              'Periksa koneksi internet Anda dan coba kembali.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                color: _secondaryTextColor,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: initUser,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text(
                'Coba Lagi',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: _textColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Profil Perusahaan',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _textColor,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Pengaduan',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Pengaduan(),
                ),
              );
            },
            icon: const Icon(
              Icons.support_agent_rounded,
              color: _primaryColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: _borderColor,
          ),
        ),
      ),
      body: SafeArea(
        bottom: true,
        child: isLoading
            ? _buildLoadingView()
            : user == null
                ? _buildErrorView()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 35),
                    children: [
                      _buildProfileHeader(),
                      const SizedBox(height: 25),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              title: 'Informasi Perusahaan',
                              subtitle:
                                  'Kelola informasi dan identitas perusahaan Anda.',
                              icon: Icons.business_outlined,
                            ),
                            const SizedBox(height: 22),
                            _buildTextField(
                              label: 'Nama Perusahaan',
                              hint: 'Masukkan nama perusahaan',
                              icon: Icons.business_center_outlined,
                              controller: namaPerusahaanController,
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'Alamat Perusahaan',
                              hint: 'Masukkan alamat perusahaan',
                              icon: Icons.location_on_outlined,
                              controller: alamatPerusahaanController,
                              maxLines: 2,
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'Email Perusahaan',
                              hint: 'Masukkan email perusahaan',
                              icon: Icons.email_outlined,
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 18),
                            _buildTextField(
                              label: 'Tentang Perusahaan',
                              hint: 'Ceritakan informasi mengenai perusahaan',
                              icon: Icons.description_outlined,
                              controller: tentangPerusahaanController,
                              maxLines: 5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader(
                              title: 'Bantuan & Keamanan',
                              subtitle:
                                  'Kelola keamanan akun dan dapatkan bantuan.',
                              icon: Icons.shield_outlined,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildSecondaryButton(
                                    label: 'Reset Password',
                                    icon: Icons.lock_reset_rounded,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Resetpassperusahaan(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildSecondaryButton(
                                    label: 'Pusat Pengaduan',
                                    icon: Icons.support_agent_rounded,
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const Pengaduan(),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildPrimaryButton(),
                      const SizedBox(height: 14),
                      SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: isSaving ? null : logout,
                          icon: const Icon(
                            Icons.logout_rounded,
                            size: 19,
                          ),
                          label: const Text(
                            'Keluar dari Akun',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: _dangerColor,
                            side: BorderSide(
                              color: _dangerColor.withOpacity(0.25),
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Center(
                        child: Text(
                          'RekanPabrik',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}
